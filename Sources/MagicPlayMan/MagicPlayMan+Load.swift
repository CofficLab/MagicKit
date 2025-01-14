import AVFoundation
import Combine
import Foundation
import MagicKit
import os.log
import SwiftUI

extension MagicPlayMan {
    /// 从 URL 加载媒体
    /// - Parameters:
    ///   - url: 媒体文件的 URL
    ///   - autoPlay: 是否自动开始播放，默认为 true
    func loadFromURL(_ url: URL, autoPlay: Bool = true) {
        os_log("\(self.t)Loading asset from URL: \(url.shortPath())")

        stop()
        currentURL = url
        state = .loading(.preparing)
        os_log("\(self.t)State changed to loading.preparing")

        if url.isNotFileExist {
            state = .failed(.invalidAsset)
            os_log(.error, "\(self.t)File not found:\(url.shortPath())")
            return
        }

        self.loadThumbnail(for: url)

        let item = AVPlayerItem(url: url)

        // 监听加载状态
        let observation = item.observe(\.status) { [weak self] item, _ in
            guard let self = self else { return }
            switch item.status {
            case .readyToPlay:
                self.duration = item.duration.seconds
                os_log("\(self.t)Asset ready to play, duration: \(self.duration)")
                if case .loading = self.state {
                    self.state = autoPlay ? .playing : .paused
                    if autoPlay {
                        self.play()
                    }
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
            os_log("\(self.t)Cache is disabled, loading directly")
            loadFromURL(asset.url)
            return
        }

        state = .loading(.connecting)
        os_log("\(self.t)Starting download for asset: \(asset.url.shortPath())")

        // 创建下载任务
        let task = URLSession.shared.dataTask(with: asset.url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                os_log("\(self.t)Download failed: \(error.localizedDescription)")
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
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    self.state = .failed(.networkError("Invalid server response (HTTP \(statusCode))"))
                    self.log("Download failed: Invalid server response (HTTP \(statusCode))", level: .error)
                }
                return
            }

            // 验证数据是否是有效的媒体文件
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            do {
                try data.write(to: tempURL)
                os_log("\(self.t)Temporary file written to: \(tempURL.path)")

                let tempAsset = AVAsset(url: tempURL)

                Task {
                    os_log("\(self.t)Validating downloaded asset")
                    let isPlayable = try await tempAsset.load(.isPlayable)
                    if !isPlayable {
                        os_log("\(self.t)Downloaded asset is not playable")
                        throw NSError(domain: "MagicPlayMan", code: -1,
                                      userInfo: [NSLocalizedDescriptionKey: "Downloaded data is not a valid media file"])
                    }

                    try self.cache?.cache(data, for: asset.url)
                    os_log("\(self.t)Asset cached successfully")

                    if let cachedURL = self.cache?.cachedURL(for: asset.url) {
                        self.loadFromURL(cachedURL)
                        self.showToast("Download completed", icon: "checkmark.circle", style: .info)
                    }
                }
            } catch {
                os_log("\(self.t)Failed to cache asset: \(error.localizedDescription)")
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
    func loadThumbnail(for url: URL) {
        Task { @MainActor in
            do {
                currentThumbnail = try await url.thumbnail(size: CGSize(width: 600, height: 600), verbose: self.verbose)
            } catch {
                log("Failed to load thumbnail: \(error.localizedDescription)", level: .warning)
            }
        }
    }
}

// MARK: - Preview

#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
        .inMagicContainer()
}
