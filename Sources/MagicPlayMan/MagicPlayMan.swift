import AVFoundation
import Combine
import Foundation
import SwiftUI
import MagicUI
import MediaPlayer

public class MagicPlayMan: ObservableObject {
    internal let _player = AVPlayer()
    private var timeObserver: Any?
    public var cancellables = Set<AnyCancellable>()
    public let cache: AssetCache?
    public var downloadTask: URLSessionDataTask?
    internal var nowPlayingInfo: [String: Any] = [:]
    private lazy var mediaCenterManager: MediaCenterManager = {
        let manager = MediaCenterManager(playMan: self)
        return manager
    }()
    
    public let playlist = Playlist()
    
    @Published public private(set) var items: [MagicAsset] = []
    @Published public private(set) var currentIndex: Int = -1
    @Published public private(set) var playMode: MagicPlayMode = .sequence
    @Published public var currentAsset: MagicAsset?
    @Published public var state: PlaybackState = .idle
    @Published public var currentTime: TimeInterval = 0
    @Published public var duration: TimeInterval = 0
    @Published public var isBuffering = false
    @Published public var progress: Double = 0
    @Published public var logs: [PlaybackLog] = []
    @Published public var currentThumbnail: Image?

    public var player: AVPlayer { _player }
    public var asset: MagicAsset? { self.currentAsset }
    public var playing: Bool { self.state == .playing }
    public var hasAsset: Bool { self.asset != nil }

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

    /// 初始化播放器
    /// - Parameter cacheDirectory: 自定义缓存目录。如果为 nil，则使用系统默认缓存目录
    public init(cacheDirectory: URL? = nil) {
        // 初始化缓存，如果失败则禁用缓存功能
        let tempCache: AssetCache?
        do {
            tempCache = try AssetCache(directory: cacheDirectory)
        } catch {
            tempCache = nil
        }
        self.cache = tempCache
        
        // 完成初始化后再设置其他内容
        setupPlayer()
        setupObservers()
        setupRemoteControl()
        
        // 记录初始化日志
        if let cacheDir = cache?.directory {
            log("Cache directory: \(cacheDir.path)")
        } else {
            log("Cache disabled", level: .warning)
        }
        
        // 修改监听方式
        playlist.$items
            .sink { [weak self] items in
                self?.items = items
            }
            .store(in: &cancellables)
        
        playlist.$currentIndex
            .sink { [weak self] index in
                self?.currentIndex = index
            }
            .store(in: &cancellables)
        
        // 监听日志变化
        logger.$logs
            .assign(to: &$logs)
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

        // 更新播放进度
        $currentTime
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] time in
                self?.mediaCenterManager.updatePlaybackTime(time)
            }
            .store(in: &cancellables)
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
        showToast("Downloading \(asset.title)", icon: "arrow.down.circle", style: .info)
        
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
                        showToast("Download completed", icon: "checkmark.circle", style: .info)
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

    public func play(_ asset: MagicAsset, reason: String, verbose: Bool = false) {
        if verbose {
            log("Playing asset: \(asset.metadata.title) (reason: \(reason))")
        }
        play(asset: asset)
    }

    /// 添加资源到播放列表并播放
    public func play(asset: MagicAsset) {
        if playlist.play(asset) {
            load(asset: asset)
        } else {
            playlist.append(asset)
            _ = playlist.play(asset)
            load(asset: asset)
        }
    }
    
    /// 添加资源到播放列表
    public func append(_ asset: MagicAsset) {
        playlist.append(asset)
    }
    
    /// 清空播放列表
    public func clearPlaylist() {
        playlist.clear()
    }
    
    /// 播放下一曲
    public func next() {
        if let nextAsset = playlist.playNext(mode: playMode) {
            load(asset: nextAsset)
        }
    }
    
    /// 播放上一曲
    public func previous() {
        if let prevAsset = playlist.playPrevious(mode: playMode) {
            load(asset: prevAsset)
        }
    }

    // MARK: - 播放模式
    
    /// 切换播放模式
    public func togglePlayMode() {
        playMode = playMode.next
        log("Playback mode changed to: \(playMode.displayName)")
    }
    
    /// 设置播放模式
    public func setPlayMode(_ mode: MagicPlayMode) {
        playMode = mode
        log("Playback mode set to: \(mode.displayName)")
    }
    
    /// 从播放列表中移除指定索引的资源
    public func removeFromPlaylist(at index: Int) {
        playlist.remove(at: index)
    }
    
    /// 移动播放列表中的资源
    public func moveInPlaylist(from: Int, to: Int) {
        playlist.move(from: from, to: to)
    }

    public func showToast(_ message: String, icon: String, style: MagicToast.Style) {
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

    /// 加载资源的缩略图
    private func loadThumbnail(for asset: MagicAsset) {
        Task { @MainActor in
            do {
                currentThumbnail = try await asset.url.thumbnail(size: CGSize(width: 600, height: 600))
            } catch {
                log("Failed to load thumbnail: \(error.localizedDescription)", level: .warning)
            }
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
}

#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
        .frame(width: 650, height: 500)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
}
