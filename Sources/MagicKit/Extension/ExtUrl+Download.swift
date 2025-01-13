import Foundation
import OSLog
import SwiftUI

public extension URL {
    /// 获取文件的状态信息
    /// 
    /// 这个属性返回文件的当前状态描述，例如：
    /// - "远程文件"：表示文件是一个网络 URL
    /// - "本地文件"：表示文件存储在本地
    /// - "iCloud 文件"：表示文件存储在 iCloud 中
    /// - "正在从 iCloud 下载"：表示文件正在从 iCloud 下载
    var magicFileStatus: String? {
        if isNetworkURL {
            return "远程文件"
        } else if isFileURL {
            if isiCloud {
                if isDownloading {
                    return "正在从 iCloud 下载"
                } else if isDownloaded {
                    return "已从 iCloud 下载"
                } else {
                    return "未从 iCloud 下载"
                }
            }
            return isLocal ? "本地文件" : nil
        }
        return nil
    }

    /// 下载方式
    enum DownloadMethod {
        /// 轮询方式
        case polling(updateInterval: TimeInterval = 0.5)  // 默认 0.5 秒
        /// 使用 NSMetadataQuery
        case query
    }
    
    /// 下载 iCloud 文件
    /// - Parameters:
    ///   - verbose: 是否输出详细日志，默认为 false
    ///   - reason: 下载原因，用于日志记录，默认为空字符串
    ///   - method: 下载方式，默认为 .polling
    ///   - onProgress: 下载进度回调
    func download(
        verbose: Bool = false, 
        reason: String = "", 
        method: DownloadMethod = .polling(), 
        onProgress: ((Double) -> Void)? = nil
    ) async throws {
        // 通用的检查和日志
        guard isiCloud, isNotDownloaded else {
            if verbose {
                os_log("\(self.t)文件无需下载：不是 iCloud 文件或已下载完成")
            }
            return
        }
        
        if verbose {
            os_log("\(self.t)🛫🛫🛫 开始下载文件\(reason.isEmpty ? "" : "，原因：\(reason)")")
        }
        
        // 如果不需要进度回调，直接使用简单的下载方式
        guard let onProgress = onProgress else {
            try await FileManager.default.startDownloadingUbiquitousItem(at: self)
            if verbose {
                os_log("\(self.t)⏬⏬⏬ 已启动下载")
            }
            return
        }
        
        // 需要进度回调时，根据方法选择具体的下载实现
        switch method {
        case .polling(let updateInterval):
            try await downloadWithPolling(verbose: verbose, updateInterval: updateInterval, onProgress: onProgress)
        case .query:
            try await downloadWithQuery(verbose: verbose, onProgress: onProgress)
        }
    }
    
    /// 下载状态相关属性
    var isDownloaded: Bool {
        if isLocal {
            return true
        }
        
        if isiCloud {
            guard let resources = try? self.resourceValues(forKeys: [
                .ubiquitousItemDownloadingStatusKey
            ]) else {
                return false
            }
            
            guard let status = resources.ubiquitousItemDownloadingStatus else {
                return false
            }
            
            return status == .current
        }
        
        return false
    }
    
    /// 判断 URL 对应的文件是否正在从 iCloud 下载中
    /// - Returns: 如果文件是 iCloud 文件且正在下载返回 true，否则返回 false
    /// - Note: 此属性会检查以下条件：
    ///   1. 文件必须是 iCloud 文件
    ///   2. 文件当前状态必须是正在下载（URLUbiquitousItemDownloadingStatus）
    var isDownloading: Bool {
        // 首先确保是 iCloud 文件
        guard isiCloud else {
            return false
        }
        
        // 获取文件的下载状态
        guard let resources = try? self.resourceValues(forKeys: [
            .ubiquitousItemDownloadingStatusKey
        ]) else {
            return false
        }
        
        // 检查下载状态
        guard let status = resources.ubiquitousItemDownloadingStatus else {
            return false
        }
        
        // 使用原始字符串比较，因为 Apple 的 API 在不同系统版本中可能有差异
        return status.rawValue == "NSMetadataUbiquitousItemDownloadingStatusDownloading"
    }
    
    var isNotDownloaded: Bool {
        !isDownloaded
    }
    
    var isiCloud: Bool {
        guard let resources = try? self.resourceValues(forKeys: [.isUbiquitousItemKey]) else {
            return false
        }
        return resources.isUbiquitousItem ?? false
    }
    
    var isNotiCloud: Bool {
        !isiCloud
    }
    
    var isLocal: Bool {
        isNotiCloud
    }
    
    /// 创建下载按钮
    /// - Parameters:
    ///   - size: 按钮大小，默认为 28x28
    ///   - showLabel: 是否显示文字标签，默认为 false
    ///   - shape: 按钮形状，默认为圆形
    ///   - destination: 下载目标位置，如果为 nil 则只下载到 iCloud 本地
    /// - Returns: 下载按钮视图
    func makeDownloadButton(
        size: CGFloat = 28,
        showLabel: Bool = false,
        shape: MagicButton.Shape = .circle,
        destination: URL? = nil
    ) -> some View {
        DownloadButtonView(
            url: self,
            size: size,
            showLabel: showLabel,
            shape: shape,
            destination: destination
        )
    }
    
    /// 从本地驱动器中移除文件，但保留在 iCloud 中
    /// - Returns: 是否成功移除
    @discardableResult
    func evict() throws -> Bool {
        os_log("\(self.t)开始从本地移除文件: \(self.path)")
        
        guard isiCloud else {
            os_log("\(self.t)不是 iCloud 文件，无法执行移除操作")
            return false
        }
        
        guard isDownloaded else {
            os_log("\(self.t)文件未下载，无需移除")
            return true
        }
        
        do {
            try FileManager.default.evictUbiquitousItem(at: self)
            os_log("\(self.t)文件已从本地成功移除")
            return true
        } catch {
            os_log("\(self.t)移除文件失败: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// 移动文件到目标位置，支持 iCloud 文件
    /// - Parameter destination: 目标位置
    /// - Throws: 移动过程中的错误
    func moveTo(_ destination: URL) async throws {
        os_log("\(self.t)开始移动文件: \(self.path) -> \(destination.path)")
        
        if self.isiCloud && self.isNotDownloaded {
            os_log("\(self.t)检测到 iCloud 文件未下载，开始下载")
            try await download()
        }
        
        let coordinator = NSFileCoordinator()
        var coordinationError: NSError?
        var moveError: Error?
        
        coordinator.coordinate(
            writingItemAt: self,
            options: .forMoving,
            writingItemAt: destination,
            options: .forReplacing,
            error: &coordinationError
        ) { sourceURL, destinationURL in
            do {
                os_log("\(self.t)执行文件移动操作")
                try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
                os_log("\(self.t)文件移动完成")
            } catch {
                moveError = error
                os_log("\(self.t)移动文件失败: \(error.localizedDescription)")
            }
        }
        
        // 检查移动过程中是否发生错误
        if let error = moveError {
            throw error
        }
        
        // 检查协调过程中是否发生错误
        if let error = coordinationError {
            throw error
        }
    }
    
    /// 使用轮询方式下载 iCloud 文件
    private func downloadWithPolling(
        verbose: Bool,
        updateInterval: TimeInterval,
        onProgress: @escaping (Double) -> Void
    ) async throws {
        // 创建下载任务
        try FileManager.default.startDownloadingUbiquitousItem(at: self)
        
        // 等待下载完成
        while isDownloading {
            if verbose {
                os_log("\(self.t)文件下载中...")
            }
            
            // 获取下载进度
            if let resources = try? self.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey, .ubiquitousItemDownloadingErrorKey, .fileSizeKey, .fileAllocatedSizeKey]),
               let totalSize = resources.fileSize,
               let downloadedSize = resources.fileAllocatedSize {
                let progress = Double(downloadedSize) / Double(totalSize)
                onProgress(progress)
                
                // 检查是否有下载错误
                if let error = resources.ubiquitousItemDownloadingError {
                    throw error
                }
            }
            
            try await Task.sleep(nanoseconds: UInt64(updateInterval * 1_000_000_000)) // 转换为纳秒
        }
        
        if verbose {
            os_log("\(self.t)文件下载完成")
        }
    }
    
    /// 使用 NSMetadataQuery 下载 iCloud 文件
    /// - Parameters:
    ///   - verbose: 是否输出详细日志，默认为 false
    ///   - onProgress: 下载进度回调
    private func downloadWithQuery(
        verbose: Bool,
        onProgress: @escaping (Double) -> Void
    ) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let query = NSMetadataQuery()
            query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
            query.predicate = NSPredicate(format: "%K == %@", NSMetadataItemURLKey, self.path)
            
            var observers: [NSObjectProtocol] = []
            
            let startObserver = NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidStartGathering,
                object: query,
                queue: .main
            ) { _ in
                if verbose {
                    os_log("\(self.t)查询开始")
                }
                
                do {
                    try FileManager.default.startDownloadingUbiquitousItem(at: self)
                } catch {
                    observers.forEach { NotificationCenter.default.removeObserver($0) }
                    continuation.resume(throwing: error)
                }
            }
            observers.append(startObserver)
            
            let updateObserver = NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidUpdate,
                object: query,
                queue: .main
            ) { _ in
                guard let item = query.results.first as? NSMetadataItem else { return }
                
                let downloadStatus = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String
                let isDownloading = downloadStatus == "NSMetadataUbiquitousItemDownloadingStatusDownloading"
                
                if isDownloading {
                    // 现在一定会计算进度
                    if let downloadedSize = item.value(forAttribute: "NSMetadataUbiquitousItemDownloadedSizeKey") as? NSNumber,
                       let totalSize = item.value(forAttribute: "NSMetadataUbiquitousItemTotalSizeKey") as? NSNumber {
                        let progress = Double(truncating: downloadedSize) / Double(truncating: totalSize)
                        onProgress(progress)
                        
                        if verbose {
                            os_log("\(self.t)下载进度：\(progress * 100)%")
                        }
                    }
                    
                    if let error = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingErrorKey) as? Error {
                        observers.forEach { NotificationCenter.default.removeObserver($0) }
                        query.stop()
                        continuation.resume(throwing: error)
                    }
                } else if downloadStatus == "NSMetadataUbiquitousItemDownloadingStatusCurrent" {
                    if verbose {
                        os_log("\(self.t)文件下载完成")
                    }
                    observers.forEach { NotificationCenter.default.removeObserver($0) }
                    query.stop()
                    continuation.resume(returning: ())
                }
            }
            observers.append(updateObserver)
            
            let finishObserver = NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidFinishGathering,
                object: query,
                queue: .main
            ) { _ in
                if verbose {
                    os_log("\(self.t)查询完成")
                }
            }
            observers.append(finishObserver)
            
            query.start()
        }
    }
    
    /// 获取文件的下载进度
    /// - Returns: 下载进度（0.0 到 1.0 之间）
    ///   - 对于本地文件，返回 1.0
    ///   - 对于 iCloud 文件，返回实际下载进度
    ///   - 如果无法获取进度信息，返回 0.0
    var downloadProgress: Double {
        // 如果是本地文件，直接返回 1.0
        if isLocal {
            return 1.0
        }
        
        // 如果是 iCloud 文件，获取下载进度
        if isiCloud {
            guard let resources = try? self.resourceValues(forKeys: [
                .fileSizeKey,
                .fileAllocatedSizeKey
            ]) else {
                return 0.0
            }
            
            guard let totalSize = resources.fileSize,
                  let downloadedSize = resources.fileAllocatedSize else {
                return 0.0
            }
            
            return Double(downloadedSize) / Double(totalSize)
        }
        
        return 0.0
    }
}

#Preview {
    DownloadButtonPreview()
}
