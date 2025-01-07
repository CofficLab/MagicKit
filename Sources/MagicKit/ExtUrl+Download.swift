import Foundation
import OSLog
import SwiftUI
import MagicUI

public extension URL {
    /// 复制文件到目标位置，支持 iCloud 文件的自动下载
    /// - Parameters:
    ///   - destination: 目标位置
    ///   - downloadProgress: 下载进度回调
    func copyTo(_ destination: URL, downloadProgress: ((Double) -> Void)? = nil) async throws {
        os_log("\(self.t)开始复制文件: \(self.path) -> \(destination.path)")
        
        if self.isiCloud && self.isNotDownloaded {
            os_log("\(self.t)检测到 iCloud 文件未下载，开始下载")
            try await download(onProgress: downloadProgress)
        }
        
        os_log("\(self.t)执行文件复制操作")
        try FileManager.default.copyItem(at: self, to: destination)
        os_log("\(self.t)文件复制完成")
    }
    
    /// 下载 iCloud 文件
    /// - Parameter onProgress: 下载进度回调
    func download(onProgress: ((Double) -> Void)? = nil) async throws {
        let fm = FileManager.default
        
        if self.isDownloaded {
            os_log("\(self.t)文件已下载，无需重新下载")
            onProgress?(100)
            return
        }
        
        os_log("\(self.t)开始下载 iCloud 文件: \(self.path)")
        try fm.startDownloadingUbiquitousItem(at: self)
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let itemQuery = ItemQuery(queue: queue)
        
        let result = itemQuery.searchMetadataItems(predicates: [
            NSPredicate(format: "%K == %@", NSMetadataItemURLKey, self as NSURL),
        ])
        
        for try await collection in result {
            if let item = collection.first {
                let progress = item.downloadProgress
                os_log("\(self.t)下载进度: \(progress)%")
                onProgress?(progress)
                
                if item.isDownloaded {
                    os_log("\(self.t)文件下载完成")
                    onProgress?(100)
                    itemQuery.stop()
                    break
                }
            }
        }
    }
    
    /// 下载状态相关属性
    var isDownloaded: Bool {
        if isLocal {
            // 本地文件，已下载
            return true
        }
        
        if isiCloud {
            // iCloud 文件，检查是否已下载
            guard let resources = try? self.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey]) else {
                return false
            }
            
            guard let status = resources.ubiquitousItemDownloadingStatus else {
                return false
            }
            
            return status == .current || status == .downloaded
        }
        
        // Web 链接，未下载
        return false
    }
    
    var isDownloading: Bool {
        guard isiCloud,
              let resources = try? self.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey]),
              let status = resources.ubiquitousItemDownloadingStatus else {
            return false
        }
        
        // 检查是否不是这三种状态，如果都不是，则表示正在下载
        return !(status == .current || status == .downloaded || status == .notDownloaded)
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
} 
