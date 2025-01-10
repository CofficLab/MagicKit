import AVFoundation
import Combine
import Foundation
import SwiftUI

import MediaPlayer
import MagicKit

public class MagicPlayMan: ObservableObject, SuperLog {
    public static var emoji = "🎧"
    
    internal let _player = AVPlayer()
    internal var timeObserver: Any?
    internal var nowPlayingInfo: [String: Any] = [:]
    internal let _playlist = Playlist()
    internal var cache: AssetCache?
    internal var verbose: Bool = true
    
    public var cancellables = Set<AnyCancellable>()
    public var downloadTask: URLSessionDataTask?
    
    /// 播放相关的事件发布者
    public private(set) lazy var events = PlaybackEvents()
    
    @Published public var items: [URL] = []
    @Published public var currentIndex: Int = -1
    @Published public var playMode: MagicPlayMode = .sequence {
        didSet {
            if oldValue != playMode {
                log("播放模式变更：\(oldValue) -> \(playMode)")
                events.onPlayModeChanged.send(playMode)
            }
        }
    }
    @Published public var currentURL: URL? {
        didSet {
            if let url = currentURL, oldValue != currentURL {
                events.onCurrentURLChanged.send(url)
            }
        }
    }
    @Published public var state: PlaybackState = .idle
    @Published public var currentTime: TimeInterval = 0
    @Published public var duration: TimeInterval = 0
    @Published public var isBuffering = false
    @Published public var progress: Double = 0
    @Published public var logs: [PlaybackLog] = []
    @Published public var currentThumbnail: Image?
    @Published public var isPlaylistEnabled: Bool = true
    @Published public var likedAssets: Set<URL> = []

    public var player: AVPlayer { _player }
    public var playing: Bool { self.state == .playing }
    public var hasAsset: Bool { self.currentURL != nil }
    public var playlist: Playlist { _playlist }
    public var currentAsset: URL? { currentURL }
    public var asset: URL? { currentURL }
    
    /// 当前资源是否被喜欢
    public var isCurrentAssetLiked: Bool {
        guard let url = currentURL else { return false }
        return likedAssets.contains(url)
    }

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

    private func isSampleAsset(_ asset: MagicAsset) -> Bool {
        SupportedFormat.allSamples.contains { $0.asset.url == asset.url }
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

    /// 检查指定资源是否被喜欢
    public func isAssetLiked(_ asset: MagicAsset) -> Bool {
        likedAssets.contains(asset.url)
    }
}

#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
}
