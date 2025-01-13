import Foundation
import Combine
import SwiftUI
import OSLog

public extension URL {
    /// iCloud 文件状态
    struct ICloudFileStatus {
        public let url: URL
        public let isDownloaded: Bool
        public let isDownloading: Bool
        public let downloadStatus: URLUbiquitousItemDownloadingStatus?
        public let error: Error?
        
        public var isUnavailable: Bool {
            return downloadStatus == .notDownloaded
        }
    }
    
    /// 监听 iCloud 文件夹内容变化
    /// - Parameters:
    ///   - verbose: 是否打印详细日志
    ///   - caller: 调用者名称
    ///   - onChange: 文件夹变化回调
    ///     - files: 文件状态列表
    ///     - isInitialFetch: 是否是初始的全量数据
    ///     - error: 可能发生的错误
    /// - Returns: 可用于取消监听的 AnyCancellable
    func onICloudDirectoryChanged(
        verbose: Bool = true,
        caller: String,
        _ onChange: @escaping (_ files: [ICloudFileStatus], _ isInitialFetch: Bool, _ error: Error?) -> Void
    ) -> AnyCancellable {
        let logger = Logger(subsystem: "MagicKit", category: "iCloudMonitor")
        let query = NSMetadataQuery()
        
        // 设置查询范围为指定文件夹
        query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        query.searchItems = [self]
        
        // 设置要监听的属性
        query.predicate = NSPredicate(format: "(%K BEGINSWITH %@)",
                                    NSMetadataItemPathKey,
                                    self.path)
        
        // 设置要获取的属性
        query.valueListAttributes = [
            NSMetadataItemURLKey,
            NSMetadataItemFSNameKey,
            NSMetadataUbiquitousItemDownloadingStatusKey,
            NSMetadataUbiquitousItemIsDownloadingKey,
            NSMetadataUbiquitousItemIsUploadedKey
        ]
        
        if verbose {
            logger.info("[\(caller)] Start monitoring iCloud directory: \(self.lastPathComponent)")
        }
        
        // 设置通知监听
        var cancellables = Set<AnyCancellable>()
        
        let notificationCenter = NotificationCenter.default
        
        // 监听查询完成通知
        notificationCenter.publisher(for: .NSMetadataQueryDidFinishGathering)
            .sink { [weak query] _ in
                guard let query = query else { return }
                processQueryResults(query: query, isInitial: true)
            }
            .store(in: &cancellables)
        
        // 监听查询更新通知
        notificationCenter.publisher(for: .NSMetadataQueryDidUpdate)
            .sink { [weak query] _ in
                guard let query = query else { return }
                processQueryResults(query: query, isInitial: false)
            }
            .store(in: &cancellables)
        
        func processQueryResults(query: NSMetadataQuery, isInitial: Bool) {
            query.disableUpdates()
            defer { query.enableUpdates() }
            
            let results = query.results as? [NSMetadataItem] ?? []
            let fileStatuses = results.compactMap { item -> ICloudFileStatus? in
                guard let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL else {
                    return nil
                }
                
                let downloadStatus = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? URLUbiquitousItemDownloadingStatus
                let isDownloading = item.value(forAttribute: NSMetadataUbiquitousItemIsDownloadingKey) as? Bool ?? false
                
                if verbose {
                    logger.info("[\(caller)] File: \(url.lastPathComponent), Status: \(downloadStatus?.rawValue ?? "unknown"), Downloading: \(isDownloading)")
                }
                
                return ICloudFileStatus(
                    url: url,
                    isDownloaded: downloadStatus == .current,
                    isDownloading: isDownloading,
                    downloadStatus: downloadStatus,
                    error: nil
                )
            }
            
            onChange(fileStatuses, isInitial, nil)
        }
        
        // 启动查询
        query.start()
        
        return AnyCancellable {
            if verbose {
                logger.info("[\(caller)] Stop monitoring iCloud directory: \(self.lastPathComponent)")
            }
            query.stop()
            cancellables.removeAll()
        }
    }
}

// MARK: - 便利扩展
public extension URL.ICloudFileStatus {
    /// 文件状态的描述
    var statusDescription: String {
        if isDownloading {
            return "正在下载"
        } else if isDownloaded {
            return "已下载"
        } else if isUnavailable {
            return "未下载"
        } else {
            return "未知状态"
        }
    }
} 
