import Foundation
import OSLog

/// 元数据项集合，用于管理和分类 iCloud 文件的元数据
public struct MetadataItemCollection: Sendable {
    /// 通知名称，用于标识此集合的更新类型
    public var name: Notification.Name
    /// 是否已更新
    public var isUpdated = false
    /// 元数据项列表
    public var items: [MetaWrapper] = []
    
    /// 集合中的项目数量
    public var count: Int {
        items.count
    }
    
    /// 第一个元数据项
    public var first: MetaWrapper? {
        items.first
    }
    
    /// 需要同步的项目（未更新的项目）
    public var itemsForSync: [MetaWrapper] {
        items.filter { $0.isUpdated == false }
    }
    
    /// 需要更新的项目（已更新且未删除的项目）
    public var itemsForUpdate: [MetaWrapper] {
        items.filter { $0.isUpdated && $0.isDeleted == false }
    }
    
    /// 需要删除的项目
    public var itemsForDelete: [MetaWrapper] {
        items.filter { $0.isDeleted }
    }
}

/// iCloud 文件元数据包装器，提供文件状态和属性的访问
public struct MetaWrapper: Sendable {
    static var label = "📁 MetaWrapper::"
    
    /// 文件名
    public let fileName: String?
    /// 文件大小（字节）
    public let fileSize: Int64?
    /// 文件内容类型（UTI）
    public let contentType: String?
    /// 是否为目录
    public let isDirectory: Bool
    /// 文件 URL
    public let url: URL?
    /// 是否为占位文件（未完全下载的文件）
    public let isPlaceholder: Bool
    /// 是否已删除
    public let isDeleted: Bool
    /// 是否已更新
    public let isUpdated: Bool
    /// 下载进度（0-1）
    public let downloadProgress: Double
    /// 是否已上传完成
    public let uploaded: Bool
    /// 标识符键（预留）
    public let identifierKey: String? = nil
    
    /// 文件是否已下载完成
    public var isDownloaded: Bool {
        downloadProgress >= 0.999 || isPlaceholder == false
    }
    
    /// 文件是否正在下载
    /// 当文件是占位文件且下载进度大于0且小于1时，表示正在下载
    public var isDownloading: Bool {
        isPlaceholder && downloadProgress > 0.0 && downloadProgress < 0.999
    }
    
    public var label: String { "\(Self.label)" }

    /// 从 NSMetadataItem 创建元数据包装器
    /// - Parameters:
    ///   - metadataItem: 系统元数据项
    ///   - isDeleted: 是否已删除
    ///   - isUpdated: 是否已更新
    ///   - verbose: 是否输出详细日志
    public init(metadataItem: NSMetadataItem, isDeleted: Bool = false, isUpdated: Bool = false, verbose: Bool = false) {
        // MARK: FileName
        
        let fileName: String? = metadataItem.value(forAttribute: NSMetadataItemFSNameKey) as? String
        
        // MARK: PlaceHolder
        
        var isPlaceholder: Bool = false
        if let downloadingStatus = metadataItem.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String {
            if downloadingStatus == NSMetadataUbiquitousItemDownloadingStatusNotDownloaded {
                // 文件是占位文件
                isPlaceholder = true
            } else if downloadingStatus == NSMetadataUbiquitousItemDownloadingStatusDownloaded || downloadingStatus == NSMetadataUbiquitousItemDownloadingStatusCurrent {
                // 文件已下载或是最新的
                isPlaceholder = false
            } else {
                isPlaceholder = false
            }
        }
        
        // MARK: DownloadProgress
        
        // 将系统返回的 0-100 的进度值转换为 0-1
        let downloadProgress = (metadataItem.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double ?? 0.0) / 100.0
        
        // MARK: FileSize
        
        let fileSize = metadataItem.value(forAttribute: NSMetadataItemFSSizeKey) as? Int64
        
        self.fileName = fileName
        self.isPlaceholder = isPlaceholder
        self.isDeleted = isDeleted
        self.isUpdated = isUpdated
        self.fileSize = fileSize
        self.contentType = metadataItem.value(forAttribute: NSMetadataItemContentTypeKey) as? String
        self.isDirectory = (self.contentType == "public.folder")
        self.url = metadataItem.value(forAttribute: NSMetadataItemURLKey) as? URL
        self.downloadProgress = downloadProgress
        // 是否已经上传完毕(只有 0 和 1 两个状态)
        self.uploaded = (metadataItem.value(forAttribute: NSMetadataUbiquitousItemPercentUploadedKey) as? Double ?? 0.0) >= 99.9

        if verbose {
            os_log("\(Self.label)Init -> \(fileName ?? "") -> PlaceHolder: \(isPlaceholder) -> \(downloadProgress) -> \(fileSize?.description ?? "")")
 
            debugPrint(metadataItem: metadataItem)
        }
    }
}

// MARK: Debug

extension MetaWrapper {
    /// 打印元数据项的所有属性（调试用）
    func debugPrint(metadataItem: NSMetadataItem) {
        metadataItem.attributes.forEach({
            let key = $0
            var value = metadataItem.value(forAttribute: $0) as? String ?? ""
            
            if key == NSMetadataItemURLKey {
                value = (metadataItem.value(forAttribute: key) as? URL)?.path ?? "x"
            }
            
            if key == NSMetadataItemFSSizeKey {
                value = (metadataItem.value(forAttribute: NSMetadataItemFSSizeKey) as? Int)?.description ?? "x"
            }
            
            os_log("    \(key):\(value)")
        })
    }
}
