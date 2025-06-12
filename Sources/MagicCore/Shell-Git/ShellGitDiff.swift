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

    /// 获取某个 commit 前后的文件内容
    /// - Parameters:
    ///   - commit: commit 哈希
    ///   - file: 文件路径（相对仓库根目录）
    ///   - repoPath: 仓库本地路径
    /// - Returns: (修改前内容, 修改后内容)
    public static func fileContentChange(at commit: String, file: String, repoPath: String) throws -> (before: String?, after: String?) {
        // 获取 parent commit
        let parentCommit = try Shell.run("git rev-parse \(commit)^", at: repoPath).trimmingCharacters(in: .whitespacesAndNewlines)
        let before = try? Shell.run("git show \(parentCommit):\(file)", at: repoPath)
        let after = try? Shell.run("git show \(commit):\(file)", at: repoPath)
        return (before, after)
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

    /// 获取所有变动文件及其 diff 内容（结构体版）
    /// - Parameters:
    ///   - staged: 是否查看暂存区差异
    ///   - path: 仓库路径
    /// - Returns: [GitDiffFile]
    public static func diffFileList(staged: Bool = false, at path: String? = nil) throws -> [GitDiffFile] {
        let option = staged ? "--cached" : ""
        // 获取变动文件及类型
        let nameStatus = try Shell.run("git diff --name-status \(option)", at: path)
        let files = nameStatus.split(separator: "\n").map { String($0) }
        var result: [GitDiffFile] = []
        for line in files {
            let parts = line.split(separator: "\t").map { String($0) }
            guard parts.count >= 2 else { continue }
            let changeType = parts[0]
            let file = parts[1]
            let diff = (try? Shell.run("git diff \(option) -- \(file)", at: path)) ?? ""
            result.append(GitDiffFile(id: file, file: file, changeType: changeType, diff: diff))
        }
        return result
    }

    /// 获取指定 commit 涉及的所有文件变动及 diff 内容（结构体版）
    /// - Parameters:
    ///   - commit: commit 哈希
    ///   - path: 仓库路径
    /// - Returns: [GitDiffFile]
    public static func fileChanges(in commit: String, at path: String? = nil) throws -> [GitDiffFile] {
        let nameStatus = try Shell.run("git diff-tree --no-commit-id --name-status -r \(commit)", at: path)
        let files = nameStatus.split(separator: "\n").map { String($0) }
        var result: [GitDiffFile] = []
        for line in files {
            let parts = line.split(separator: "\t").map { String($0) }
            guard parts.count >= 2 else { continue }
            let changeType = parts[0]
            let file = parts[1]
            let diff = (try? Shell.run("git show \(commit):\(file)", at: path)) ?? ""
            result.append(GitDiffFile(id: file, file: file, changeType: changeType, diff: diff))
        }
        return result
    }
}

#Preview("ShellGit+Diff Demo") {
    ShellGitDiffPreview()
        .inMagicContainer()
} 
