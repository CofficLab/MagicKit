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
    
    /// 获取文件的缩略图 CGImage
    /// - Parameter size: 缩略图的目标大小
    /// - Returns: 生成的 CGImage 缩略图
    public func thumbnailCGImage(
        size: CGSize = CGSize(width: 120, height: 120)
    ) async throws -> CGImage? {
        // 如果是网络 URL 或系统图标，返回系统图标
        if isNetworkURL || isiCloud && isNotDownloaded {
            return try await systemIconCGImage(name: icon)
        }
        
        // 检查文件是否存在
        guard FileManager.default.fileExists(atPath: path) else {
            throw URLError(.fileDoesNotExist)
        }
        
        if hasDirectoryPath {
            return try await systemIconCGImage(name: "folder.fill")
        }
        
        if isImage {
            return try await imageCGImage()
        }
        
        if isVideo {
            return try await videoCGImage(size: size)
        }
        
        if isAudio {
            return try await audioCGImage(size: size)
        }
        
        // 默认文档图标
        return try await systemIconCGImage(name: icon)
    }
    
    /// 获取文件的缩略图
    /// - Parameter size: 缩略图的目标大小
    /// - Returns: SwiftUI Image
    public func thumbnail(
        size: CGSize = CGSize(width: 120, height: 120)
    ) async throws -> Image? {
        if let cgImage = try await thumbnailCGImage(size: size) {
            #if os(macOS)
            return Image(nsImage: NSImage(cgImage: cgImage, size: size))
            #else
            return Image(uiImage: UIImage(cgImage: cgImage))
            #endif
        }
        return nil
    }
    
    /// 获取文件的缩略图
    /// - Parameter size: 缩略图的目标大小
    /// - Returns: 平台特定的图片类型 (NSImage/UIImage)
    public func thumbnailPlatformImage(
        size: CGSize = CGSize(width: 120, height: 120)
    ) async throws -> PlatformImage? {
        if let cgImage = try await thumbnailCGImage(size: size) {
            #if os(macOS)
            return NSImage(cgImage: cgImage, size: size)
            #else
            return UIImage(cgImage: cgImage)
            #endif
        }
        return nil
    }
    
    // MARK: - Private Methods
    
    private func systemIconCGImage(name: String) async throws -> CGImage? {
        #if os(macOS)
        return NSImage(systemSymbolName: name, accessibilityDescription: nil)?
            .cgImage(forProposedRect: nil, context: nil, hints: nil)
        #else
        return UIImage(systemName: name)?
            .withTintColor(.systemBlue)
            .cgImage
        #endif
    }
    
    private func imageCGImage() async throws -> CGImage? {
        #if os(macOS)
        guard let image = NSImage(contentsOf: self) else {
            throw URLError(.cannotDecodeContentData)
        }
        return image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        #else
        guard let image = UIImage(contentsOf: self) else {
            throw URLError(.cannotDecodeContentData)
        }
        return image.cgImage
        #endif
    }
    
    private func videoCGImage(size: CGSize) async throws -> CGImage? {
        let asset = AVAsset(url: self)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = size
        
        do {
            return try await imageGenerator.image(at: .zero).image
        } catch {
            os_log(.error, "\(self.lastPathComponent) 生成视频缩略图失败: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func audioCGImage(size: CGSize) async throws -> CGImage? {
        let asset = AVAsset(url: self)
        do {
            let metadata = try await asset.load(.metadata)
            
            // 尝试从元数据中获取封面图片
            for item in metadata {
                // 检查常见的音频封面标签
                if let identifier = item.identifier {
                    let keyString = identifier.rawValue
                    if identifier == .commonIdentifierArtwork || // 通用封面标识符
                       keyString == "APIC" || // ID3 picture tag
                       keyString == "covr" || // iTunes cover art
                       keyString == "©ART" { // Another common artwork key
                        if let imageData = try await item.load(.dataValue),
                           let source = CGImageSourceCreateWithData(imageData as CFData, nil),
                           let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) {
                            return cgImage
                        }
                    }
                }
            }
            
            // 如果没有找到封面图，返回默认音乐图标
            return try await systemIconCGImage(name: "music.note")
        } catch {
            os_log(.error, "读取音频元数据失败: \(error.localizedDescription)")
            return try await systemIconCGImage(name: "music.note")
        }
    }
}

// MARK: - Preview
#Preview("头像视图") {
    AvatarDemoView()
}

