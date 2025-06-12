import Foundation
import OSLog
import SwiftUI

extension ShellGit {
    /// 提交暂存区的变更
    /// - Parameters:
    ///   - message: 提交信息
    ///   - path: 仓库路径
    /// - Returns: 提交的哈希值
    @discardableResult
    public static func commit(message: String, at path: String? = nil) throws -> String {
        let output = try Shell.run("git commit -m \"\(message)\"", at: path)
        // 从输出中提取提交哈希
        if let match = output.range(of: "[0-9a-f]{40}", options: .regularExpression) {
            return String(output[match])
        }
        throw NSError(domain: "ShellGit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get commit hash"])
    }
    
    /// 添加并提交文件
    /// - Parameters:
    ///   - files: 要提交的文件路径数组，为空则提交所有文件
    ///   - message: 提交信息
    ///   - path: 仓库路径
    /// - Returns: 提交的哈希值
    @discardableResult
    public static func addAndCommit(files: [String] = [], message: String, at path: String? = nil) throws -> String {
        try add(files, at: path)
        return try commit(message: message, at: path)
    }
}

#Preview("ShellGit+Commit Demo") {
    ShellGitCommitPreview()
        .inMagicContainer()
} 
