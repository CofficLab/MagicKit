import Foundation

public extension NSMetadataItem {
    /// 文件名
    var fileName: String? {
        value(forAttribute: NSMetadataItemFSNameKey) as? String
    }
    
    /// 文件大小（字节）
    var fileSize: Int64? {
        value(forAttribute: NSMetadataItemFSSizeKey) as? Int64
    }
    
    /// 文件内容类型（UTI）
    var contentType: String? {
        value(forAttribute: NSMetadataItemContentTypeKey) as? String
    }
    
    /// 是否为目录
    var isDirectory: Bool {
        contentType == "public.folder"
    }
    
    /// 文件 URL
    var url: URL? {
        value(forAttribute: NSMetadataItemURLKey) as? URL
    }
    
    /// 是否为占位文件（未完全下载的文件）
    var isPlaceholder: Bool {
        guard let downloadingStatus = value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String else {
            return false
        }
        return downloadingStatus == NSMetadataUbiquitousItemDownloadingStatusNotDownloaded
    }
    
    /// 下载进度（0-1）
    var downloadProgress: Double {
        (value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double ?? 0.0) / 100.0
    }
    
    /// 是否已上传完成
    var isUploaded: Bool {
        (value(forAttribute: NSMetadataUbiquitousItemPercentUploadedKey) as? Double ?? 0.0) >= 99.9
    }
    
    /// 文件是否已下载完成
    var isDownloaded: Bool {
        downloadProgress >= 0.999 || isPlaceholder == false
    }
    
    /// 文件是否正在下载
    var isDownloading: Bool {
        isPlaceholder && downloadProgress > 0.0 && downloadProgress < 0.999
    }
    
    /// 打印所有属性（调试用）
    func debugPrint() {
        attributes.forEach { key in
            var value = self.value(forAttribute: key) as? String ?? ""
            
            if key == NSMetadataItemURLKey {
                value = (self.value(forAttribute: key) as? URL)?.path ?? "x"
            }
            
            if key == NSMetadataItemFSSizeKey {
                value = (self.value(forAttribute: NSMetadataItemFSSizeKey) as? Int)?.description ?? "x"
            }
            
            print("    \(key):\(value)")
        }
    }
}

// MARK: - Hashable
extension NSMetadataItem {
    override public var hash: Int {
        url?.hashValue ?? 0
    }
}
