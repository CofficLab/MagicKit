import Combine
import Foundation

extension AvatarView {
    /// 下载监控管理器
    final class DownloadMonitor {
        private var cancellables: Set<AnyCancellable> = []
        private var verbose: Bool
        
        init(verbose: Bool) {
            self.verbose = verbose
        }
        
        func startMonitoring(
            url: URL,
            onProgress: @escaping (Double) -> Void,
            onFinished: @escaping () -> Void
        ) {
            // 清理之前的监控
            cancellables.removeAll()
            
            // 设置新的监控
            let progressCancellable = url.onDownloading(verbose: self.verbose, caller: "AvatarView.DownloadMonitor", updateInterval: 1, onProgress)
            progressCancellable.store(in: &cancellables)
            
            let finishedCancellable = url.onDownloadFinished(caller: "AvatarView.DownloadMonitor", onFinished)
            finishedCancellable.store(in: &cancellables)
        }
        
        func stopMonitoring() {
            cancellables.removeAll()
        }
    }
} 
