import Foundation
import UniformTypeIdentifiers
import SwiftUI

public extension URL {
    /// 是否是音频文件
    var isAudio: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .audio)
        }
        return audioExtensions.contains(pathExtension.lowercased())
    }
    
    /// 是否是视频文件
    var isVideo: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .audiovisualContent)
        }
        return videoExtensions.contains(pathExtension.lowercased())
    }
    
    /// 是否是图片文件
    var isImage: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .image)
        }
        return imageExtensions.contains(pathExtension.lowercased())
    }
    
    /// 是否是文件夹
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    /// 是否是媒体文件（音频或视频）
    var isMedia: Bool {
        isAudio || isVideo
    }
    
    /// 是否是本地文件
    var isLocalFile: Bool {
        isFileURL && FileManager.default.fileExists(atPath: path)
    }
    
    /// 是否是流媒体 URL
    var isStreamingURL: Bool {
        scheme == "http" || scheme == "https"
    }
}

// MARK: - Supported Extensions
private extension URL {
    /// 支持的音频文件扩展名
    var audioExtensions: Set<String> {
        [
            "mp3", "m4a", "aac", "wav", "aiff", "wma",
            "ogg", "oga", "opus", "flac", "alac"
        ]
    }
    
    /// 支持的视频文件扩展名
    var videoExtensions: Set<String> {
        [
            "mp4", "m4v", "mov", "avi", "wmv", "flv",
            "mkv", "webm", "3gp", "mpeg", "mpg"
        ]
    }
    
    /// 支持的图片文件扩展名
    var imageExtensions: Set<String> {
        [
            "jpg", "jpeg", "png", "gif", "bmp", "tiff",
            "webp", "heic", "heif", "raw", "svg"
        ]
    }
}

// MARK: - Preview
#Preview("URL Type Tests") {
    URLTypeTestView()
}

private struct URLTypeTestView: View {
    let testURLs = [
        // 音频
        URL(string: "https://example.com/song.mp3")!,
        URL(string: "file:///music/track.m4a")!,
        // 视频
        URL(string: "https://example.com/movie.mp4")!,
        URL(string: "file:///videos/clip.mov")!,
        // 图片
        URL(string: "https://example.com/photo.jpg")!,
        URL(string: "file:///images/icon.png")!,
        // 其他
        URL(string: "https://example.com/document.pdf")!,
        URL.documentsDirectory
    ]
    
    var body: some View {
        List(testURLs, id: \.absoluteString) { url in
            VStack(alignment: .leading, spacing: 4) {
                Text(url.lastPathComponent)
                    .font(.headline)
                
                Group {
                    if url.isAudio {
                        Label("Audio", systemImage: "music.note")
                    } else if url.isVideo {
                        Label("Video", systemImage: "film")
                    } else if url.isImage {
                        Label("Image", systemImage: "photo")
                    } else if url.isDirectory {
                        Label("Directory", systemImage: "folder")
                    } else {
                        Label("Other", systemImage: "doc")
                    }
                }
                .foregroundStyle(.secondary)
                
                Text(url.absoluteString)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
        }
    }
} 
