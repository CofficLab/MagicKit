import Foundation
import SwiftUI
import AVFoundation
import OSLog
import MagicUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

extension URL {
    /// 获取文件的缩略图
    /// - Parameters:
    ///   - size: 缩略图的目标大小
    /// - Returns: 生成的缩略图，如果无法生成则返回 nil
    public func thumbnail(
        size: CGSize = CGSize(width: 120, height: 120)
    ) async throws -> Image? {
        // 如果是 iCloud 文件且未下载，返回特殊的缩略图
        if isiCloud && isNotDownloaded {
            return makeICloudThumbnail(size: size)
        }
        
        if hasDirectoryPath {
            return try await folderThumbnail(size: size)
        }
        
        if isImage {
            return try await imageThumbnail(size: size)
        }
        
        if isAudio {
            return try await audioThumbnail(size: size)
        }
        
        if isVideo {
            return try await videoThumbnail(size: size)
        }
        
        return nil
    }
    
    // MARK: - iCloud Thumbnail
    
    private func makeICloudThumbnail(size: CGSize) -> Image? {
        let format = fileFormat
        
        #if os(macOS)
        let baseIcon = NSImage(systemSymbolName: format.iconName, accessibilityDescription: nil)
        let cloudIcon = NSImage(systemSymbolName: "icloud", accessibilityDescription: nil)
        let arrowIcon = NSImage(systemSymbolName: "arrow.down.circle", accessibilityDescription: nil)
        
        guard let combined = combineIcons(
            base: baseIcon,
            cloud: cloudIcon,
            arrow: arrowIcon,
            size: size
        ) else { return nil }
        
        return Image(nsImage: combined)
        #else
        let baseIcon = UIImage(systemName: format.iconName)?.withTintColor(format.color)
        let cloudIcon = UIImage(systemName: "icloud")?.withTintColor(.systemBlue)
        let arrowIcon = UIImage(systemName: "arrow.down.circle")?.withTintColor(.systemBlue)
        
        guard let combined = combineIcons(
            base: baseIcon,
            cloud: cloudIcon,
            arrow: arrowIcon,
            size: size
        ) else { return nil }
        
        return Image(uiImage: combined)
        #endif
    }
    
    #if os(macOS)
    private func combineIcons(
        base: NSImage?,
        cloud: NSImage?,
        arrow: NSImage?,
        size: CGSize
    ) -> NSImage? {
        guard let base = base,
              let cloud = cloud,
              let arrow = arrow else { return nil }
        
        let result = NSImage(size: size)
        result.lockFocus()
        
        // 绘制主图标
        base.draw(in: CGRect(origin: .zero, size: size))
        
        // 绘制云图标（右上角）
        let cloudSize = CGSize(width: size.width * 0.4, height: size.height * 0.4)
        let cloudPoint = CGPoint(x: size.width - cloudSize.width, y: size.height - cloudSize.height)
        cloud.draw(in: CGRect(origin: cloudPoint, size: cloudSize))
        
        // 绘制下载箭头（左下角）
        let arrowSize = CGSize(width: size.width * 0.4, height: size.height * 0.4)
        let arrowPoint = CGPoint(x: 0, y: 0)
        arrow.draw(in: CGRect(origin: arrowPoint, size: arrowSize))
        
        result.unlockFocus()
        return result
    }
    #else
    private func combineIcons(
        base: UIImage?,
        cloud: UIImage?,
        arrow: UIImage?,
        size: CGSize
    ) -> UIImage? {
        guard let base = base,
              let cloud = cloud,
              let arrow = arrow else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        // 绘制主图标
        base.draw(in: CGRect(origin: .zero, size: size))
        
        // 绘制云图标（右上角）
        let cloudSize = CGSize(width: size.width * 0.4, height: size.height * 0.4)
        let cloudPoint = CGPoint(x: size.width - cloudSize.width, y: size.height - cloudSize.height)
        cloud.draw(in: CGRect(origin: cloudPoint, size: cloudSize))
        
        // 绘制下载箭头（左下角）
        let arrowSize = CGSize(width: size.width * 0.4, height: size.height * 0.4)
        let arrowPoint = CGPoint(x: 0, y: 0)
        arrow.draw(in: CGRect(origin: arrowPoint, size: arrowSize))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    #endif
    
    // MARK: - File Format
    
    private var fileFormat: FileFormat {
        let ext = pathExtension.lowercased()
        switch ext {
        case "mp3", "wav", "aac", "m4a":
            return FileFormat(iconName: "music.note", color: .systemPurple)
        case "mp4", "mov", "m4v":
            return FileFormat(iconName: "film", color: .systemBlue)
        case "jpg", "jpeg", "png", "gif":
            return FileFormat(iconName: "photo", color: .systemGreen)
        case "pdf":
            return FileFormat(iconName: "doc.text", color: .systemRed)
        case "txt", "rtf":
            return FileFormat(iconName: "doc.text", color: .systemGray)
        default:
            return FileFormat(iconName: "doc", color: .systemGray)
        }
    }
    
    private struct FileFormat {
        let iconName: String
        let color: PlatformColor
        
        #if os(macOS)
        typealias PlatformColor = NSColor
        #else
        typealias PlatformColor = UIColor
        #endif
    }
    
    // MARK: - Private Methods
    
    private func folderThumbnail(size: CGSize) async throws -> Image? {
        #if os(macOS)
        if let folderIcon = NSImage(systemSymbolName: "folder.fill", accessibilityDescription: nil) {
            let resizedIcon = folderIcon.resize(to: size)
            return Image(nsImage: resizedIcon)
        }
        if let defaultIcon = NSImage(systemSymbolName: "folder", accessibilityDescription: nil) {
            return Image(nsImage: defaultIcon)
        }
        #else
        if let folderIcon = UIImage(systemName: "folder.fill")?.withTintColor(.systemBlue) {
            let resizedIcon = folderIcon.resize(to: size)
            return Image(uiImage: resizedIcon)
        }
        if let defaultIcon = UIImage(systemName: "folder")?.withTintColor(.systemBlue) {
            return Image(uiImage: defaultIcon)
        }
        #endif
        return nil
    }
    
    private func imageThumbnail(size: CGSize) async throws -> Image? {
        #if os(macOS)
        if let image = NSImage(contentsOf: self) {
            let resizedImage = image.resize(to: size)
            return Image(nsImage: resizedImage)
        }
        #else
        if let image = UIImage(contentsOf: self) {
            let resizedImage = image.resize(to: size)
            return Image(uiImage: resizedImage)
        }
        #endif
        return nil
    }
    
    private func videoThumbnail(size: CGSize) async throws -> Image? {
        let asset = AVAsset(url: self)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = size
        
        do {
            let cgImage = try await imageGenerator.image(at: .zero).image
            #if os(macOS)
            let image = NSImage(cgImage: cgImage, size: size)
            return Image(nsImage: image)
            #else
            let image = UIImage(cgImage: cgImage)
            return Image(uiImage: image)
            #endif
        } catch {
            os_log(.error, "\(self.t)生成视频缩略图失败: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func audioThumbnail(size: CGSize) async throws -> Image? {
        let asset = AVAsset(url: self)
        do {
            let metadata = try await asset.load(.metadata)
            
            // 尝试从元数据中获取封面图片
            for item in metadata {
                let keyString = item.key as? String
                if item.identifier == AVMetadataIdentifier.commonIdentifierArtwork ||
                    keyString == "APIC" || // ID3 picture tag
                    keyString == "covr" || // iTunes cover art
                    keyString == "©ART" { // Another common artwork key
                    if let data = try await item.load(.dataValue) {
                        #if os(macOS)
                        if let image = NSImage(data: data) {
                            let resizedImage = image.resize(to: size)
                            return Image(nsImage: resizedImage)
                        }
                        #else
                        if let image = UIImage(data: data) {
                            let resizedImage = image.resize(to: size)
                            return Image(uiImage: resizedImage)
                        }
                        #endif
                    }
                }
            }
            
            // 如果没有找到封面图，返回默认音乐图标
            return defaultAudioThumbnail(size: size)
        } catch {
            os_log(.error, "读取音频元数据失败: \(error.localizedDescription)")
            return defaultAudioThumbnail(size: size)
        }
    }
}

// MARK: - Preview

#Preview("Thumbnails") {
    ScrollView {
        VStack(spacing: 20) {
            Group {
                // 文件夹
                AsyncThumbnailView(
                    url: .documentsDirectory,
                    title: "文件夹缩略图"
                )
                
                // 图片文件
                AsyncThumbnailView(
                    url: .sample_jpg_earth,
                    title: "NASA 地球照片"
                )
                AsyncThumbnailView(
                    url: .sample_jpg_mars,
                    title: "NASA 火星照片"
                )
                AsyncThumbnailView(
                    url: .sample_png_transparency,
                    title: "PNG 透明度演示"
                )
                AsyncThumbnailView(
                    url: .sample_png_gradient,
                    title: "RGB 渐变演示"
                )
            }
            
            Group {
                // 音频文件
                AsyncThumbnailView(
                    url: .sample_mp3_kennedy,
                    title: "肯尼迪演讲"
                )
                AsyncThumbnailView(
                    url: .sample_wav_mars,
                    title: "火星音效"
                )
                AsyncThumbnailView(
                    url: .sample_mp3_apollo,
                    title: "阿波罗登月"
                )
            }
            
            Group {
                // 视频文件
                AsyncThumbnailView(
                    url: .sample_mp4_bunny,
                    title: "Big Buck Bunny"
                )
                AsyncThumbnailView(
                    url: .sample_mp4_sintel,
                    title: "Sintel 预告片"
                )
                AsyncThumbnailView(
                    url: .sample_mp4_elephants,
                    title: "Elephants Dream"
                )
            }
            
            Group {
                // PDF 文件
                AsyncThumbnailView(
                    url: .sample_pdf_swift_guide,
                    title: "Swift 入门指南"
                )
                AsyncThumbnailView(
                    url: .sample_pdf_swiftui,
                    title: "SwiftUI 文档"
                )
            }
            
            Group {
                // 文本文件
                AsyncThumbnailView(
                    url: .sample_txt_mit,
                    title: "MIT 开源协议"
                )
                AsyncThumbnailView(
                    url: .sample_txt_apache,
                    title: "Apache 开源协议"
                )
            }
            
            Group {
                // 临时文件测试
                AsyncThumbnailView(
                    url: .sample_temp_mp3,
                    title: "临时音频文件"
                )
                AsyncThumbnailView(
                    url: .sample_temp_txt,
                    title: "临时文本文件"
                )
                AsyncThumbnailView(
                    url: .sample_temp_pdf,
                    title: "临时 PDF 文件"
                )
            }
        }
        .padding()
    }
    .frame(width: 500, height: 600)
    .background(MagicBackground.mint)
}

private struct AsyncThumbnailView: View {
    let url: URL
    let title: String
    @State private var thumbnail: Image?
    @State private var error: Error?
    
    var body: some View {
        HStack {
            Group {
                if let thumbnail = thumbnail {
                    thumbnail
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if error != nil {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 60, height: 60)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                if let error {
                    Text(error.localizedDescription)
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
            }
        }
        .task {
            do {
                thumbnail = try await url.thumbnail(size: CGSize(width: 120, height: 120))
            } catch {
                self.error = error
            }
        }
    }
} 
