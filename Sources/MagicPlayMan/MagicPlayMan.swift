import AVFoundation
import Combine
import Foundation
import SwiftUI
import MagicUI

public class MagicPlayMan: ObservableObject {
    private let _player = AVPlayer()
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    private let cache: AssetCache?
    private var downloadTask: URLSessionDataTask?

    @Published public private(set) var currentAsset: MagicAsset?
    @Published public private(set) var state: PlaybackState = .idle
    @Published public private(set) var currentTime: TimeInterval = 0
    @Published public private(set) var duration: TimeInterval = 0
    @Published public private(set) var isBuffering = false
    @Published public private(set) var progress: Double = 0
    @Published public private(set) var logs: [PlaybackLog] = []

    public var player: AVPlayer { _player }

    /// 初始化播放器
    /// - Parameter cacheDirectory: 自定义缓存目录。如果为 nil，则使用系统默认缓存目录
    public init(cacheDirectory: URL? = nil) {
        // 初始化缓存，如果失败则禁用缓存功能
        cache = try? AssetCache(directory: cacheDirectory)
        if let cacheDir = cache?.directory {
            log("Cache directory: \(cacheDir.path)")
        } else {
            log("Cache disabled", level: .warning)
        }

        setupPlayer()
        setupObservers()
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
        } catch {
            log("Failed to clear cache: \(error.localizedDescription)", level: .error)
        }
    }

    private func setupPlayer() {
        timeObserver = _player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            if self.duration > 0 {
                self.progress = self.currentTime / self.duration
            }
        }
    }

    private func setupObservers() {
        // 监听播放状态
        _player.publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .playing:
                    if case .loading = self.state {
                        self.state = .playing
                    }
                    self.isBuffering = false
                case .paused:
                    if case .playing = self.state {
                        self.state = self.currentTime == 0 ? .stopped : .paused
                    }
                case .waitingToPlayAtSpecifiedRate:
                    self.isBuffering = true
                    if case .playing = self.state {
                        self.state = .loading(.buffering)
                    }
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)

        // 监听缓冲状态
        _player.publisher(for: \.currentItem?.isPlaybackBufferEmpty)
            .sink { [weak self] isEmpty in
                if let isEmpty = isEmpty {
                    self?.isBuffering = isEmpty
                }
            }
            .store(in: &cancellables)
    }

    public func load(asset: MagicAsset) {
        log("Loading asset: \(asset.metadata.title)")
        currentAsset = asset
        state = .loading(.connecting)

        // 检查缓存
        if let cachedURL = cache?.cachedURL(for: asset.url) {
            log("Loading asset from cache")
            loadFromURL(cachedURL)
            return
        }

        // 如果是示例资源，则下载并缓存
        if isSampleAsset(asset) {
            downloadAndCache(asset)
        } else {
            // 非示例资源直接加载
            loadFromURL(asset.url)
        }
    }

    private func loadFromURL(_ url: URL) {
        let playerItem = AVPlayerItem(url: url)
        _player.replaceCurrentItem(with: playerItem)

        // 监听播放项状态
        playerItem.publisher(for: \.status)
            .sink { [weak self] status in
                switch status {
                case .readyToPlay:
                    self?.duration = playerItem.duration.seconds
                    self?.state = .paused
                    self?.log("Asset ready to play")
                case .failed:
                    if let error = playerItem.error {
                        // 转换 AVPlayer 错误为 PlaybackError
                        let playbackError: PlaybackState.PlaybackError
                        if let urlError = error as? URLError {
                            playbackError = .networkError(urlError.localizedDescription)
                        } else {
                            playbackError = .playbackError(error.localizedDescription)
                        }
                        self?.state = .failed(playbackError)
                        self?.log("Failed to load asset: \(error.localizedDescription)", level: .error)
                    } else {
                        self?.state = .failed(.invalidAsset)
                        self?.log("Failed to load asset: Unknown error", level: .error)
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)

        // 监听缓冲进度
        playerItem.publisher(for: \.isPlaybackLikelyToKeepUp)
            .sink { [weak self] isLikelyToKeepUp in
                if !isLikelyToKeepUp {
                    self?.state = .loading(.buffering)
                }
            }
            .store(in: &cancellables)

        // 监听加载状态
        playerItem.publisher(for: \.loadedTimeRanges)
            .sink { [weak self] _ in
                if case .loading = self?.state {
                    self?.state = .loading(.preparing)
                }
            }
            .store(in: &cancellables)
    }

    private func downloadAndCache(_ asset: MagicAsset) {
        log("Downloading asset for caching")

        let session = URLSession.shared
        downloadTask?.cancel()

        downloadTask = session.dataTask(with: asset.url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    self.state = .failed(.networkError(error.localizedDescription))
                    self.log("Download failed: \(error.localizedDescription)", level: .error)
                    return
                }

                guard let data = data else {
                    self.state = .failed(.networkError("No data received"))
                    self.log("Download failed: No data received", level: .error)
                    return
                }

                do {
                    try self.cache?.cache(data, for: asset.url)
                    self.log("Asset cached successfully")

                    if let cachedURL = self.cache?.cachedURL(for: asset.url) {
                        self.loadFromURL(cachedURL)
                    }
                } catch {
                    self.log("Failed to cache asset: \(error.localizedDescription)", level: .warning)
                    self.loadFromURL(asset.url)
                }
            }
        }

        downloadTask?.resume()
    }

    private func isSampleAsset(_ asset: MagicAsset) -> Bool {
        SupportedFormat.allSamples.contains { $0.asset.url == asset.url }
    }

    public func play() {
        guard state != .playing else { return }

        if currentAsset == nil {
            state = .failed(.noAsset)
            log("Attempted to play with no asset loaded", level: .error)
            return
        }

        log("Starting playback")
        _player.play()
        state = .playing
    }

    public func pause() {
        guard state == .playing else { return }
        log("Pausing playback")
        _player.pause()
        state = .paused
    }

    public func stop() {
        _player.pause()
        seek(to: 0)
        state = .stopped
    }

    public func seek(to progress: Double) {
        let time = duration * progress
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        _player.seek(to: cmTime)
    }

    public func skipForward(by seconds: TimeInterval = 10) {
        let targetTime = min(currentTime + seconds, duration)
        seek(to: targetTime / duration)
    }

    public func skipBackward(by seconds: TimeInterval = 10) {
        let targetTime = max(currentTime - seconds, 0)
        seek(to: targetTime / duration)
    }

    deinit {
        downloadTask?.cancel()
        if let timeObserver = timeObserver {
            _player.removeTimeObserver(timeObserver)
        }
        cancellables.removeAll()
    }

    private func log(_ message: String, level: PlaybackLog.Level = .info) {
        let log = PlaybackLog(timestamp: Date(), level: level, message: message)
        DispatchQueue.main.async {
            self.logs.append(log)
        }
    }

    public func clearLogs() {
        logs.removeAll()
    }

    // 视频视图
    @ViewBuilder
    public var videoView: some View {
        if let asset = currentAsset, asset.type == .video {
            VideoPlayerView(player: player)
        } else {
            EmptyView()
        }
    }
    
    // 音频视图
    @ViewBuilder
    public var audioView: some View {
        if let asset = currentAsset, asset.type == .audio {
            MagicAudioView(
                title: asset.metadata.title,
                artist: asset.metadata.artist
            )
        } else {
            EmptyView()
        }
    }
    
    // 空状态视图
    @ViewBuilder
    public var emptyView: some View {
        MagicAudioView(
            title: "No Media Selected",
            artist: "Select a media file to play"
        )
    }

    /// 获取支持的格式列表
    public var supportedFormats: [SupportedFormat] {
        SupportedFormat.allFormats
    }
}

#Preview {
    MagicPlayMan.PreviewView()
        .frame(width: 650, height: 500)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
        .previewDisplayName("MagicPlayMan")
}
