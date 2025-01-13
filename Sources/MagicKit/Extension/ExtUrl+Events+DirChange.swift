import Foundation
import Combine
import OSLog

public extension URL {
    /// 智能监听文件夹变化（自动判断本地/iCloud文件夹）
    func onDirChange(
        verbose: Bool = true,
        caller: String,
        _ onChange: @escaping (_ files: [URL], _ isInitialFetch: Bool, _ error: Error?) async -> Void,
        onDownloadProgress: @escaping (_ url: URL, _ progress: Double) -> Void
    ) -> AnyCancellable {
        let logger = Logger(subsystem: "MagicKit", category: "DirectoryMonitor")
        
        if isiCloud {
            if verbose {
                logger.info("[\(caller)] Using iCloud monitor for: \(self.shortPath())")
            }
            return onICloudDirectoryChanged(verbose: verbose, caller: caller) { files, isInitial, error in
                Task {
                    await onChange(files, isInitial, error)
                }
            } onDownloadProgress: { url, progress in
                onDownloadProgress(url, progress)
            }
        } else {
            if verbose {
                logger.info("[\(caller)] Using local monitor for: \(self.shortPath())")
            }
            return onLocalDirectoryChanged(verbose: verbose, caller: caller, onChange)
        }
    }
    
    /// 监听本地文件夹变化
    private func onLocalDirectoryChanged(
        verbose: Bool = true,
        caller: String,
        _ onChange: @escaping (_ files: [URL], _ isInitialFetch: Bool, _ error: Error?) async -> Void
    ) -> AnyCancellable {
        let logger = Logger(subsystem: "MagicKit", category: "LocalMonitor")
        
        // 创建文件描述符
        let fileDescriptor = Darwin.open(self.path, O_EVTONLY)
        guard fileDescriptor >= 0 else {
            if verbose {
                logger.error("[\(caller)] Failed to create file descriptor for: \(self.lastPathComponent)")
            }
            Task {
                await onChange([], true, URLError(.cannotOpenFile))
            }
            return AnyCancellable {}
        }
        
        // 创建监听源
        let monitor = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .all,
            queue: .global(qos: .background)
        )
        
        // 使用 actor 来管理状态
        actor MonitorState {
            private var isFirstFetch = true
            
            func getAndUpdateFirstFetch() -> Bool {
                let current = isFirstFetch
                isFirstFetch = false
                return current
            }
        }
        
        let state = MonitorState()
        
        // 扫描目录内容的函数
        @Sendable func scanDirectory() async {
            do {
                let urls = try FileManager.default.contentsOfDirectory(
                    at: self,
                    includingPropertiesForKeys: [.contentModificationDateKey],
                    options: [.skipsHiddenFiles]
                )
                
                if verbose {
                    logger.info("[\(caller)] Directory content updated: \(self.lastPathComponent)")
                }
                
                let isFirstFetch = await state.getAndUpdateFirstFetch()
                await onChange(urls, isFirstFetch, nil)
            } catch {
                if verbose {
                    logger.error("[\(caller)] Failed to scan directory: \(error.localizedDescription)")
                }
                await onChange([], false, error)
            }
        }
        
        // 设置事件处理
        monitor.setEventHandler {
            Task {
                await scanDirectory()
            }
        }
        
        // 设置取消处理
        monitor.setCancelHandler {
            close(fileDescriptor)
        }
        
        // 启动监听
        monitor.resume()
        
        // 执行初始扫描
        Task {
            await scanDirectory()
        }
        
        return AnyCancellable {
            if verbose {
                logger.info("[\(caller)] Stop monitoring directory: \(self.lastPathComponent)")
            }
            monitor.cancel()
        }
    }
    
    /// 监听 iCloud 文件夹内容变化
    /// - Parameters:
    ///   - verbose: 是否打印详细日志
    ///   - caller: 调用者名称
    ///   - onChange: 文件夹变化回调
    ///     - files: 文件URL列表
    ///     - isInitialFetch: 是否是初始的全量数据
    ///     - error: 可能发生的错误
    /// - Returns: 可用于取消监听的 AnyCancellable
    private func onICloudDirectoryChanged(
        verbose: Bool = true,
        caller: String,
        _ onChange: @escaping (_ files: [URL], _ isInitialFetch: Bool, _ error: Error?) -> Void,
        onDownloadProgress: @escaping (_ url: URL, _ progress: Double) -> Void
    ) -> AnyCancellable {
        let logger = Logger(subsystem: "MagicKit", category: "iCloudMonitor")
        let query = NSMetadataQuery()
        
        // 设置查询范围为指定文件夹
        query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        query.searchItems = [self]
        
        // 设置要监听的属性
        query.predicate = NSPredicate(format: "(%K BEGINSWITH %@)",
                                    NSMetadataItemPathKey,
                                    self.path)
        
        // 设置要获取的属性
        query.valueListAttributes = [
            NSMetadataItemURLKey,
            NSMetadataItemFSNameKey,
            NSMetadataUbiquitousItemIsDownloadingKey,
            NSMetadataUbiquitousItemDownloadingStatusKey,
            NSMetadataUbiquitousItemPercentDownloadedKey
        ]
        
        if verbose {
            logger.info("[\(caller)] Start monitoring iCloud directory: \(self.lastPathComponent)")
        }
        
        // 设置通知监听
        var cancellables = Set<AnyCancellable>()
        
        let notificationCenter = NotificationCenter.default
        
        // 监听查询完成通知
        notificationCenter.publisher(for: .NSMetadataQueryDidFinishGathering)
            .sink { [weak query] _ in
                guard let query = query else { return }
                processQueryResults(query: query, isInitial: true)
            }
            .store(in: &cancellables)
        
        // 监听查询更新通知
        notificationCenter.publisher(for: .NSMetadataQueryDidUpdate)
            .sink { [weak query] _ in
                guard let query = query else { return }
                processQueryResults(query: query, isInitial: false)
            }
            .store(in: &cancellables)
        
        func processQueryResults(query: NSMetadataQuery, isInitial: Bool) {
            query.disableUpdates()
            defer { query.enableUpdates() }
            
            let results = query.results as? [NSMetadataItem] ?? []
            let urls = results.compactMap { item -> URL? in
                guard let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL else {
                    return nil
                }
                
                // 检查文件是否正在下载
                if let isDownloading = item.value(forAttribute: NSMetadataUbiquitousItemIsDownloadingKey) as? Bool,
                   isDownloading {
                    // 获取下载进度
                    if let percentDownloaded = item.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double {
                        onDownloadProgress(url, percentDownloaded / 100.0)
                    }
                }
                
                if verbose {
                    logger.info("[\(caller)] File: \(url.lastPathComponent)")
                }
                
                return url
            }
            
            onChange(urls, isInitial, nil)
        }
        
        // 启动查询
        query.start()
        
        return AnyCancellable {
            if verbose {
                logger.info("[\(caller)] Stop monitoring iCloud directory: \(self.lastPathComponent)")
            }
            query.stop()
            cancellables.removeAll()
        }
    }
} 
