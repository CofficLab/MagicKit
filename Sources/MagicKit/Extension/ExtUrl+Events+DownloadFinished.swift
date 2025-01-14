import Foundation
import Combine
import SwiftUI
import OSLog

public extension URL {    
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
        
        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(format: "%K == %@", NSMetadataItemURLKey, self as NSURL)
        query.operationQueue = queue
        
        if verbose {
            os_log("\(self.t)👂👂👂 [\(caller)] 开始监听下载完成 -> \(self.title)")
        }
        
        let task = Task {
            let stream = AsyncStream<Notification> { continuation in
                NotificationCenter.default.addObserver(
                    forName: .NSMetadataQueryDidUpdate,
                    object: query,
                    queue: queue
                ) { notification in
                    continuation.yield(notification)
                }
            }
            
            for await _ in stream {
                if let item = query.results.first as? NSMetadataItem, item.isDownloaded {
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
        
        query.start()
        
        return AnyCancellable {
            if verbose {
                os_log("\(self.t)🔚🔚🔚 [\(caller)] 停止监听下载完成 -> \(self.title)")
            }
            task.cancel()
            query.stop()
        }
    }
} 
