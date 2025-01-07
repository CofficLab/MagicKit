import Combine
import Foundation

extension AvatarView {
    /// 下载监控管理器
    final class DownloadMonitor {
        private var cancellables: Set<AnyCancellable> = []
        
        func startMonitoring(
            url: URL,
            onProgress: @escaping (Double) -> Void,
            onFinished: @escaping () -> Void
        ) {
            // 清理之前的监控
            cancellables.removeAll()
            
            // 设置新的监控
            url.onDownloading(caller: "AvatarView.DownloadMonitor") { progress in
                onProgress(progress)
            }.store(in: &cancellables)
            
            url.onDownloadFinished(caller: "AvatarView.DownloadMonitor") {
                onFinished()
            }.store(in: &cancellables)
        }
        
        func stopMonitoring() {
            cancellables.removeAll()
        }
    }
} 
