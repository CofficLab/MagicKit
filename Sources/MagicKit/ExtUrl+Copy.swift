import Foundation
import OSLog
import SwiftUI
import MagicUI

public extension URL {
    /// 复制文件到目标位置，支持 iCloud 文件的自动下载
    /// - Parameters:
    ///   - destination: 目标位置
    ///   - downloadProgress: 下载进度回调
    ///   - verbose: 是否打印详细日志，默认为 false
    ///   - reason: 复制原因，用于日志记录
    func copyTo(
        _ destination: URL,
        verbose: Bool = false,
        reason: String,
        downloadProgress: ((Double) -> Void)? = nil
    ) async throws {
        if verbose {
            os_log("\(self.t)开始复制文件 (\(reason)): \(self.path) -> \(destination.path)")
        }
        
        if self.isiCloud && self.isNotDownloaded {
            if verbose {
                os_log("\(self.t)检测到 iCloud 文件未下载，开始下载")
            }
            try await download(onProgress: downloadProgress)
        }
        
        if verbose {
            os_log("\(self.t)🚛🚛🚛 执行文件复制操作")
        }
        try FileManager.default.copyItem(at: self, to: destination)
        if verbose {
            os_log("\(self.t)✅✅✅ 文件复制完成")
        }
    }
}

#Preview("Copy View") {
    CopyViewPreviewContainer()
}
