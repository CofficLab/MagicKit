import Foundation
import Combine
import SwiftUI
import OSLog

public extension URL {
    /// 监听文件夹内容变化
    /// - Parameters:
    ///   - verbose: 是否打印详细日志
    ///   - caller: 调用者名称
    ///   - onChange: 文件夹变化回调
    ///     - files: 文件列表
    ///     - isInitialFetch: 是否是初始的全量数据
    /// - Returns: 可用于取消监听的 AnyCancellable
    func onDirectoryChanged(
        verbose: Bool = true,
        caller: String,
        _ onChange: @escaping (_ files: [NSMetadataItem], _ isInitialFetch: Bool) async -> Void
    ) -> AnyCancellable {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        
        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(format: "%K BEGINSWITH %@ AND %K != %@", 
                                    NSMetadataItemPathKey, self.path,
                                    NSMetadataItemPathKey, self.path)
        query.operationQueue = queue
        
        if verbose {
            os_log("\(self.t)👂👂👂 [\(caller)] 开始监听文件夹变化 -> \(self.title)")
        }
        
        var isFirstFetch = true
        let task = Task {
            try await withTaskCancellationHandler {
                let stream = AsyncStream<Notification> { continuation in
                    // 监听初始数据收集完成的通知
                    NotificationCenter.default.addObserver(
                        forName: .NSMetadataQueryDidFinishGathering,
                        object: query,
                        queue: queue
                    ) { notification in
                        continuation.yield(notification)
                    }
                    
                    // 监听数据更新的通知
                    NotificationCenter.default.addObserver(
                        forName: .NSMetadataQueryDidUpdate,
                        object: query,
                        queue: queue
                    ) { notification in
                        continuation.yield(notification)
                    }
                }
                
                for await _ in stream {
                    guard !Task.isCancelled else { break }
                    
                    let items = query.results.compactMap { item -> NSMetadataItem? in
                        guard let metadataItem = item as? NSMetadataItem else { return nil }
                        return metadataItem
                    }
                    
                    if verbose {
                        os_log("\(self.t)🍋🍋🍋 [\(caller)] 文件夹内容已更新 -> \(self.shortPath())")
                    }
                    
                    await onChange(items, isFirstFetch)
                    isFirstFetch = false
                }
            } onCancel: {
                query.stop()
                NotificationCenter.default.removeObserver(self, 
                    name: .NSMetadataQueryDidFinishGathering, 
                    object: query)
                NotificationCenter.default.removeObserver(self, 
                    name: .NSMetadataQueryDidUpdate, 
                    object: query)
            }
        }
        
        query.start()
        
        return AnyCancellable {
            if verbose {
                os_log("\(self.t)🔚🔚🔚 [\(caller)] 停止监听文件夹变化 -> \(self.shortPath())")
            }
            task.cancel()
            query.stop()
        }
    }
} 