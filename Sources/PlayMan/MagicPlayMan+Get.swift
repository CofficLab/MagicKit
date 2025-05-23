import AVFoundation
import Foundation
import Core

public extension MagicPlayMan {
    /// Returns the current playback error, if any.
    ///
    /// This property returns the error associated with the current failed playback state.
    /// If the player is not in a failed state, it returns `nil`.
    ///
    /// - Returns: The current `PlaybackError` or `nil` if there is no error.
    var currentError: PlaybackState.PlaybackError? {
        if case let .failed(error) = state {
            return error
        }
        return nil
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

    /// 剩余播放时间
    public var remainingTime: TimeInterval {
        max(0, duration - currentTime)
    }

    /// 检查指定资源是否被喜欢
    public func isAssetLiked(_ asset: MagicAsset) -> Bool {
        likedAssets.contains(asset.url)
    }

    public var player: AVPlayer { _player }
    public var playing: Bool { self.state == .playing }
    public var hasAsset: Bool { self.currentURL != nil }
    public var playlist: Playlist { _playlist }
    public var currentAsset: URL? { currentURL }
    public var asset: URL? { currentURL }
    public var isLoading: Bool { if case .loading = self.state { return true } else { return false } }

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

    /// 支持的媒体格式
    public var supportedFormats: [SupportedFormat] {
        SupportedFormat.allFormats
    }
}
