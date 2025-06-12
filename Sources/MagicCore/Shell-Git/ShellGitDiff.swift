import Foundation
import OSLog
import SwiftUI

extension ShellGit {
    /// 获取差异
    /// - Parameters:
    ///   - staged: 是否查看暂存区差异
    ///   - path: 仓库路径
    /// - Returns: 差异信息
    public static func diff(staged: Bool = false, at path: String? = nil) throws -> String {
        let option = staged ? "--cached" : ""
        return try Shell.run("git diff \(option)", at: path)
    }
    
    /// 获取文件差异
    /// - Parameters:
    ///   - file: 文件路径
    ///   - staged: 是否查看暂存区差异
    ///   - path: 仓库路径
    /// - Returns: 文件差异信息
    public static func diffFile(_ file: String, staged: Bool = false, at path: String? = nil) throws -> String {
        let option = staged ? "--cached" : ""
        return try Shell.run("git diff \(option) \(file)", at: path)
    }

    /// 获取指定 commit 下的文件内容
    /// - Parameters:
    ///   - file: 文件路径（相对仓库根目录）
    ///   - commit: commit 哈希（如 HEAD, HEAD~1, 某个具体 hash）
    ///   - path: 仓库路径
    /// - Returns: 文件内容字符串
    public static func fileContent(atCommit commit: String, file: String, at path: String? = nil) throws -> String {
        return try Shell.run("git show \(commit):\(file)", at: path)
    }

    /// 获取当前工作区的文件内容
    /// - Parameters:
    ///   - file: 文件路径（相对仓库根目录）
    ///   - path: 仓库路径
    /// - Returns: 文件内容字符串
    public static func fileContentInWorkingDirectory(file: String, at path: String? = nil) throws -> String {
        let fullPath = ((path?.hasSuffix("/") == true ? path! : (path ?? "") + "/") + file)
        return try String(contentsOfFile: fullPath, encoding: .utf8)
    }
}

#Preview("ShellGit+Diff Demo") {
    ShellGitDiffPreview()
        .inMagicContainer()
} 