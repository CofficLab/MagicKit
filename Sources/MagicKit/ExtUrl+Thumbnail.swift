import Foundation
import SwiftUI
import AVFoundation
import OSLog
import MagicUI
import AVKit

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
            if verbose { os_log("\(self.t)🍽️🍽️🍽️ 从缓存中获取缩略图: \(self.title)") }
            return cachedImage.toSwiftUIImage()
        }
        
        // 生成缩略图
        if let platformImage = try await platformThumbnail(size: size, verbose: verbose) {
            // 存入缓存
            if verbose { os_log("\(self.t)🍽️🍽️🍽️ 缓存缩略图: \(self.title)") }

            var cache = ThumbnailCache.shared
            cache.verbose = verbose
            cache.save(platformImage, for: self, size: size)

            return platformImage.toSwiftUIImage()
        }
        return nil
    }
    
    /// 获取文件的缩略图（原生图片格式）
    /// - Parameters:
    ///   - size: 缩略图的目标大小
    /// - Returns: 生成的缩略图，如果无法生成则返回 nil
    public func platformThumbnail(
        size: CGSize = CGSize(width: 120, height: 120),
        verbose: Bool
    ) async throws -> Image.PlatformImage? {
        // 如果是网络 URL，根据文件类型返回对应图标
        if isNetworkURL {
            return Image.PlatformImage.fromSystemIcon(.iconICloudDownload)
        }
        
        // 如果是 iCloud 文件且未下载，返回下载图标
        if isiCloud && isNotDownloaded {
            return Image.PlatformImage.fromSystemIcon(.iconICloudDownload)
        }
        
        // 检查文件是否存在
        guard self.isFileExist else {
            throw URLError(.fileDoesNotExist)
        }
        
        if hasDirectoryPath {
            return try await platformFolderThumbnail(size: size, verbose: verbose)
        }
        
        if isImage {
            return try await platformImageThumbnail(size: size, verbose: verbose)
        }
        
        if isAudio {
            return try await platformAudioThumbnail(size: size, verbose: verbose)
        }
        
        if isVideo {
            return try await platformVideoThumbnail(size: size, verbose: verbose)
        }
        
        // 如果无法识别类型，返回默认文档图标
        return Image.PlatformImage.fromSystemIcon(icon)
    }
    
    /// 获取缩略图缓存目录
    /// - Returns: 缩略图缓存目录的 URL
    public static func thumbnailCacheDirectory() -> URL {
        return ThumbnailCache.shared.getCacheDirectory()
    }
    
    // MARK: - Private Platform Image Methods
    
    private func platformFolderThumbnail(size: CGSize, verbose: Bool) async throws -> Image.PlatformImage? {
        return Image.PlatformImage.folderIcon(size: size)
    }
    
    private func platformImageThumbnail(size: CGSize, verbose: Bool) async throws -> Image.PlatformImage? {
        guard let image = Image.PlatformImage.fromFile(self) else {
            throw URLError(.cannotDecodeContentData)
        }
        return image.resize(to: size, quality: .high)
    }
    
    private func platformVideoThumbnail(size: CGSize, verbose: Bool) async throws -> Image.PlatformImage? {
        let asset = AVAsset(url: self)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = size
        
        do {
            let cgImage = try await imageGenerator.image(at: .zero).image
            return Image.PlatformImage.fromCGImage(cgImage, size: size)
        } catch {
            os_log(.error, "\(self.lastPathComponent) 生成视频缩略图失败: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func platformAudioThumbnail(size: CGSize, verbose: Bool) async throws -> Image.PlatformImage? {
        // 尝试从音频元数据中获取封面
        if let coverImage = try await getPlatformCoverFromMetadata(verbose: verbose) {
            return coverImage.resize(to: size)
        }
        
        // 如果没有找到封面，返回默认音频图标
        return Image.PlatformImage.defaultAudioIcon
    }
    
    /// 从音频文件的元数据中获取封面图片（原生图片格式）
    private func getPlatformCoverFromMetadata(verbose: Bool) async throws -> Image.PlatformImage? {
        if verbose {
            os_log("\(self.t)🍽️🍽️🍽️ 从音频文件的元数据中获取封面图片: \(self.title)")
        }

        let asset = AVURLAsset(url: self)
        
        // Try multiple metadata keys that might contain artwork
        let artworkKeys = [
            AVMetadataKey.commonKeyArtwork,
            AVMetadataKey.id3MetadataKeyAttachedPicture,
            AVMetadataKey.iTunesMetadataKeyCoverArt
        ]
        
        let commonMetadata = try await asset.load(.commonMetadata)
        
        // Try each artwork key
        for key in artworkKeys {
            if verbose {
                os_log("\(self.t)🍽️🍽️🍽️ 尝试从音频文件的元数据中获取封面图片: \(key.rawValue)")
            }

            let artworkItems = AVMetadataItem.metadataItems(
                from: commonMetadata,
                withKey: key,
                keySpace: AVMetadataKeySpace.common
            )
            
            if let artworkItem = artworkItems.first {
                do {
                    if let artworkData = try await artworkItem.load(.value) as? Data {
                        if let image = Image.PlatformImage.fromCacheData(artworkData) {
                            return image
                        }
                    } else if let artworkImage = try await artworkItem.load(.value) as? Image.PlatformImage {
                        return artworkImage
                    }
                } catch {
                    os_log(.error, "Failed to load artwork for key \(key.rawValue): \(error.localizedDescription)")
                    continue // Try next key if this one fails
                }
            }
        }
        
        return nil
    }
}

// MARK: - Preview
#Preview("头像视图") {
    AvatarDemoView()
}

