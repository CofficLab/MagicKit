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

        // 添加更详细的日志
        if verbose {
            logger.info("\(self.t)🔄 [\(caller)] Initializing iCloud query")
        }

        // 修改查询范围和谓词设置
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]

        // 修改谓词以确保正确匹配 iCloud 路径
        let predicateFormat = "(%K BEGINSWITH %@)"
        let searchPath = self.path
        query.predicate = NSPredicate(format: predicateFormat, NSMetadataItemPathKey, searchPath)

        // 输出谓词信息到日志
        if verbose {
            logger.info("\(self.t)🔍 [\(caller)] Search path: \(self.path)")
            logger.info("\(self.t)🎯 [\(caller)] Search scopes: \(query.searchScopes)")
        }

        // 添加更多相关属性以更好地跟踪文件状态
        query.valueListAttributes = [
            NSMetadataItemURLKey,
            NSMetadataItemFSNameKey,
            NSMetadataUbiquitousItemPercentDownloadedKey,
            NSMetadataUbiquitousItemIsDownloadingKey,
            NSMetadataUbiquitousItemIsUploadedKey,
            NSMetadataUbiquitousItemIsUploadingKey,
        ]

        // 设置通知监听
        var cancellables = Set<AnyCancellable>()

        let notificationCenter = NotificationCenter.default

        // 监听查询更新通知
        notificationCenter.publisher(for: .NSMetadataQueryDidUpdate)
            .sink { [weak query] notification in
                guard let query = query else { return }

                // 只处理增量更新
                if let changedItems = notification.userInfo?[NSMetadataQueryUpdateChangedItemsKey] as? [NSMetadataItem] {
                    if verbose {
                        logger.info("\(self.t)📢 [\(caller)] Processing \(changedItems.count) changed items")
                    }

                    // 只处理发生变化的项目的下载进度
                    for item in changedItems {
                        guard let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL else { continue }

                        if let isDownloading = item.value(forAttribute: NSMetadataUbiquitousItemIsDownloadingKey) as? Bool,
                           isDownloading,
                           let percentDownloaded = item.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double {
                            let progress = max(0.0, min(1.0, percentDownloaded / 100))
                            if verbose {
                                logger.info("\(self.t)📥 [\(caller)] Downloading: \(url.lastPathComponent) - \(Int(progress * 100))%")
                            }
                            DispatchQueue.main.async {
                                onProgress(url, progress)
                            }
                        }
                    }
                }
            }
            .store(in: &cancellables)

        // 监听查询完成通知（只在初始化时触发一次）
        notificationCenter.publisher(for: .NSMetadataQueryDidFinishGathering)
            .sink { [weak query] _ in
                if verbose {
                    logger.info("\(self.t)📢 [\(caller)] Received didFinishGathering notification")
                }
                guard let query = query else { return }
                processQueryResults(query: query, isInitial: true)
            }
            .store(in: &cancellables)

        // 添加查询启动失败的监听
        notificationCenter.publisher(for: .NSMetadataQueryDidStartGathering)
            .sink { [weak query] _ in
                if verbose {
                    logger.info("\(self.t)🚀 [\(caller)] Query did start gathering")
                }
            }
            .store(in: &cancellables)

        func processQueryResults(query: NSMetadataQuery, isInitial: Bool) {
            if verbose {
                logger.info("\(self.t)🔄 [\(caller)] Processing \(isInitial ? "initial" : "update") query results")
            }

            query.disableUpdates()
            defer { query.enableUpdates() }

            let results = query.results as? [NSMetadataItem] ?? []

            if verbose {
                logger.info("\(self.t)📊 [\(caller)] Raw results count: \(results.count)")
            }

            let urls = results.compactMap { item -> URL? in
                guard let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL else {
                    return nil
                }
                return url
            }

            if verbose {
                logger.info("\(self.t)📦 [\(caller)] Processed \(urls.count) valid URLs")
            }

            onChange(urls, isInitial, nil)
        }

        // 启动查询
        if verbose {
            logger.info("\(self.t)🚀 [\(caller)] Starting iCloud query")
        }

        DispatchQueue.main.async {
            query.start()
            if verbose {
                logger.info("\(self.t)✅ [\(caller)] Query started successfully")
            }
        }

        return AnyCancellable {
            if verbose {
                logger.info("[\(caller)] Stop monitoring iCloud directory: \(self.lastPathComponent)")
            }
            query.stop()
            cancellables.removeAll()
        }
    }
}

#if DEBUG

    // MARK: - Previews

    struct DirectoryMonitorPreview: View {
        @State private var files: [URL] = []
        @State private var downloadProgress: [URL: Double] = [:]
        @State private var isMonitoring = false
        @State private var selectedDirectory: URL?
        @State private var monitor: AnyCancellable?

        var body: some View {
            VStack {
                // 监控状态和目录选择
                HStack {
                    Button(isMonitoring ? "Stop Monitoring" : "Start Monitoring") {
                        if isMonitoring {
                            stopMonitoring()
                        } else {
                            selectDirectory()
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    if let dir = selectedDirectory {
                        Text(dir.lastPathComponent)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()

                // 文件列表
                List {
                    ForEach(files, id: \.absoluteString) { url in
                        VStack(alignment: .leading) {
                            Text(url.lastPathComponent)

                            // 如果有下载进度，显示进度条
                            if let progress = downloadProgress[url] {
                                ProgressView(value: progress) {
                                    Text("\(Int(progress * 100))%")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: 400, height: 600)
        }

        private func selectDirectory() {
            let panel = NSOpenPanel()
            panel.canChooseFiles = false
            panel.canChooseDirectories = true
            panel.allowsMultipleSelection = false

            if panel.runModal() == .OK, let url = panel.url {
                DispatchQueue.main.async {
                    selectedDirectory = url
                    startMonitoring(url: url)
                }
            }
        }

        private func startMonitoring(url: URL) {
            let newMonitor = url.onDirChange(
                caller: "Preview",
                { files, _, error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }
                    DispatchQueue.main.async {
                        self.files = files
                    }
                },
                onProgress: { url, progress in
                    DispatchQueue.main.async {
                        self.downloadProgress[url] = progress
                    }
                }
            )

            DispatchQueue.main.async {
                self.monitor = newMonitor
                self.isMonitoring = true
            }
        }

        private func stopMonitoring() {
            DispatchQueue.main.async {
                self.monitor?.cancel()
                self.monitor = nil
                self.isMonitoring = false
                self.files = []
                self.downloadProgress = [:]
            }
        }
    }

    #Preview {
        DirectoryMonitorPreview().inMagicContainer()
    }
#endif
