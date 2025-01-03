import Foundation
import SwiftUI

public extension MagicPlayMan {
    /// 加载并播放一个 URL
    /// - Parameters:
    ///   - url: 要播放的媒体 URL
    ///   - title: 可选的标题，如果不提供则使用文件名
    ///   - autoPlay: 是否自动开始播放，默认为 true
    /// - Returns: 如果成功加载返回 true，否则返回 false
    @MainActor @discardableResult
    func play(
        url: URL,
        title: String? = nil,
        autoPlay: Bool = true
    ) -> Bool {
        // 检查 URL 是否有效
        guard url.isFileURL || url.scheme == "http" || url.scheme == "https" else {
            log("Invalid URL scheme: \(url.scheme ?? "nil")", level: .error)
            return false
        }
        
        // 判断媒体类型
        let type: MagicAsset.MediaType
        if url.isVideo {
            type = .video
        } else if url.isAudio {
            type = .audio
        } else {
            log("Unsupported media type: \(url.pathExtension)", level: .error)
            return false
        }
        
        // 创建资源元数据
        let metadata = MagicAsset.Metadata(
            title: title ?? url.lastPathComponent,
            artist: nil,
            album: nil,
            artwork: nil
        )
        
        // 创建资源对象
        let asset = MagicAsset(
            url: url,
            type: type,
            metadata: metadata
        )
        
        // 加载资源
        if autoPlay {
            if isPlaylistEnabled {
                play(asset: asset)
            } else {
                load(asset: asset)
            }
        } else if isPlaylistEnabled {
            append(asset)
        } else {
            log("Cannot append: playlist is disabled", level: .warning)
            return false
        }
        
        log("Added URL to playlist: \(url.absoluteString)")
        return true
    }
    
    /// 加载并播放多个 URL
    /// - Parameters:
    ///   - urls: 要播放的媒体 URL 数组
    ///   - playFirst: 是否立即播放第一个资源，默认为 true
    /// - Returns: 成功加载的 URL 数量
    @MainActor @discardableResult
    func play(
        urls: [URL],
        playFirst: Bool = true
    ) -> Int {
        guard isPlaylistEnabled || urls.count == 1 else {
            log("Cannot play multiple URLs: playlist is disabled", level: .warning)
            return 0
        }
        
        var successCount = 0
        
        for (index, url) in urls.enumerated() {
            let shouldAutoPlay = playFirst && index == 0
            if play(url: url, autoPlay: shouldAutoPlay) {
                successCount += 1
            }
        }
        
        log("Added \(successCount) of \(urls.count) URLs to playlist")
        return successCount
    }
    
    /// 加载并播放一个 URL，带有完整的元数据
    /// - Parameters:
    ///   - url: 要播放的媒体 URL
    ///   - metadata: 媒体元数据
    ///   - autoPlay: 是否自动开始播放，默认为 true
    /// - Returns: 如果成功加载返回 true，否则返回 false
    @MainActor @discardableResult
    func play(
        url: URL,
        metadata: MagicAsset.Metadata,
        autoPlay: Bool = true
    ) -> Bool {
        // 检查 URL 是否有效
        guard url.isFileURL || url.scheme == "http" || url.scheme == "https" else {
            log("Invalid URL scheme: \(url.scheme ?? "nil")", level: .error)
            return false
        }
        
        // 判断媒体类型
        let type: MagicAsset.MediaType
        if url.isVideo {
            type = .video
        } else if url.isAudio {
            type = .audio
        } else {
            log("Unsupported media type: \(url.pathExtension)", level: .error)
            return false
        }
        
        // 创建资源对象
        let asset = MagicAsset(
            url: url,
            type: type,
            metadata: metadata
        )
        
        // 加载资源
        if autoPlay {
            play(asset: asset)
        } else {
            append(asset)
        }
        
        log("Added URL to playlist: \(url.absoluteString) with custom metadata")
        return true
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

