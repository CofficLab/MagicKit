import Combine
import Darwin
import Foundation
import OSLog
import SwiftUI

public extension URL {
    /// 自动判断并监听文件夹变化（支持本地文件夹和 iCloud 文件夹）
    /// - Parameters:
    ///   - verbose: 是否打印详细日志，默认为 true
    ///   - caller: 调用者名称，用于日志标识
    ///   - onChange: 文件夹变化回调
    ///     - files: 文件列表，包含文件夹下所有文件的 URL
    ///     - isInitialFetch: 是否是初始的全量数据。首次获取数据时为 true，后续更新为 false
    ///     - error: 可能发生的错误。如果操作成功，则为 nil
    ///   - onProgress: iCloud 文件下载进度回调
    ///     - url: 正在下载的文件 URL
    ///     - progress: 下载进度，范围 0.0-1.0
    /// - Returns: 可用于取消监听的 AnyCancellable。调用 cancel() 方法可停止监听
    /// - Note: 对于本地文件夹，使用 FSEvents 进行监听；对于 iCloud 文件夹，使用 NSMetadataQuery 进行监听
    /// - Important: 请确保在不需要监听时调用返回的 AnyCancellable 的 cancel() 方法，以释放资源
    func onDirChange(
        verbose: Bool = true,
        caller: String,
        _ onChange: @escaping (_ files: [URL], _ isInitialFetch: Bool, _ error: Error?) async -> Void,
        onProgress: @escaping (_ url: URL, _ progress: Double) -> Void = { _, _ in }
    ) -> AnyCancellable {
        if isiCloud {
            os_log("\(self.t)👀 [\(caller)] Start monitoring iCloud directory: \(self.shortPath())")
            return onICloudDirectoryChanged(verbose: verbose, caller: caller,
                                            onProgress: onProgress) { files, isInitial, error in
                Task {
                    await onChange(files, isInitial, error)
                }
            }
        } else {
            os_log("\(self.t)👀 [\(caller)] Start monitoring local directory: \(self.shortPath())")
            return onDirectoryChanged(verbose: verbose, caller: caller, onChange)
        }
    }

    /// 监听本地文件夹内容变化
    /// - Parameters:
    ///   - verbose: 是否打印详细日志，默认为 true
    ///   - caller: 调用者名称，用于日志标识
    ///   - onChange: 文件夹变化回调
    ///     - files: 文件列表，包含文件夹下所有文件的 URL
    ///     - isInitialFetch: 是否是初始的全量数据
    ///     - error: 可能发生的错误
    /// - Returns: 可用于取消监听的 AnyCancellable
    /// - Note: 使用 FSEvents 监听文件夹变化，可以实时检测文件的添加、删除和修改
    private func onDirectoryChanged(
        verbose: Bool = true,
        caller: String,
        _ onChange: @escaping (_ files: [URL], _ isInitialFetch: Bool, _ error: Error?) async -> Void
    ) -> AnyCancellable {
        let logger = Logger(subsystem: "MagicKit", category: "FileMonitor")

        // 创建文件监视器
        let fileDescriptor = Darwin.open(self.path, O_EVTONLY)
        if fileDescriptor < 0 {
            logger.error("\(self.t)❌ [\(caller)] Failed to open file descriptor for \(self.path)")
            return AnyCancellable {}
        }

        if verbose {
            logger.info("\(self.t)🎯 [\(caller)] Successfully opened file descriptor for: \(self.lastPathComponent)")
        }

        let monitor = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: .global(qos: .background)
        )

        if verbose {
            logger.info("[\(caller)] Start monitoring directory: \(self.lastPathComponent)")
        }

        // 使用 actor 来管理状态
        actor DirectoryMonitorState {
            private var isFirstFetch = true

            func getAndUpdateFirstFetch() -> Bool {
                let current = isFirstFetch
                isFirstFetch = false
                return current
            }
        }

        let state = DirectoryMonitorState()

        @Sendable func scanDirectory() async throws {
            if verbose {
                logger.info("\(self.t)🔍 [\(caller)] Scanning directory: \(self.lastPathComponent)")
            }

            let fileManager = FileManager.default

            guard fileManager.fileExists(atPath: self.path) else {
                logger.error("\(self.t)❌ [\(caller)] Directory does not exist: \(self.lastPathComponent)")
                throw URLError(.fileDoesNotExist)
            }

            let urls = try fileManager.contentsOfDirectory(
                at: self,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: [.skipsHiddenFiles]
            )

            if verbose {
                logger.info("\(self.t)📝 [\(caller)] Found \(urls.count) files in: \(self.lastPathComponent)")
                urls.forEach { url in
                    logger.info("\(self.t)📄 [\(caller)] File: \(url.lastPathComponent)")
                }
            }

            let isFirstFetch = await state.getAndUpdateFirstFetch()
            await onChange(urls, isFirstFetch, nil)
        }

        let task = Task {
            do {
                // 初始化监听
                try await scanDirectory()

                // 设置文件变化处理
                monitor.setEventHandler {
                    Task {
                        try await scanDirectory()
                    }
                }

                monitor.resume()
            } catch {
                await onChange([], false, error)
            }
        }

        return AnyCancellable {
            if verbose {
                logger.info("[\(caller)] Stop monitoring directory: \(self.lastPathComponent)")
            }
            task.cancel()
            monitor.cancel()
            Darwin.close(fileDescriptor)
        }
    }

    /// 监听 iCloud 文件夹内容变化
    /// - Parameters:
    ///   - verbose: 是否打印详细日志，默认为 true
    ///   - caller: 调用者名称，用于日志标识
    ///   - onChange: 文件夹变化回调
    ///     - files: 文件列表，包含文件夹下所有文件的 URL
    ///     - isInitialFetch: 是否是初始的全量数据。首次查询完成时为 true，后续更新为 false
    ///     - error: 可能发生的错误。如果查询成功，则为 nil
    ///   - onProgress: iCloud 文件下载进度回调
    ///     - url: 正在下载的文件 URL
    ///     - progress: 下载进度，范围 0.0-1.0
    /// - Returns: 可用于取消监听的 AnyCancellable
    /// - Note: 使用 NSMetadataQuery 监听 iCloud 文件夹变化，可以检测文件的同步状态和变化
    /// - Important: iCloud 文件夹的监听可能会有一定延迟，这是由 iCloud 同步机制决定的
    private func onICloudDirectoryChanged(
        verbose: Bool = true,
        caller: String,
        onProgress: @escaping (_ url: URL, _ progress: Double) -> Void,
        _ onChange: @escaping (_ files: [URL], _ isInitialFetch: Bool, _ error: Error?) -> Void
    ) -> AnyCancellable {
        let logger = Logger(subsystem: "MagicKit", category: "iCloudMonitor")
        let query = NSMetadataQuery()
        var cancellables = Set<AnyCancellable>()
        
        // 配置查询参数
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(format: "(%K BEGINSWITH %@)", NSMetadataItemPathKey, self.path)
        query.valueListAttributes = [
            NSMetadataItemURLKey,
            NSMetadataUbiquitousItemPercentDownloadedKey,
            NSMetadataUbiquitousItemIsDownloadingKey
        ]
        
        if verbose {
            logger.info("\(self.t)🔍 [\(caller)] Monitoring iCloud path: \(self.path)")
        }
        
        // 处理文件下载进度
        func handleDownloadProgress(_ items: [NSMetadataItem]) {
            for item in items {
                guard let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL,
                      let isDownloading = item.value(forAttribute: NSMetadataUbiquitousItemIsDownloadingKey) as? Bool,
                      isDownloading,
                      let percentDownloaded = item.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double
                else { continue }
                
                let progress = max(0.0, min(1.0, percentDownloaded / 100))
                if verbose {
                    logger.info("\(self.t)📥 [\(caller)] \(url.lastPathComponent): \(Int(progress * 100))%")
                }
                DispatchQueue.main.async {
                    onProgress(url, progress)
                }
            }
        }
        
        // 处理查询结果
        func processResults(isInitial: Bool = false, changedItems: [NSMetadataItem]? = nil) {
            query.disableUpdates()
            defer { query.enableUpdates() }
            
            let urls: [URL]
            if isInitial {
                // 初始化时返回所有文件
                urls = (query.results as? [NSMetadataItem] ?? [])
                    .compactMap { $0.value(forAttribute: NSMetadataItemURLKey) as? URL }
            } else {
                // 更新时只返回变化的文件
                urls = (changedItems ?? [])
                    .compactMap { $0.value(forAttribute: NSMetadataItemURLKey) as? URL }
            }
            
            if verbose {
                logger.info("\(self.t)📦 [\(caller)] Found \(urls.count) \(isInitial ? "total" : "changed") files")
            }
            
            onChange(urls, isInitial, nil)
        }
        
        // 设置通知监听
        NotificationCenter.default.publisher(for: .NSMetadataQueryDidUpdate)
            .sink { [weak query] notification in
                guard let query = query,
                      let items = notification.userInfo?[NSMetadataQueryUpdateChangedItemsKey] as? [NSMetadataItem]
                else { return }
                
                handleDownloadProgress(items)
                processResults(isInitial: false, changedItems: items)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .NSMetadataQueryDidFinishGathering)
            .sink { [weak query] _ in
                guard let query = query else { return }
                processResults(isInitial: true)
            }
            .store(in: &cancellables)
        
        // 启动查询
        DispatchQueue.main.async {
            query.start()
        }
        
        return AnyCancellable {
            if verbose {
                logger.info("[\(caller)] Stop monitoring: \(self.lastPathComponent)")
            }
            query.stop()
            cancellables.removeAll()
        }
    }
}
