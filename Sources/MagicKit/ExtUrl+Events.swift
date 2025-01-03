import Foundation
import Combine
import SwiftUI
import OSLog

public extension URL {
    /// 监听文件的下载进度
    /// - Parameters:
    ///   - verbose: 是否打印详细日志
    ///   - onProgress: 下载进度回调，progress 范围 0-1
    /// - Returns: 可用于取消监听的 AnyCancellable
    func onDownloading(verbose: Bool = true, _ onProgress: @escaping (Double) -> Void) -> AnyCancellable {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let query = ItemQuery(queue: queue)
        
        if verbose {
            os_log("\(self.t)开始监听下载进度 -> \(self.title)")
        }
        
        let task = Task {
            let result = query.searchMetadataItems(predicates: [
                NSPredicate(format: "%K == %@", NSMetadataItemURLKey, self as NSURL),
            ])
            
            for try await collection in result {
                if let item = collection.first {
                    let progress = item.downloadProgress / 100
                    if verbose {
                        os_log("\(self.t)下载进度: \(progress) -> \(self.title)")
                    }
                    
                    await MainActor.run {
                        onProgress(progress)
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
                os_log("\(self.t)停止监听下载进度 -> \(self.title)")
            }
            task.cancel()
            query.stop()
        }
    }
    
    /// 监听文件下载完成事件
    /// - Parameters:
    ///   - verbose: 是否打印详细日志
    ///   - onFinished: 下载完成回调
    /// - Returns: 可用于取消监听的 AnyCancellable
    func onDownloadFinished(verbose: Bool = true, _ onFinished: @escaping () -> Void) -> AnyCancellable {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let query = ItemQuery(queue: queue)
        
        if verbose {
            os_log("\(self.t)开始监听下载完成")
        }
        
        let task = Task {
            let result = query.searchMetadataItems(predicates: [
                NSPredicate(format: "%K == %@", NSMetadataItemURLKey, self as NSURL),
            ])
            
            for try await collection in result {
                if let item = collection.first, item.isDownloaded {
                    if verbose {
                        os_log("\(self.t)下载完成")
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
                os_log("\(self.t)停止监听下载完成")
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
        let query = ItemQuery(queue: queue)
        
        if verbose {
            os_log("\(self.t)开始监听状态变化")
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

// MARK: - Preview
struct URLEventsPreview: View {
    @State private var downloadProgress: Double = 0
    @State private var isFinished = false
    @State private var cancellable: AnyCancellable?
    
    var body: some View {
        VStack(spacing: 20) {
            // 下载进度示例
            VStack {
                Text("下载进度: \(Int(downloadProgress * 100))%")
                ProgressView(value: downloadProgress)
            }
            .padding()
            
            // 下载状态示例
            if isFinished {
                Text("下载已完成")
                    .foregroundStyle(.green)
            }
            
            // 测试按钮
            Button("开始监听") {
                let url = URL.documentsDirectory.appendingPathComponent("test.pdf")
                
                // 监听下载进度
                cancellable = url.onDownloading { progress in
                    downloadProgress = progress
                }
                
                // 监听下载完成
                cancellable = url.onDownloadFinished {
                    isFinished = true
                }
            }
        }
        .onDisappear {
            cancellable?.cancel()
        }
    }
}

#Preview {
    URLEventsPreview()
} 
