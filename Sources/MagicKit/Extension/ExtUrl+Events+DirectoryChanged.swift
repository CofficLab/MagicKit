import Foundation
import Combine
import SwiftUI
import OSLog
import Darwin

public extension URL {
    /// 监听文件夹内容变化
    /// - Parameters:
    ///   - verbose: 是否打印详细日志
    ///   - caller: 调用者名称
    ///   - onChange: 文件夹变化回调
    ///     - files: 文件列表
    ///     - isInitialFetch: 是否是初始的全量数据
    ///     - error: 可能发生的错误
    /// - Returns: 可用于取消监听的 AnyCancellable
    func onDirectoryChanged(
        verbose: Bool = true,
        caller: String,
        _ onChange: @escaping (_ files: [URL], _ isInitialFetch: Bool, _ error: Error?) async -> Void
    ) -> AnyCancellable {
        let logger = Logger(subsystem: "MagicKit", category: "FileMonitor")
        
        // 创建文件监视器
        let fileDescriptor = Darwin.open(self.path, O_EVTONLY)
        if fileDescriptor < 0 {
            logger.error("Failed to open file descriptor for \(self.path)")
            return AnyCancellable {}
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
            // 在函数内部创建 FileManager 实例，而不是捕获外部实例
            let fileManager = FileManager.default
            
            guard fileManager.fileExists(atPath: self.path) else {
                throw URLError(.fileDoesNotExist)
            }
            
            let urls = try fileManager.contentsOfDirectory(
                at: self,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: [.skipsHiddenFiles]
            )
            
            if verbose {
                logger.info("[\(caller)] Directory content updated: \(self.lastPathComponent)")
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
} 
