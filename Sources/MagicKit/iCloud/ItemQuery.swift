import AsyncAlgorithms
import Foundation
import OSLog

/// iCloud 文件元数据查询器
/// 用于监听 iCloud 文件的变化，包括文件的添加、删除、更新等操作
public class ItemQuery: SuperLog, SuperEvent, SuperThread {
    public static let emoji = "🌸"
    
    /// 系统元数据查询器
    public let query = NSMetadataQuery()
    /// 操作队列
    public let queue: OperationQueue
    /// 是否输出详细日志
    public var verbose = false
    /// 是否已停止监听
    public var stopped = false

    /// 创建查询器实例
    /// - Parameter queue: 操作队列，默认为主队列
    public init(queue: OperationQueue = .main) {
        self.queue = queue
    }
    
    /// 停止监听文件变化
    public func stop() {
        self.stopped = true
    }

    // MARK: - 文件监听

    /// 监听 iCloud 文件变化
    /// - Parameters:
    ///   - predicates: 查询条件数组，用于过滤要监听的文件
    ///   - sortDescriptors: 排序描述符数组，用于对结果进行排序
    ///   - scopes: 查询范围，默认为 iCloud Documents 文件夹
    /// - Returns: 异步流，提供文件变化的实时更新
    ///
    /// 使用示例：
    /// ```swift
    /// let query = ItemQuery()
    /// 
    /// // 监听所有文本文件
    /// let predicate = NSPredicate(format: "%K LIKE[c] '*.txt'", NSMetadataItemFSNameKey)
    /// 
    /// for await collection in query.searchMetadataItems(predicates: [predicate]) {
    ///     // 处理文件变化
    ///     print("Changed files: \(collection.items.count)")
    /// }
    /// ```
    public func searchMetadataItems(
        predicates: [NSPredicate] = [],
        sortDescriptors: [NSSortDescriptor] = [],
        scopes: [Any] = [NSMetadataQueryUbiquitousDocumentsScope]
    ) -> AsyncStream<MetadataItemCollection> {
        if verbose {
            os_log("\(self.t)searchMetadataItems")
        }
        
        query.searchScopes = scopes
        query.sortDescriptors = sortDescriptors
        query.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        return AsyncStream { continuation in
            // 监听初始数据收集完成的通知
            NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidFinishGathering,
                object: query,
                queue: queue
            ) { _ in
                self.collectAll(continuation, name: .NSMetadataQueryDidFinishGathering)
            }

            // 监听数据更新的通知
            NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidUpdate,
                object: query,
                queue: queue
            ) { notification in
                if self.stopped {
                    os_log("\(self.t)停止监听")
                    return continuation.finish()
                }
                
                self.collectChanged(continuation, notification: notification, name: .NSMetadataQueryDidUpdate)
            }

            // 启动查询
            query.operationQueue = queue
            query.operationQueue?.addOperation {
                if self.verbose {
                    os_log("\(self.t)start")
                }
                
                self.query.start()
            }

            // 清理工作
            continuation.onTermination = { @Sendable _ in
                self.query.stop()
                NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidFinishGathering, object: self.query)
                NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidUpdate, object: self.query)
            }
        }
    }

    // MARK: - 私有方法
    
    /// 收集所有文件的元数据
    private func collectAll(_ continuation: AsyncStream<MetadataItemCollection>.Continuation, name: Notification.Name) {
        self.bg.async {
            if self.verbose {
                os_log("\(self.t)NSMetadataQueryDidFinishGathering")
            }
            
            let result = self.query.results.compactMap { item -> MetaWrapper? in
                guard let metadataItem = item as? NSMetadataItem else {
                    return nil
                }
                
                return MetaWrapper(metadataItem: metadataItem)
            }
            
            if self.verbose {
                os_log("\(self.t)Yield with \(result.count)")
            }
            continuation.yield(MetadataItemCollection(name: name, items: result))
        }
    }

    /// 收集发生变化的文件的元数据
    private func collectChanged(_ continuation: AsyncStream<MetadataItemCollection>.Continuation, notification: Notification, name: Notification.Name) {
        let changedItems = notification.userInfo?[NSMetadataQueryUpdateChangedItemsKey] as? [NSMetadataItem] ?? []
        let deletedItems = notification.userInfo?[NSMetadataQueryUpdateRemovedItemsKey] as? [NSMetadataItem] ?? []
        
        let changedResult = changedItems.compactMap { item -> MetaWrapper? in
            MetaWrapper(metadataItem: item, isUpdated: true)
        }
        
        let deletedResult = deletedItems.compactMap { item -> MetaWrapper? in
            MetaWrapper(metadataItem: item, isDeleted: true, isUpdated: true)
        }
        
        DispatchQueue.global().async {
            if self.verbose {
                os_log("\(self.t)NSMetadataQueryDidUpdate")
            }
                
            if changedResult.count > 0 {
                if self.verbose {
                    os_log("\(self.t)Yield with changed \(changedResult.count)")
                }
                continuation.yield(MetadataItemCollection(name: name, items: changedResult))
            }
            
            if deletedResult.count > 0 {
                if self.verbose {
                    os_log("\(self.t)Yield with deleted\(deletedResult.count)")
                }
                continuation.yield(MetadataItemCollection(name: name, items: deletedResult))
            }
        }
    }
}
