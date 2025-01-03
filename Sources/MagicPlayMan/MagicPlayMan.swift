import AVFoundation
import Combine
import Foundation
import SwiftUI
import MagicUI
import MediaPlayer

public class MagicPlayMan: ObservableObject {
    internal let _player = AVPlayer()
    internal var timeObserver: Any?
    internal var nowPlayingInfo: [String: Any] = [:]
    internal let _playlist = Playlist()
    internal var cache: AssetCache?
    
    public var cancellables = Set<AnyCancellable>()
    public var downloadTask: URLSessionDataTask?
    
    // MARK: - Publishers
    
    /// 播放事件发布者
    public class PlaybackEvents: ObservableObject {
        /// 事件订阅者信息
        public struct Subscriber {
            let id: UUID
            let name: String
            let date: Date
            
            public init(name: String) {
                self.id = UUID()
                self.name = name
                self.date = Date()
            }
        }
        
        /// 当前的订阅者列表
        @Published private(set) var subscribers: [Subscriber] = []
        
        /// 单曲播放完成事件
        /// 当播放列表被禁用时，通知调用者当前曲目播放完成
        /// 调用者可以通过订阅这个事件来处理播放完成，并决定下一首要播放的内容
        /// 只有在播放列表被禁用（isPlaylistEnabled = false）时才会触发
        public let onTrackFinished = PassthroughSubject<MagicAsset, Never>()
        
        /// 播放失败事件
        /// 当播放过程中发生错误时触发
        public let onPlaybackFailed = PassthroughSubject<PlaybackState.PlaybackError, Never>()
        
        /// 缓冲状态变化事件
        /// 当播放器开始或停止缓冲时触发
        public let onBufferingStateChanged = PassthroughSubject<Bool, Never>()
        
        /// 播放状态变化事件
        /// 当播放状态发生改变时触发（播放/暂停/停止等）
        public let onStateChanged = PassthroughSubject<PlaybackState, Never>()
        
        /// 添加订阅者
        func addSubscriber(_ name: String) -> UUID {
            let subscriber = Subscriber(name: name)
            subscribers.append(subscriber)
            return subscriber.id
        }
        
        /// 移除订阅者
        func removeSubscriber(id: UUID) {
            subscribers.removeAll { $0.id == id }
        }
        
        /// 获取订阅者信息
        func getSubscriberInfo(id: UUID) -> Subscriber? {
            subscribers.first { $0.id == id }
        }
        
        init() {}
    }
    
    /// 播放相关的事件发布者
    public private(set) lazy var events = PlaybackEvents()
    
    /// 订阅事件
    /// - Parameters:
    ///   - name: 订阅者名称，用于调试和跟踪
    ///   - onTrackFinished: 单曲播放完成的处理闭包
    ///   - onPlaybackFailed: 播放失败的处理闭包
    ///   - onBufferingStateChanged: 缓冲状态变化的处理闭包
    ///   - onStateChanged: 播放状态变化的处理闭包
    /// - Returns: 订阅者ID，可用于后续取消订阅
    @discardableResult
    public func subscribe(
        name: String,
        onTrackFinished: ((MagicAsset) -> Void)? = nil,
        onPlaybackFailed: ((PlaybackState.PlaybackError) -> Void)? = nil,
        onBufferingStateChanged: ((Bool) -> Void)? = nil,
        onStateChanged: ((PlaybackState) -> Void)? = nil
    ) -> UUID {
        let subscriberId = events.addSubscriber(name)
        
        if let handler = onTrackFinished {
            events.onTrackFinished
                .sink { [weak self] asset in
                    self?.log("事件：单曲播放完成 - 将由 \(name) 处理")
                    handler(asset)
                }
                .store(in: &cancellables)
        }
        
        if let handler = onPlaybackFailed {
            events.onPlaybackFailed
                .sink { [weak self] error in
                    self?.log("事件：播放失败 - 将由 \(name) 处理", level: .error)
                    handler(error)
                }
                .store(in: &cancellables)
        }
        
        if let handler = onBufferingStateChanged {
            events.onBufferingStateChanged
                .sink { [weak self] isBuffering in
                    self?.log("事件：缓冲状态变化 - 将由 \(name) 处理")
                    handler(isBuffering)
                }
                .store(in: &cancellables)
        }
        
        if let handler = onStateChanged {
            events.onStateChanged
                .sink { [weak self] state in
                    self?.log("事件：播放状态变化 - 将由 \(name) 处理")
                    handler(state)
                }
                .store(in: &cancellables)
        }
        
        return subscriberId
    }
    
    /// 取消订阅
    /// - Parameter subscriberId: 订阅者ID
    public func unsubscribe(_ subscriberId: UUID) {
        if let subscriber = events.getSubscriberInfo(id: subscriberId) {
            events.removeSubscriber(id: subscriberId)
            log("取消订阅：\(subscriber.name)")
        }
    }
    
    @Published public var items: [MagicAsset] = []
    @Published public var currentIndex: Int = -1
    @Published public var playMode: MagicPlayMode = .sequence
    @Published public var currentAsset: MagicAsset?
    @Published public var state: PlaybackState = .idle
    @Published public var currentTime: TimeInterval = 0
    @Published public var duration: TimeInterval = 0
    @Published public var isBuffering = false
    @Published public var progress: Double = 0
    @Published public var logs: [PlaybackLog] = []
    @Published public var currentThumbnail: Image?
    @Published public var isPlaylistEnabled: Bool = true

    public var player: AVPlayer { _player }
    public var asset: MagicAsset? { self.currentAsset }
    public var playing: Bool { self.state == .playing }
    public var hasAsset: Bool { self.asset != nil }
    public var playlist: Playlist { _playlist }

    /// 格式化后的当前播放时间，格式为 "mm:ss" 或 "hh:mm:ss"
    public var currentTimeForDisplay: String {
        currentTime.displayFormat
    }
    
    /// 格式化后的总时长，格式为 "mm:ss" 或 "hh:mm:ss"
    public var durationForDisplay: String {
        duration.displayFormat
    }

    public let logger = PlayLogger()

    /// 支持的媒体格式
    public var supportedFormats: [SupportedFormat] {
        SupportedFormat.allFormats
    }

    /// 获取当前缓存目录
    public var cacheDirectory: URL? {
        cache?.directory
    }

    /// 检查资源是否已缓存
    public func isAssetCached(_ asset: MagicAsset) -> Bool {
        cache?.isCached(asset.url) ?? false
    }

    /// 获取缓存大小（字节）
    public func cacheSize() throws -> UInt64 {
        try cache?.size() ?? 0
    }

    /// 清理所有缓存
    public func clearCache() {
        do {
            try cache?.clear()
            log("Cache cleared")
            showToast("Cache cleared successfully", icon: "trash", style: .info)
        } catch {
            log("Failed to clear cache: \(error.localizedDescription)", level: .error)
            showToast("Failed to clear cache", icon: "exclamationmark.triangle", style: .error)
        }
    }

    private func isSampleAsset(_ asset: MagicAsset) -> Bool {
        SupportedFormat.allSamples.contains { $0.asset.url == asset.url }
    }

    public func showToast(_ message: String, icon: String, style: MagicToast.Style) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .showToast,
                object: nil,
                userInfo: [
                    "message": message,
                    "icon": icon,
                    "style": style
                ]
            )
        }
    }

    public func log(_ message: String, level: PlaybackLog.Level = .info) {
        logger.log(message, level: level)
    }

    /// Returns the current playback error, if any.
    ///
    /// This property returns the error associated with the current failed playback state.
    /// If the player is not in a failed state, it returns `nil`.
    ///
    /// - Returns: The current `PlaybackError` or `nil` if there is no error.
    public var currentError: PlaybackState.PlaybackError? {
        if case .failed(let error) = state {
            return error
        }
        return nil
    }

    /// 剩余播放时间
    public var remainingTime: TimeInterval {
        max(0, duration - currentTime)
    }
}

#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
        .frame(width: 650, height: 800)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
}
