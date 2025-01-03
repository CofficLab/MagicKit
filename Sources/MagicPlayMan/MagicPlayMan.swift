import AVFoundation
import Combine
import Foundation
import SwiftUI
import MagicUI
import MediaPlayer

public class MagicPlayMan: ObservableObject {
    internal let _player = AVPlayer()
    internal var timeObserver: Any?
    public var cancellables = Set<AnyCancellable>()
    internal var cache: AssetCache?
    public var downloadTask: URLSessionDataTask?
    internal var nowPlayingInfo: [String: Any] = [:]
    internal let _playlist = Playlist()
    
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
