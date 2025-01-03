import Foundation
import SwiftUI
import MagicUI
import UniformTypeIdentifiers

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

    /// 是否是 PDF 文件
    var isPDF: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .pdf)
        }
        return pathExtension.lowercased() == "pdf"
    }
    
    /// 是否是文本文件
    var isText: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .text)
        }
        return textExtensions.contains(pathExtension.lowercased())
    }
    
    /// 是否是压缩文件
    var isArchive: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .archive)
        }
        return archiveExtensions.contains(pathExtension.lowercased())
    }

    /// 返回 URL 对应的文件类型标签视图
    var label: Label<Text, Image> {
        if isAudio {
            return Label("Audio", systemImage: icon)
        } else if isVideo {
            return Label("Video", systemImage: icon)
        } else if isImage {
            return Label("Image", systemImage: icon)
        } else if isDirectory {
            return Label("Directory", systemImage: icon)
        } else if isPDF {
            return Label("PDF", systemImage: icon)
        } else if isText {
            return Label("Text", systemImage: icon)
        } else if isArchive {
            return Label("Archive", systemImage: icon)
        } else {
            return Label("Other", systemImage: icon)
        }
    }

    /// 返回 URL 对应的文件类型图标名称
    var icon: String {
        if isAudio {
            return "music.note"
        } else if isVideo {
            return "film"
        } else if isImage {
            return "photo"
        } else if isDirectory {
            return "folder"
        } else if isPDF {
            return "doc.text"
        } else if isText {
            return "doc.text.fill"
        } else if isArchive {
            return "doc.zipper"
        } else {
            return "doc"
        }
    }
}

// MARK: - Supported Extensions

private extension URL {
    /// 支持的音频文件扩展名
    var audioExtensions: Set<String> {
        [
            "mp3", "m4a", "aac", "wav", "aiff", "wma",
            "ogg", "oga", "opus", "flac", "alac",
        ]
    }

    /// 支持的视频文件扩展名
    var videoExtensions: Set<String> {
        [
            "mp4", "m4v", "mov", "avi", "wmv", "flv",
            "mkv", "webm", "3gp", "mpeg", "mpg",
        ]
    }

    /// 支持的图片文件扩展名
    var imageExtensions: Set<String> {
        [
            "jpg", "jpeg", "png", "gif", "bmp", "tiff",
            "webp", "heic", "heif", "raw", "svg",
        ]
    }

    /// 支持的文本文件扩展名
    var textExtensions: Set<String> {
        [
            "txt", "rtf", "md", "json", "xml", "yml",
            "yaml", "swift", "java", "cpp", "c", "h",
            "html", "css", "js", "py", "sh"
        ]
    }
    
    /// 支持的压缩文件扩展名
    var archiveExtensions: Set<String> {
        [
            "zip", "rar", "7z", "tar", "gz", "bz2",
            "xz", "tgz", "tbz"
        ]
    }
}

// MARK: - Preview

struct FileTypeExamplesView: View {
    let examples: [(String, URL)] = [
        // 音频文件
        ("NASA 肯尼迪演讲", URL.sample_mp3_kennedy),
        ("NASA 阿波罗登月", URL.sample_mp3_apollo),
        ("NASA 火箭发射音效", URL.sample_wav_launch),
        ("NASA 太空站音效", URL.sample_wav_iss),
        ("NASA 火星音效", URL.sample_wav_mars),
        
        // 视频文件
        ("Big Buck Bunny", URL.sample_mp4_bunny),
        ("Sintel 预告片", URL.sample_mp4_sintel),
        ("Elephants Dream", URL.sample_mp4_elephants),
        
        // 图片文件
        ("地球 - 蓝色弹珠", URL.sample_jpg_earth),
        ("火星 - 好奇号", URL.sample_jpg_mars),
        ("PNG透明度演示", URL.sample_png_transparency),
        ("RGB渐变演示", URL.sample_png_gradient),
        
        // 流媒体
        ("HLS基础流", URL.sample_stream_basic),
        ("HLS 4K流", URL.sample_stream_4k),
        
        // 其他文件
        ("Swift入门指南", URL.sample_pdf_swift_guide),
        ("SwiftUI文档", URL.sample_pdf_swiftui),
        ("MIT开源协议", URL.sample_txt_mit),
        ("Apache开源协议", URL.sample_txt_apache)
    ]
    
    var body: some View {
        List {
            ForEach(examples, id: \.0) { title, url in
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.headline)
                    
                    url.label
                        .foregroundStyle(.secondary)
                    
                    Text(url.lastPathComponent)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

#Preview {
    FileTypeExamplesView().frame(height: 800)
}
