import Foundation
import SwiftUI
import AVFoundation
import OSLog

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
        if hasDirectoryPath {
            return try await folderThumbnail(size: size)
        }
        
        if isImage() {
            return try await imageThumbnail(size: size)
        }
        
        if isVideo {
            return try await videoThumbnail(size: size)
        }
        
        if isAudio {
            return try await audioThumbnail(size: size)
        }
        
        return nil
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
            os_log(.error, "生成视频缩略图失败: \(error.localizedDescription)")
            return nil
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
    VStack(spacing: 20) {
        // 测试文件夹缩略图
        AsyncThumbnailView(
            url: .documentsDirectory,
            title: "文件夹缩略图"
        )
        
        // 测试图片缩略图
        AsyncThumbnailView(
            url: URL(string: "https://picsum.photos/200")!,
            title: "图片缩略图"
        )
        
        // 测试音频缩略图（使用 Apple Music 预览链接）
        AsyncThumbnailView(
            url: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/fd/37/41/fd374113-bf05-692f-e157-5c364af08d9d/mzaf_15384825730917775750.plus.aac.p.m4a")!,
            title: "音频缩略图"
        )
        
        // 测试视频缩略图（使用示例视频）
        AsyncThumbnailView(
            url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
            title: "视频缩略图"
        )
    }
    .padding()
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