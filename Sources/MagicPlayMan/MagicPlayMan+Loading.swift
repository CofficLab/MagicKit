import AVFoundation
import Combine
import Foundation
import SwiftUI

public extension MagicPlayMan {
    /// 加载媒体资源
    /// - Parameter asset: 要加载的资源
    func load(asset: MagicAsset) {
        Task { @MainActor in
            stop() // 确保在主线程上调用
            currentAsset = asset
            state = .loading(.preparing)
            log("Loading asset: \(asset.metadata.title)")

            self.loadFromURL(asset.url)
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
                  (200 ... 299).contains(response.statusCode) else {
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

#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
        .frame(width: 650, height: 800)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
}
