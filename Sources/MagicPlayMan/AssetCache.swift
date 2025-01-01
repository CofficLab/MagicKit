import Foundation

class AssetCache {
    private let cacheDirectory: URL
    private let fileManager = FileManager.default
    
    /// 创建资源缓存管理器
    /// - Parameter directory: 自定义缓存目录。如果为 nil，则使用系统默认缓存目录下的 MagicPlayMan 文件夹
    init(directory: URL? = nil) throws {
        if let customDirectory = directory {
            cacheDirectory = customDirectory
        } else {
            let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            cacheDirectory = cacheDir.appendingPathComponent("MagicPlayMan", isDirectory: true)
        }
        
        // 确保缓存目录存在
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    /// 获取缓存目录路径
    var directory: URL {
        cacheDirectory
    }
    
    /// 检查资源是否已缓存
    func isCached(_ url: URL) -> Bool {
        let filename = url.lastPathComponent
        let cachedURL = cacheDirectory.appendingPathComponent(filename)
        return fileManager.fileExists(atPath: cachedURL.path)
    }
    
    /// 获取缓存文件的 URL
    func cachedURL(for url: URL) -> URL? {
        let filename = url.lastPathComponent
        let cachedURL = cacheDirectory.appendingPathComponent(filename)
        return fileManager.fileExists(atPath: cachedURL.path) ? cachedURL : nil
    }
    
    /// 缓存数据
    func cache(_ data: Data, for url: URL) throws {
        let filename = url.lastPathComponent
        let cachedURL = cacheDirectory.appendingPathComponent(filename)
        try data.write(to: cachedURL)
    }
    
    /// 清理所有缓存
    func clear() throws {
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        for url in contents {
            try fileManager.removeItem(at: url)
        }
    }
    
    /// 获取缓存大小（字节）
    func size() throws -> UInt64 {
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
        return try contents.reduce(0) { total, url in
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            return total + (attributes[.size] as? UInt64 ?? 0)
        }
    }
} 