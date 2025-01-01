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
        
        // 停止当前播放
        stop()
        
        currentAsset = asset
        state = .loading(.connecting)

        // 检查缓存
        if let cachedURL = cache?.cachedURL(for: asset.url) {
            // 验证缓存文件
            if cache?.validateCache(for: asset.url) == true {
                log("Loading asset from cache")
                loadFromURL(cachedURL)
            } else {
                log("Cached file is invalid, removing and redownloading", level: .warning)
                cache?.removeCached(asset.url)
                if isSampleAsset(asset) {
                    downloadAndCache(asset)
                } else {
                    loadFromURL(asset.url)
                }
            }
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
        log("Loading asset from URL: \(url.absoluteString)")
        
        // 预检查文件是否可访问
        #if os(macOS)
        if url.isFileURL && !FileManager.default.fileExists(atPath: url.path) {
            state = .failed(.invalidAsset)
            log("File does not exist at path: \(url.path)", level: .error)
            return
        }
        #endif
        
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        // 预加载关键属性
        Task { @MainActor in
            do {
                let isPlayable = try await asset.load(.isPlayable)
                if !isPlayable {
                    throw NSError(domain: "MagicPlayMan", code: -1, 
                                userInfo: [NSLocalizedDescriptionKey: "Asset is not playable"])
                }
            } catch {
                self.state = .failed(.invalidAsset)
                self.log("Asset validation failed: \(error.localizedDescription)", level: .error)
                return
            }
        }
        
        // 添加资源加载错误观察
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
                self.log("Playback failed: \(error.localizedDescription)", level: .error)
            }
        }
        
        _player.replaceCurrentItem(with: playerItem)
        
        // 监听播放项状态
        playerItem.publisher(for: \.status)
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .readyToPlay:
                    self.duration = playerItem.duration.seconds
                    self.state = .paused
                    self.log("Asset ready to play (duration: \(self.duration)s)")
                    
                    // 检查是否可以播放
                    if !playerItem.isPlaybackLikelyToKeepUp {
                        self.log("Playback not likely to keep up, buffering...", level: .warning)
                    }
                    
                    // 检查错误
                    if let error = playerItem.error {
                        self.log("Asset loaded but has error: \(error.localizedDescription)", level: .error)
                    }
                    
                case .failed:
                    if let error = playerItem.error {
                        // 获取更详细的错误信息
                        let errorDescription = error.localizedDescription
                        let underlyingError = (error as NSError).userInfo[NSUnderlyingErrorKey] as? Error
                        let underlyingDescription = underlyingError?.localizedDescription ?? "Unknown"
                        
                        self.log("Failed to load asset: \(errorDescription)", level: .error)
                        self.log("Underlying error: \(underlyingDescription)", level: .error)
                        
                        // 转换 AVPlayer 错误为 PlaybackError
                        let playbackError: PlaybackState.PlaybackError
                        if let urlError = error as? URLError {
                            playbackError = .networkError(urlError.localizedDescription)
                        } else {
                            playbackError = .playbackError(errorDescription)
                        }
                        self.state = .failed(playbackError)
                    } else {
                        self.state = .failed(.invalidAsset)
                        self.log("Failed to load asset: Unknown error", level: .error)
                    }
                    
                case .unknown:
                    self.log("Asset status unknown", level: .warning)
                    
                @unknown default:
                    self.log("Asset status: unexpected value", level: .warning)
                }
            }
            .store(in: &cancellables)
        
        // 监听缓冲进度
        playerItem.publisher(for: \.isPlaybackLikelyToKeepUp)
            .sink { [weak self] isLikelyToKeepUp in
                guard let self = self else { return }
                if !isLikelyToKeepUp {
                    self.state = .loading(.buffering)
                    self.log("Buffering required")
                }
            }
            .store(in: &cancellables)
        
        // 监听加载状态
        playerItem.publisher(for: \.loadedTimeRanges)
            .sink { [weak self] ranges in
                guard let self = self else { return }
                if case .loading = self.state {
                    self.state = .loading(.preparing)
                    if let timeRange = ranges.first?.timeRangeValue {
                        let bufferedDuration = timeRange.duration.seconds
                        self.log("Buffered duration: \(bufferedDuration)s")
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func downloadAndCache(_ asset: MagicAsset) {
        log("Downloading asset for caching")
        
        let session = URLSession.shared
        downloadTask?.cancel()
        
        // 创建带进度的数据任务
        let task = session.dataTask(with: asset.url) { [weak self] data, response, error in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                if let error = error {
                    self.state = .failed(.networkError(error.localizedDescription))
                    self.log("Download failed: \(error.localizedDescription)", level: .error)
                    return
                }
                
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    self.state = .failed(.networkError("Invalid server response"))
                    self.log("Download failed: Invalid server response", level: .error)
                    return
                }
                
                // 验证数据是否是有效的媒体文件
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                do {
                    try data.write(to: tempURL)
                    let tempAsset = AVAsset(url: tempURL)
                    let isPlayable = try await tempAsset.load(.isPlayable)
                    if !isPlayable {
                        throw NSError(domain: "MagicPlayMan", code: -1, 
                                    userInfo: [NSLocalizedDescriptionKey: "Downloaded data is not a valid media file"])
                    }
                    
                    try self.cache?.cache(data, for: asset.url)
                    self.log("Asset cached successfully")
                    
                    if let cachedURL = self.cache?.cachedURL(for: asset.url) {
                        self.loadFromURL(cachedURL)
                    }
                } catch {
                    self.log("Failed to cache asset: \(error.localizedDescription)", level: .error)
                    self.loadFromURL(asset.url)
                }
                
                try? FileManager.default.removeItem(at: tempURL)
            }
        }
        
        // 添加进度观察
        if let expectedSize = try? asset.url.resourceValues(forKeys: [.fileSizeKey]).fileSize {
            var observation: NSKeyValueObservation?
            observation = task.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
                DispatchQueue.main.async {
                    self?.state = .loading(.downloading(progress.fractionCompleted))
                    self?.log("Download progress: \(Int(progress.fractionCompleted * 100))%")
                }
            }
            downloadTask = task
            task.resume()
        } else {
            downloadTask = task
            task.resume()
        }
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

#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
        .frame(width: 650, height: 500)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
}
