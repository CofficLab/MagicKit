import Foundation
import Combine
import SwiftUI
import OSLog

public extension URL {
    /// 监听文件的下载进度
    /// - Parameter onProgress: 下载进度回调，progress 范围 0-1
    /// - Returns: 可用于取消监听的 AnyCancellable
    func onDownloading(_ onProgress: @escaping (Double) -> Void) -> AnyCancellable {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let query = ItemQuery(queue: queue)
        
        let task = Task {
            let result = query.searchMetadataItems(predicates: [
                NSPredicate(format: "%K == %@", NSMetadataItemURLKey, self as NSURL),
            ])
            
            for try await collection in result {
                if let item = collection.first {
                    let progress = item.downloadProgress
                    await MainActor.run {
                        onProgress(progress)
                    }
                    
                    if item.isDownloaded {
                        query.stop()
                        break
                    }
                }
            }
        }
        
        return AnyCancellable {
            task.cancel()
            query.stop()
        }
    }
    
    /// 监听文件下载完成事件
    /// - Parameter onFinished: 下载完成回调
    /// - Returns: 可用于取消监听的 AnyCancellable
    func onDownloadFinished(_ onFinished: @escaping () -> Void) -> AnyCancellable {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let query = ItemQuery(queue: queue)
        
        let task = Task {
            let result = query.searchMetadataItems(predicates: [
                NSPredicate(format: "%K == %@", NSMetadataItemURLKey, self as NSURL),
            ])
            
            for try await collection in result {
                if let item = collection.first, item.isDownloaded {
                    await MainActor.run {
                        onFinished()
                    }
                    query.stop()
                    break
                }
            }
        }
        
        return AnyCancellable {
            task.cancel()
            query.stop()
        }
    }
    
    /// 监听文件的状态变化
    /// - Parameter onChange: 状态变化回调，返回最新的元数据项
    /// - Returns: 可用于取消监听的 AnyCancellable
    func onStateChanged(_ onChange: @escaping (MetaWrapper) -> Void) -> AnyCancellable {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let query = ItemQuery(queue: queue)
        
        let task = Task {
            let result = query.searchMetadataItems(predicates: [
                NSPredicate(format: "%K == %@", NSMetadataItemURLKey, self as NSURL),
            ])
            
            for try await collection in result {
                if let item = collection.first {
                    await MainActor.run {
                        onChange(item)
                    }
                }
            }
        }
        
        return AnyCancellable {
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