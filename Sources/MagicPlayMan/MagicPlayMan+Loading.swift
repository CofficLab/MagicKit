import Foundation
import Combine
import AVFoundation
import SwiftUI

public extension MagicPlayMan {
    /// 加载媒体资源
    /// - Parameter asset: 要加载的资源
    func load(asset: MagicAsset) {
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
    
    /// 从 URL 加载媒体
    private func loadFromURL(_ url: URL) {
        log("Loading asset from URL: \(url.absoluteString)")
        
        // 预检查文件是否可访问
        #if os(macOS)
        if url.isFileURL && !FileManager.default.fileExists(atPath: url.path) {
            state = .failed(.invalidAsset)
            log("File not found: \(url.path)", level: .error)
            return
        }
        #endif
        
        let item = AVPlayerItem(url: url)
        
        // 监听加载状态
        let observation = item.observe(\.status) { [weak self] item, _ in
            guard let self = self else { return }
            switch item.status {
            case .readyToPlay:
                self.duration = item.duration.seconds
                if case .loading = self.state {
                    self.state = .playing
                    self.play()
                }
            case .failed:
                let message = item.error?.localizedDescription ?? "Unknown error"
                self.state = .failed(.playbackError(message))
                self.log("Playback failed: \(message)", level: .error)
            default:
                break
            }
        }
        
        // 保存观察者以防止被释放
        cancellables.insert(AnyCancellable {
            observation.invalidate()
        })
        
        _player.replaceCurrentItem(with: item)
    }
    
    /// 下载并缓存资源
    private func downloadAndCache(_ asset: MagicAsset) {
        guard let cache = cache else {
            log("Cache is disabled, loading directly", level: .warning)
            loadFromURL(asset.url)
            return
        }
        
        state = .loading(.connecting)
        
        // 创建下载任务
        let task = URLSession.shared.dataTask(with: asset.url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.state = .failed(.networkError(error.localizedDescription))
                    self.log("Download failed: \(error.localizedDescription)", level: .error)
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  let data = data,
                  (200...299).contains(response.statusCode) else {
                DispatchQueue.main.async {
                    self.state = .failed(.networkError("Invalid server response"))
                    self.log("Download failed: Invalid server response", level: .error)
                }
                return
            }
            
            // 验证数据是否是有效的媒体文件
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            do {
                try data.write(to: tempURL)
                let tempAsset = AVAsset(url: tempURL)
                
                Task {
                    let isPlayable = try await tempAsset.load(.isPlayable)
                    if !isPlayable {
                        throw NSError(domain: "MagicPlayMan", code: -1, 
                                    userInfo: [NSLocalizedDescriptionKey: "Downloaded data is not a valid media file"])
                    }
                    
                    try self.cache?.cache(data, for: asset.url)
                    self.log("Asset cached successfully")
                    
                    if let cachedURL = self.cache?.cachedURL(for: asset.url) {
                        self.loadFromURL(cachedURL)
                        self.showToast("Download completed", icon: "checkmark.circle", style: .info)
                    }
                }
            } catch {
                self.log("Failed to cache asset: \(error.localizedDescription)", level: .error)
                self.loadFromURL(asset.url)
            }
            
            try? FileManager.default.removeItem(at: tempURL)
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
    
    /// 检查是否是示例资源
    private func isSampleAsset(_ asset: MagicAsset) -> Bool {
        SupportedFormat.allSamples.contains { $0.asset.url == asset.url }
    }
} 

// MARK: - Preview
#Preview("Asset Loading") {
    LoadingPreview().frame(height: 800)
}

private struct LoadingPreview: View {
    @StateObject private var playMan = MagicPlayMan()
    
    private let testAssets = [
        // 本地缓存测试
        (
            name: "Cached Audio",
            url: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/fd/37/41/fd374113-bf05-692f-e157-5c364af08d9d/mzaf_15384825730917775750.plus.aac.p.m4a")!,
            type: MagicAsset.MediaType.audio
        ),
        // 在线流媒体测试
        (
            name: "Streaming Video",
            url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
            type: MagicAsset.MediaType.video
        )
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // 状态显示
            playMan.makeStateView()
            
            // 加载测试按钮
            ForEach(testAssets, id: \.name) { asset in
                Button {
                    loadAsset(name: asset.name, url: asset.url, type: asset.type)
                } label: {
                    Label(
                        "Load \(asset.name)",
                        systemImage: asset.type == .audio ? "music.note" : "film"
                    )
                }
                .buttonStyle(.bordered)
            }
            
            // 缓存控制
            HStack {
                Button("Clear Cache") {
                    playMan.clearCache()
                }
                .buttonStyle(.bordered)
                
                if let asset = playMan.currentAsset {
                    Text(playMan.isAssetCached(asset) ? "Cached" : "Not Cached")
                        .foregroundStyle(.secondary)
                }
            }
            
            // 缩略图显示
            if let thumbnail = playMan.currentThumbnail {
                thumbnail
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
            }
            
            // 日志显示
            playMan.makeLogView()
        }
        .padding()
    }
    
    private func loadAsset(name: String, url: URL, type: MagicAsset.MediaType) {
        let asset = MagicAsset(
            url: url,
            type: type,
            metadata: .init(
                title: name,
                artist: "Test Artist",
                album: "Test Album"
            )
        )
        playMan.load(asset: asset)
    }
} 
