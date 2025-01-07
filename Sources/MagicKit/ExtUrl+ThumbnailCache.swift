import Foundation
import OSLog
import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// 缩略图缓存管理器
public class ThumbnailCache {
    /// 单例
    public static let shared = ThumbnailCache()
    
    /// 内存缓存
    private let memoryCache = NSCache<NSURL, PlatformImage>()
    
    /// 磁盘缓存目录
    private let diskCacheURL: URL
    
    private init() {
        // 设置内存缓存限制
        memoryCache.countLimit = 100 // 最多缓存100张图片
        memoryCache.totalCostLimit = 1024 * 1024 * 50 // 50MB
        
        // 创建磁盘缓存目录
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheURL = cacheDirectory.appendingPathComponent("ThumbnailCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }
    
    /// 缓存键生成
    private func cacheKey(for url: URL, size: CGSize) -> String {
        "\(url.lastPathComponent)_\(Int(size.width))x\(Int(size.height))"
    }
    
    /// 获取缓存
    public func fetch(for url: URL, size: CGSize) -> PlatformImage? {
        let key = cacheKey(for: url, size: size)
        
        // 1. 检查内存缓存
        if let cachedImage = memoryCache.object(forKey: url as NSURL) {
            return cachedImage
        }
        
        // 2. 检查磁盘缓存
        let diskURL = diskCacheURL.appendingPathComponent(key)
        guard let data = try? Data(contentsOf: diskURL) else {
            return nil
        }
        
        #if os(macOS)
        guard let image = NSImage(data: data) else { return nil }
        #else
        guard let image = UIImage(data: data) else { return nil }
        #endif
        
        // 找到磁盘缓存后，也放入内存缓存
        memoryCache.setObject(image, forKey: url as NSURL)
        return image
    }
    
    /// 保存缓存
    public func save(_ image: PlatformImage, for url: URL, size: CGSize) {
        let key = cacheKey(for: url, size: size)
        
        // 1. 保存到内存缓存
        memoryCache.setObject(image, forKey: url as NSURL)
        
        // 2. 保存到磁盘缓存
        let diskURL = diskCacheURL.appendingPathComponent(key)
        
        #if os(macOS)
        guard let data = image.tiffRepresentation else { return }
        #else
        guard let data = image.pngData() else { return }
        #endif
        
        do {
            try data.write(to: diskURL)
        } catch {
            os_log(.error, "缓存缩略图失败: \(error.localizedDescription)")
        }
    }
    
    /// 清理缓存
    public func clearCache() {
        // 清理内存缓存
        memoryCache.removeAllObjects()
        
        // 清理磁盘缓存
        try? FileManager.default.removeItem(at: diskCacheURL)
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }
    
    /// 获取缓存大小
    public func getCacheSize() throws -> Int64 {
        let resourceKeys = Set<URLResourceKey>([.totalFileAllocatedSizeKey])
        guard let enumerator = FileManager.default.enumerator(at: diskCacheURL,
                                                            includingPropertiesForKeys: Array(resourceKeys)) else {
            throw URLError(.cannotOpenFile)
        }
        
        var size: Int64 = 0
        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                  let fileSize = resourceValues.totalFileAllocatedSize else {
                continue
            }
            size += Int64(fileSize)
        }
        return size
    }
    
    /// 获取缩略图缓存目录
    /// - Returns: 缓存目录的 URL
    public func getCacheDirectory() -> URL {
        return diskCacheURL
    }
} 

// MARK: - Preview
#Preview("头像视图") {
    AvatarDemoView()
}
