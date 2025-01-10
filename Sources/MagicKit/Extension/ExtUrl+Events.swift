import Foundation
import Combine
import SwiftUI
import OSLog

public extension URL {
    /// 监听文件的下载进度
    /// - Parameters:
    ///   - verbose: 是否打印详细日志
    ///   - caller: 调用者名称
    ///   - updateInterval: 更新进度的时间间隔（秒），默认 0.5 秒
    ///   - onProgress: 下载进度回调，progress 范围 0-1
    /// - Returns: 可用于取消监听的 AnyCancellable
    func onDownloading(
        verbose: Bool = true,
        caller: String,
        updateInterval: TimeInterval = 0.5,
        _ onProgress: @escaping (Double) -> Void
    ) -> AnyCancellable {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        let query = ItemQuery(queue: queue)
        
        if verbose {
            Task.detached {
                os_log("\(self.t)👂👂👂 [\(caller)] 开始监听下载进度 -> \(self.title)")
            }
        }
        
        var lastUpdateTime: TimeInterval = 0
        
        let task = Task {
            let result = query.searchMetadataItems(predicates: [
                NSPredicate(format: "%K == %@", NSMetadataItemURLKey, self as NSURL),
            ])
            
            for try await collection in result {
                if let item = collection.first {
                    let currentTime = Date().timeIntervalSince1970
                    if currentTime - lastUpdateTime >= updateInterval {
                        let progress = item.downloadProgress
                        lastUpdateTime = currentTime
                        
                        await MainActor.run {
                            onProgress(progress)
                        }
                    }
                    
                    if item.isDownloaded {
                        if verbose {
                            os_log("\(self.t)下载完成 -> \(self.title)")
                        }
                        query.stop()
                        break
                    }
                }
            }
        }
        
        return AnyCancellable {
            if verbose {
                os_log("\(self.t)🔚🔚🔚 [\(caller)] 停止监听下载进度 -> \(self.title)")
            }
            task.cancel()
            query.stop()
        }
    }
    
    /// 监听文件下载完成事件
    /// - Parameters:
    ///   - verbose: 是否打印详细日志
    ///   - caller: 调用者名称
    ///   - onFinished: 下载完成回调
    /// - Returns: 可用于取消监听的 AnyCancellable
    func onDownloadFinished(
        verbose: Bool = true,
        caller: String,
        _ onFinished: @escaping () -> Void
    ) -> AnyCancellable {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        let query = ItemQuery(queue: queue)
        
        if verbose {
            Task.detached {
                os_log("\(self.t)👂👂👂 [\(caller)] 开始监听下载完成 -> \(self.title)")
            }
        }
        
        let task = Task {
            let result = query.searchMetadataItems(predicates: [
                NSPredicate(format: "%K == %@", NSMetadataItemURLKey, self as NSURL),
            ])
            
            for try await collection in result {
                if let item = collection.first, item.isDownloaded {
                    if verbose {
                        os_log("\(self.t)[\(caller)] 下载完成 -> \(self.title)")
                    }
                    await MainActor.run {
                        onFinished()
                    }
                    query.stop()
                    break
                }
            }
        }
        
        return AnyCancellable {
            if verbose {
                os_log("\(self.t)🔚🔚🔚 [\(caller)] 停止监听下载完成 -> \(self.title)")
            }
            task.cancel()
            query.stop()
        }
    }
    
    /// 监听文件的状态变化
    /// - Parameters:
    ///   - verbose: 是否打印详细日志
    ///   - onChange: 状态变化回调，返回最新的元数据项
    /// - Returns: 可用于取消监听的 AnyCancellable
    func onStateChanged(verbose: Bool = true, _ onChange: @escaping (MetaWrapper) -> Void) -> AnyCancellable {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        let query = ItemQuery(queue: queue)
        
        if verbose {
            Task.detached {
                os_log("\(self.t)开始监听状态变化")
            }
        }
        
        let task = Task {
            let result = query.searchMetadataItems(predicates: [
                NSPredicate(format: "%K == %@", NSMetadataItemURLKey, self as NSURL),
            ])
            
            for try await collection in result {
                if let item = collection.first {
                    if verbose {
                        os_log("\(self.t)状态已更新")
                    }
                    await MainActor.run {
                        onChange(item)
                    }
                }
            }
        }
        
        return AnyCancellable {
            if verbose {
                os_log("\(self.t)停止监听状态变化")
            }
            task.cancel()
            query.stop()
        }
    }
    
    /// 监听文件夹内容变化
    /// - Parameters:
    ///   - verbose: 是否打印详细日志
    ///   - caller: 调用者名称
    ///   - onChange: 文件夹变化回调
    ///     - files: 文件列表
    ///     - isInitialFetch: 是否是初始的全量数据
    /// - Returns: 可用于取消监听的 AnyCancellable
    ///
    /// 示例用法:
    /// ```swift
    /// // 1. 基础用法
    /// let url = URL(filePath: "path/to/icloud/folder")
    /// let cancellable = url.onDirectoryChanged(caller: "MyApp") { files, isInitialFetch in
    ///     if isInitialFetch {
    ///         print("收到文件夹的初始数据，文件数：\(files.count)")
    ///     } else {
    ///         print("文件夹内容发生变化，当前文件数：\(files.count)")
    ///     }
    ///     
    ///     // 遍历所有文件
    ///     for file in files {
    ///         print("文件名：\(file.url.lastPathComponent)")
    ///         print("下载状态：\(file.isDownloaded ? "已下载" : "未下载")")
    ///         print("下载进度：\(file.downloadProgress)")
    ///     }
    /// }
    ///
    /// // 2. 在 SwiftUI 视图中使用
    /// class FolderViewModel: ObservableObject {
    ///     @Published var files: [MetaWrapper] = []
    ///     private var cancellable: AnyCancellable?
    ///     
    ///     func startMonitoring(url: URL) {
    ///         cancellable = url.onDirectoryChanged(caller: "FolderView") { [weak self] files, isInitialFetch in
    ///             if isInitialFetch {
    ///                 // 首次加载，可以显示加载指示器
    ///                 self?.files = files
    ///             } else {
    ///                 // 后续更新，可以显示更新提示
    ///                 self?.files = files
    ///             }
    ///         }
    ///     }
    ///     
    ///     func stopMonitoring() {
    ///         cancellable?.cancel()
    ///     }
    /// }
    /// ```
    func onDirectoryChanged(
        verbose: Bool = true,
        caller: String,
        _ onChange: @escaping (_ files: [MetaWrapper], _ isInitialFetch: Bool) -> Void
    ) -> AnyCancellable {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        let query = ItemQuery(queue: queue)
        
        if verbose {
            Task.detached {
                os_log("\(self.t)👂👂👂 [\(caller)] 开始监听文件夹变化 -> \(self.title)")
            }
        }
        
        var isFirstFetch = true
        let task = Task {
            let result = query.searchMetadataItems(predicates: [
                NSPredicate(format: "%K BEGINSWITH %@ AND %K != %@", 
                           NSMetadataItemPathKey, self.path,
                           NSMetadataItemPathKey, self.path)
            ])
            
            for try await collection in result {
                if verbose {
                    os_log("\(self.t)🍋🍋🍋 [\(caller)] 文件夹内容已更新 -> \(self.title)")
                }
                await MainActor.run {
                    onChange(collection.items, isFirstFetch)
                    isFirstFetch = false
                }
            }
        }
        
        return AnyCancellable {
            if verbose {
                os_log("\(self.t)🔚🔚🔚 [\(caller)] 停止监听文件夹变化 -> \(self.title)")
            }
            task.cancel()
            query.stop()
        }
    }
} 

/// iCloud 文件元数据查询器
/// 用于监听 iCloud 文件的变化，包括文件的添加、删除、更新等操作
private class ItemQuery: SuperLog, SuperEvent, SuperThread {
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


#Preview {
    URLEventsPreview()
}
