import Foundation
import SwiftUI
import AVFoundation
import OSLog
import MagicUI
import AVKit

#if os(macOS)
    import AppKit
    public typealias PlatformImage = NSImage
#else
    import UIKit
    public typealias PlatformImage = UIImage
#endif

extension URL {
    /// 获取文件的缩略图
    /// - Parameters:
    ///   - size: 缩略图的目标大小
    /// - Returns: 生成的缩略图，如果无法生成则返回 nil
    public func thumbnail(
        size: CGSize = CGSize(width: 120, height: 120),
        verbose: Bool
    ) async throws -> Image? {
        // 检查缓存
        if let cachedImage = ThumbnailCache.shared.fetch(for: self, size: size) {
            if verbose { os_log("\(self.t)从缓存中获取缩略图: \(self.title)") }
            #if os(macOS)
            return Image(nsImage: cachedImage)
            #else
            return Image(uiImage: cachedImage)
            #endif
        }
        
        // 生成缩略图
        if let platformImage = try await platformThumbnail(size: size) {
            // 存入缓存
            if verbose { os_log("\(self.t)缓存缩略图: \(self.title)") }
            ThumbnailCache.shared.save(platformImage, for: self, size: size)
            #if os(macOS)
            return Image(nsImage: platformImage)
            #else
            return Image(uiImage: platformImage)
            #endif
        }
        return nil
    }
    
    /// 获取文件的缩略图（原生图片格式）
    /// - Parameters:
    ///   - size: 缩略图的目标大小
    /// - Returns: 生成的缩略图，如果无法生成则返回 nil
    public func platformThumbnail(
        size: CGSize = CGSize(width: 120, height: 120)
    ) async throws -> PlatformImage? {
        // 如果是网络 URL，根据文件类型返回对应图标
        if isNetworkURL {
            #if os(macOS)
            return NSImage(systemSymbolName: icon, accessibilityDescription: nil)
            #else
            return UIImage(systemName: icon)
            #endif
        }
        
        // 如果是 iCloud 文件且未下载，返回下载图标
        if isiCloud && isNotDownloaded {
            #if os(macOS)
            return NSImage(systemSymbolName: "arrow.down.circle.dotted", accessibilityDescription: nil)
            #else
            return UIImage(systemName: "arrow.down.circle.dotted")
            #endif
        }
        
        // 检查文件是否存在
        guard self.isFileExist else {
            throw URLError(.fileDoesNotExist)
        }
        
        if hasDirectoryPath {
            return try await platformFolderThumbnail(size: size)
        }
        
        if isImage {
            return try await platformImageThumbnail(size: size)
        }
        
        if isAudio {
            return try await platformAudioThumbnail(size: size)
        }
        
        if isVideo {
            return try await platformVideoThumbnail(size: size)
        }
        
        // 如果无法识别类型，返回默认文档图标
        #if os(macOS)
        return NSImage(systemSymbolName: icon, accessibilityDescription: nil)
        #else
        return UIImage(systemName: icon)
        #endif
    }
    
    /// 获取缩略图缓存目录
    /// - Returns: 缩略图缓存目录的 URL
    public static func thumbnailCacheDirectory() -> URL {
        return ThumbnailCache.shared.getCacheDirectory()
    }
    
    // MARK: - Private Platform Image Methods
    
    private func platformFolderThumbnail(size: CGSize) async throws -> PlatformImage? {
        #if os(macOS)
        if let folderIcon = NSImage(systemSymbolName: "folder.fill", accessibilityDescription: nil) {
            return folderIcon.resize(to: size)
        }
        return NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
        #else
        if let folderIcon = UIImage(systemName: "folder.fill")?.withTintColor(.systemBlue) {
            return folderIcon.resize(to: size)
        }
        return UIImage(systemName: "folder")
        #endif
    }
    
    private func platformImageThumbnail(size: CGSize) async throws -> PlatformImage? {
        #if os(macOS)
        guard let image = NSImage(contentsOf: self) else {
            throw URLError(.cannotDecodeContentData)
        }
        return image.resize(to: size)
        #else
        guard let image = UIImage(contentsOf: self) else {
            throw URLError(.cannotDecodeContentData)
        }
        return image.resize(to: size)
        #endif
    }
    
    private func platformVideoThumbnail(size: CGSize) async throws -> PlatformImage? {
        let asset = AVAsset(url: self)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = size
        
        do {
            let cgImage = try await imageGenerator.image(at: .zero).image
            #if os(macOS)
            return NSImage(cgImage: cgImage, size: size)
            #else
            return UIImage(cgImage: cgImage)
            #endif
        } catch {
            os_log(.error, "\(self.lastPathComponent) 生成视频缩略图失败: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func platformAudioThumbnail(size: CGSize) async throws -> PlatformImage? {
        // 尝试从音频元数据中获取封面
        if let coverImage = try await getPlatformCoverFromMetadata() {
            // 添加 resize 操作
            return coverImage.resize(to: size)
        }
        
        // 如果没有找到封面，返回默认音频图标
        #if os(macOS)
        return NSImage(systemSymbolName: "music.note", accessibilityDescription: nil)
        #else
        return UIImage(systemName: "music.note")
        #endif
    }
    
    /// 从音频文件的元数据中获取封面图片（原生图片格式）
    private func getPlatformCoverFromMetadata() async throws -> PlatformImage? {
        let asset = AVURLAsset(url: self)
        let commonMetadata = try await asset.load(.commonMetadata)
        let artworkItems = AVMetadataItem.metadataItems(
            from: commonMetadata,
            withKey: AVMetadataKey.commonKeyArtwork,
            keySpace: .common
        )
        
        if let artworkItem = artworkItems.first {
            if let artworkData = try await artworkItem.load(.value) as? Data {
                #if os(macOS)
                return NSImage(data: artworkData)
                #else
                return UIImage(data: artworkData)
                #endif
            } else if let artworkImage = try await artworkItem.load(.value) as? PlatformImage {
                return artworkImage
            }
        }
        
        return nil
    }
}

// MARK: - Preview
#Preview("头像视图") {
    AvatarDemoView()
}

