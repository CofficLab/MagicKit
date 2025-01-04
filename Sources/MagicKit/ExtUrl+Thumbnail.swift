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
    /// 检查是否是网络 URL
    public var isNetworkURL: Bool {
        scheme == "http" || scheme == "https"
    }
    
    /// 获取文件的缩略图
    /// - Parameters:
    ///   - size: 缩略图的目标大小
    /// - Returns: 生成的缩略图，如果无法生成则返回 nil
    public func thumbnail(
        size: CGSize = CGSize(width: 120, height: 120)
    ) async throws -> Image? {
        // 如果是网络 URL，根据文件类型返回对应图标
        if isNetworkURL {
            return Image(systemName: icon)
        }
        
        // 如果是 iCloud 文件且未下载，返回下载图标
        if isiCloud && isNotDownloaded {
            return Image(systemName: "arrow.down.circle.dotted")
        }
        
        // 检查文件是否存在
        guard FileManager.default.fileExists(atPath: path) else {
            throw URLError(.fileDoesNotExist)
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
        
        // 如果无法识别类型，返回默认文档图标
        return Image(systemName: icon)
    }
    
    // MARK: - Private Methods
    
    private func folderThumbnail(size: CGSize) async throws -> Image? {
        #if os(macOS)
        if let folderIcon = NSImage(systemSymbolName: "folder.fill", accessibilityDescription: nil) {
            let resizedIcon = folderIcon.resize(to: size)
            return Image(nsImage: resizedIcon)
        }
        return Image(systemName: "folder")
        #else
        if let folderIcon = UIImage(systemName: "folder.fill")?.withTintColor(.systemBlue) {
            let resizedIcon = folderIcon.resize(to: size)
            return Image(uiImage: resizedIcon)
        }
        return Image(systemName: "folder")
        #endif
    }
    
    private func imageThumbnail(size: CGSize) async throws -> Image? {
        #if os(macOS)
        guard let image = NSImage(contentsOf: self) else {
            throw URLError(.cannotDecodeContentData)
        }
        let resizedImage = image.resize(to: size)
        return Image(nsImage: resizedImage)
        #else
        guard let image = UIImage(contentsOf: self) else {
            throw URLError(.cannotDecodeContentData)
        }
        let resizedImage = image.resize(to: size)
        return Image(uiImage: resizedImage)
        #endif
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
            os_log(.error, "\(self.lastPathComponent) 生成视频缩略图失败: \(error.localizedDescription)")
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
#Preview("头像视图") {
    AvatarDemoView()
}

