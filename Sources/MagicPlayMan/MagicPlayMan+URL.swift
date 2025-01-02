import Foundation
import SwiftUI

public extension MagicPlayMan {
    /// 加载并播放一个 URL
    /// - Parameters:
    ///   - url: 要播放的媒体 URL
    ///   - title: 可选的标题，如果不提供则使用文件名
    ///   - autoPlay: 是否自动开始播放，默认为 true
    /// - Returns: 如果成功加载返回 true，否则返回 false
    @discardableResult
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
            play(asset: asset)
        } else {
            append(asset)
        }
        
        log("Added URL to playlist: \(url.absoluteString)")
        return true
    }
    
    /// 加载并播放多个 URL
    /// - Parameters:
    ///   - urls: 要播放的媒体 URL 数组
    ///   - playFirst: 是否立即播放第一个资源，默认为 true
    /// - Returns: 成功加载的 URL 数量
    @discardableResult
    func play(
        urls: [URL],
        playFirst: Bool = true
    ) -> Int {
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
    @discardableResult
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
#Preview("URL Playback") {
    URLPlaybackPreview()
}

private struct URLPlaybackPreview: View {
    @StateObject private var playMan = MagicPlayMan()
    
    private let sampleURLs = [
        // 音频示例
        URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/fd/37/41/fd374113-bf05-692f-e157-5c364af08d9d/mzaf_15384825730917775750.plus.aac.p.m4a")!,
        // 视频示例
        URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                // 单个 URL 播放
                Button("Play Audio URL") {
                    playMan.play(url: sampleURLs[0], title: "Sample Audio")
                }
                .buttonStyle(.bordered)
                
                Button("Play Video URL") {
                    playMan.play(url: sampleURLs[1], title: "Sample Video")
                }
                .buttonStyle(.bordered)
                
                // 批量 URL 播放
                Button("Play All URLs") {
                    playMan.play(urls: sampleURLs)
                }
                .buttonStyle(.bordered)
            }
            
            playMan.makeStateView()
            playMan.makeLogView()
        }
        .padding()
        .frame(width: 600, height: 800)
    }
} 
