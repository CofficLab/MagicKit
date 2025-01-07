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
} 

#Preview {
    URLEventsPreview()
}
