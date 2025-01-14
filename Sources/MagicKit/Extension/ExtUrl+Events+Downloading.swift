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
        
        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(format: "%K == %@", NSMetadataItemURLKey, self as NSURL)
        query.operationQueue = queue
        
        if verbose {
            os_log("\(self.t)👂👂👂 [\(caller)] 开始监听下载进度 -> \(self.title)")
        }
        
        var lastUpdateTime: TimeInterval = 0
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
                if let item = query.results.first as? NSMetadataItem {
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
        
        query.start()
        
        return AnyCancellable {
            if verbose {
                os_log("\(self.t)🔚🔚🔚 [\(caller)] 停止监听下载进度 -> \(self.title)")
            }
            task.cancel()
            query.stop()
        }
    }
}
