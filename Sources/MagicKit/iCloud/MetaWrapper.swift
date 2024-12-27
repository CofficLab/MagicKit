import Foundation
import OSLog

public struct MetadataItemCollection: Sendable {
    public var name: Notification.Name
    public var isUpdated = false
    public var items: [MetaWrapper] = []
    
    public var count: Int {
        items.count
    }
    
    public var first: MetaWrapper? {
        items.first
    }
    
    public var itemsForSync: [MetaWrapper] {
        items.filter { $0.isUpdated == false }
    }
    
    public var itemsForUpdate: [MetaWrapper] {
        items.filter { $0.isUpdated && $0.isDeleted == false }
    }
    
    public var itemsForDelete: [MetaWrapper] {
        items.filter { $0.isDeleted }
    }
}

public struct MetaWrapper: Sendable {
    static var label = "📁 MetaWrapper::"
    
    public let fileName: String?
    public let fileSize: Int64?
    public let contentType: String?
    public let isDirectory: Bool
    public let url: URL?
    public let isPlaceholder: Bool
    public let isDeleted: Bool
    /// 发生了变动
    public let isUpdated: Bool
    public let downloadProgress: Double
    public let uploaded: Bool
    public let identifierKey: String? = nil
    
    public var isDownloaded: Bool {
        downloadProgress == 100 || isPlaceholder == false
    }
    
    // 如果是占位文件且下载进度大于0且小于100，则认为文件正在下载
    public var isDownloading: Bool {
        isPlaceholder && downloadProgress > 0.0 && downloadProgress < 100.0
    }
    
    public var label: String { "\(Self.label)" }

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
        
        let downloadProgress = metadataItem.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double ?? 0.0
        
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
        // 是否已经上传完毕(只有 0 和 100 两个状态)
        self.uploaded = (metadataItem.value(forAttribute: NSMetadataUbiquitousItemPercentUploadedKey) as? Double ?? 0.0) == 100

        if verbose {
            os_log("\(Self.label)Init -> \(fileName ?? "") -> PlaceHolder: \(isPlaceholder) -> \(downloadProgress) -> \(fileSize?.description ?? "")")
 
            debugPrint(metadataItem: metadataItem)
        }
    }
}

// MARK: Debug

extension MetaWrapper {
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
