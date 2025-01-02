import AVFoundation
import Combine
import Foundation
import SwiftUI
import MagicUI
import MediaPlayer

public class MagicPlayMan: ObservableObject {
    private let _player = AVPlayer()
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    private let cache: AssetCache?
    private var downloadTask: URLSessionDataTask?
    private var nowPlayingInfo: [String: Any] = [:]
    private lazy var mediaCenterManager: MediaCenterManager = {
        let manager = MediaCenterManager(playMan: self)
        return manager
    }()
    
    private let playlist = Playlist()
    
    @Published public private(set) var items: [MagicAsset] = []
    @Published public private(set) var currentIndex: Int = -1
    @Published public private(set) var playMode: PlayMode = .sequence
    @Published public private(set) var currentAsset: MagicAsset?
    @Published public private(set) var state: PlaybackState = .idle
    @Published public private(set) var currentTime: TimeInterval = 0
    @Published public private(set) var duration: TimeInterval = 0
    @Published public private(set) var isBuffering = false
    @Published public private(set) var progress: Double = 0
    @Published public private(set) var logs: [PlaybackLog] = []
    @Published public private(set) var currentThumbnail: Image?

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

    private let logger = PlayLogger()

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

    public func load(asset: MagicAsset) {
        log("Loading asset: \(asset.title)")
        
        // 停止当前播放
        stop()
        
        currentAsset = asset
        state = .loading(.connecting)
        updateNowPlayingInfo()
        
        // 加载缩略图
        loadThumbnail(for: asset)
        
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
        mediaCenterManager.updateNowPlayingInfo(
            asset: currentAsset,
            state: state,
            currentTime: currentTime,
            duration: duration
        )
    }

    public func pause() {
        guard state == .playing else { return }
        log("Pausing playback")
        _player.pause()
        state = .paused
        mediaCenterManager.updateNowPlayingInfo(
            asset: currentAsset,
            state: state,
            currentTime: currentTime,
            duration: duration
        )
    }

    public func stop() {
        _player.pause()
        seek(to: 0)
        state = .stopped
        mediaCenterManager.updateNowPlayingInfo(
            asset: currentAsset,
            state: state,
            currentTime: currentTime,
            duration: duration
        )
    }

    public func seek(_ time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        _player.seek(to: cmTime)
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

    /// 切换播放状态
    /// 如果当前正在播放则暂停，如果当前已暂停则开始播放
    public func toggle() {
        switch state {
        case .playing:
            pause()
        case .paused, .stopped:
            play()
        case .loading, .failed, .idle:
            // 在这些状态下不执行任何操作
            log("Cannot toggle playback in current state: \(state)", level: .warning)
            break
        }
    }

    deinit {
        downloadTask?.cancel()
        if let timeObserver = timeObserver {
            _player.removeTimeObserver(timeObserver)
        }
        cancellables.removeAll()
        mediaCenterManager.cleanup()
    }

    /// 记录日志
    public func log(_ message: String, level: PlaybackLog.Level = .info) {
        logger.log(message, level: level)
    }
    
    /// 清空日志
    public func clearLogs() {
        logger.clear()
    }
    
    /// 创建日志视图
    public func makeLogView() -> some View {
        logger.makeLogView()
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

    private func setupRemoteControl() {
        #if os(iOS)
        // 请求音频会话
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif

        // 设置远程控制事件接收
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // 播放/暂停
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if self.state != .playing {
                self.play()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if self.state == .playing {
                self.pause()
                return .success
            }
            return .commandFailed
        }
        
        // 快进/快退
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.skipForward()
            return .success
        }
        
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.skipBackward()
            return .success
        }
        
        // 进度控制
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self.seek(to: event.positionTime / self.duration)
            return .success
        }
    }
    
    private func updateNowPlayingInfo() {
        guard let asset = currentAsset else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: asset.metadata.title,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: state == .playing ? 1.0 : 0.0
        ]
        
        if let artist = asset.metadata.artist {
            info[MPMediaItemPropertyArtist] = artist
        }
        
        // 设置媒体类型
        info[MPMediaItemPropertyMediaType] = asset.type == .audio ? 
            MPMediaType.music.rawValue : MPMediaType.movie.rawValue
        
        // 如果是视频，可以添加缩略图
        if asset.type == .video {
            Task {
                if let image = try? await generateThumbnail() {
                    info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
                        boundsSize: image.size,
                        requestHandler: { _ in image }
                    )
                    DispatchQueue.main.async {
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                    }
                }
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        self.nowPlayingInfo = info
    }
    
    private func generateThumbnail() async throws -> NSImage? {
        guard let asset = currentAsset,
              asset.type == .video else { return nil }
        
        let generator = AVAssetImageGenerator(asset: AVAsset(url: asset.url))
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 0, preferredTimescale: 600)
        let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
        
        #if os(macOS)
        return NSImage(cgImage: cgImage, size: .zero)
        #else
        return UIImage(cgImage: cgImage)
        #endif
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
    public func setPlayMode(_ mode: PlayMode) {
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

    // 添加 Toast 显示方法
    private func showToast(_ message: String, icon: String, style: MagicToast.Style) {
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
    
    /// 手动刷新当前资源的缩略图
    public func reloadThumbnail() {
        guard let asset = currentAsset else { return }
        loadThumbnail(for: asset)
    }

    /// 创建播放列表视图
    public func makePlaylistView() -> some View {
        playlist.makeListView(
            onSelect: { [weak self] asset in
                self?.play(asset: asset)
            },
            onRemove: { [weak self] index in
                self?.removeFromPlaylist(at: index)
            },
            onMove: { [weak self] from, to in
                self?.moveInPlaylist(from: from, to: to)
            }
        )
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
