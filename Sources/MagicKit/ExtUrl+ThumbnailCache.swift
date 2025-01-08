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
    private let memoryCache = NSCache<NSURL, Image.PlatformImage>()
    
    /// 磁盘缓存目录
    private let diskCacheURL: URL
    
    /// 缓存配置
    private struct Config {
        static let maxMemoryCount = 100  // 最大内存缓存数量
        static let maxMemorySize = 50 * 1024 * 1024  // 最大内存占用(50MB)
        static let maxDiskSize = 200 * 1024 * 1024  // 最大磁盘占用(200MB)
        static let cleanupThreshold = 0.8  // 清理阈值(80%)
    }
    
    private init() {
        memoryCache.countLimit = Config.maxMemoryCount
        memoryCache.totalCostLimit = Config.maxMemorySize
        
        // 创建磁盘缓存目录
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheURL = cacheDirectory.appendingPathComponent("ThumbnailCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
        
        // 定期检查并清理过期缓存
        startCacheCleanupTimer()
    }
    
    /// 启动定期清理计时器
    private func startCacheCleanupTimer() {
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task {
                await self?.cleanupCacheIfNeeded()
            }
        }
    }
    
    /// 根据需要清理缓存
    private func cleanupCacheIfNeeded() async {
        do {
            let currentSize = try getCacheSize()
            if currentSize > Int64(Double(Config.maxDiskSize) * Config.cleanupThreshold) {
                try await cleanupOldCache()
            }
        } catch {
            os_log(.error, "检查缓存大小失败: \(error.localizedDescription)")
        }
    }
    
    /// 清理旧缓存
    private func cleanupOldCache() async throws {
        let fileManager = FileManager.default
        let resourceKeys: Set<URLResourceKey> = [.contentModificationDateKey, .totalFileAllocatedSizeKey]
        
        // 获取所有缓存文件信息
        let fileURLs = try fileManager.contentsOfDirectory(at: diskCacheURL, includingPropertiesForKeys: Array(resourceKeys))
        
        // 按修改时间排序
        let sortedFiles = try fileURLs.map { url -> (URL, Date) in
            let resourceValues = try url.resourceValues(forKeys: resourceKeys)
            return (url, resourceValues.contentModificationDate ?? Date.distantPast)
        }.sorted { $0.1 < $1.1 }
        
        // 删除最旧的文件直到低于阈值
        var currentSize = try getCacheSize()
        let targetSize = Int64(Double(Config.maxDiskSize) * 0.5) // 清理到50%
        
        for (fileURL, _) in sortedFiles {
            if currentSize <= targetSize { break }
            
            if let size = try? fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize {
                try? fileManager.removeItem(at: fileURL)
                currentSize -= Int64(size)
            }
        }
    }
    
    /// 缓存键生成
    private func cacheKey(for url: URL, size: CGSize) -> String {
        #if os(macOS)
        let fileExtension = "tiff"
        #else
        let fileExtension = "png"
        #endif
        return "\(url.lastPathComponent)_\(Int(size.width))x\(Int(size.height)).\(fileExtension)"
    }
    
    /// 获取缓存
    public func fetch(for url: URL, size: CGSize) -> Image.PlatformImage? {
        let key = cacheKey(for: url, size: size)
        
        // 1. 检查内存缓存
        if let cachedImage = memoryCache.object(forKey: url as NSURL) {
            return cachedImage
        }
        
        // 2. 检查磁盘缓存
        let diskURL = diskCacheURL.appendingPathComponent(key)
        guard let data = try? Data(contentsOf: diskURL),
              let image = Image.PlatformImage.fromCacheData(data) else {
            return nil
        }
        
        // 找到磁盘缓存后，也放入内存缓存
        memoryCache.setObject(image, forKey: url as NSURL)
        return image
    }
    
    /// 保存缓存
    public func save(_ image: Image.PlatformImage, for url: URL, size: CGSize) {
        let key = cacheKey(for: url, size: size)
        
        // 1. 保存到内存缓存
        memoryCache.setObject(image, forKey: url as NSURL)
        
        // 2. 保存到磁盘缓存
        let diskURL = diskCacheURL.appendingPathComponent(key)
        
        guard let data = image.cacheData else { return }
        
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
