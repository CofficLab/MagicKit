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
    
    /// 获取两个提交之间的差异
    /// - Parameters:
    ///   - from: 起始提交
    ///   - to: 目标提交
    ///   - path: 仓库路径
    /// - Returns: 差异信息
    public static func diffBetweenCommits(from: String, to: String, at path: String? = nil) throws -> String {
        return try Shell.run("git diff \(from) \(to)", at: path)
    }
    
    /// 检查文件在指定commit中是否存在
    /// - Parameters:
    ///   - commit: commit哈希
    ///   - file: 文件路径
    ///   - repoPath: 仓库路径
    /// - Returns: 文件是否存在
    private static func fileExists(at commit: String, file: String, repoPath: String) -> Bool {
        do {
            _ = try Shell.run("git cat-file -e \(commit):\(file)", at: repoPath)
            return true
        } catch {
            return false
        }
    }
    
    /// 获取某个 commit 前后的文件内容
    /// - Parameters:
    ///   - commit: commit 哈希
    ///   - file: 文件路径（相对仓库根目录）
    ///   - repoPath: 仓库本地路径
    /// - Returns: (修改前内容, 修改后内容)
    ///   - before: 父commit中的文件内容，如果文件在父commit中不存在则为nil
    ///   - after: 当前commit中的文件内容，如果文件在当前commit中不存在则为nil
    /// - Note: 
    ///   - 如果文件是新增的：before为nil，after为文件内容
    ///   - 如果文件是删除的：before为文件内容，after为nil
    ///   - 如果文件是修改的：before和after都为文件内容
    ///   - 如果文件在两个commit中都不存在：before和after都为nil
    public static func fileContentChange(at commit: String, file: String, repoPath: String) throws -> (before: String?, after: String?) {
        // 获取 parent commit
        let parentCommit = try Shell.run("git rev-parse \(commit)^", at: repoPath).trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 先检查文件是否存在，再获取内容
        let before: String? = fileExists(at: parentCommit, file: file, repoPath: repoPath) 
            ? try Shell.run("git show \(parentCommit):\(file)", at: repoPath)
            : nil
            
        let after: String? = fileExists(at: commit, file: file, repoPath: repoPath)
            ? try Shell.run("git show \(commit):\(file)", at: repoPath) 
            : nil
        
        return (before, after)
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
    
    /// 获取指定 commit 变动的文件名列表
    /// - Parameters:
    ///   - commit: commit 哈希
    ///   - path: 仓库路径
    /// - Returns: 文件名数组
    public static func changedFiles(in commit: String, at path: String? = nil) throws -> [String] {
        let output = try Shell.run("git diff-tree --no-commit-id --name-only -r \(commit)", at: path)
        return output.split(separator: "\n").map { String($0) }
    }
    
    /// 获取指定 commit 变动的文件列表（结构体版）
    /// - Parameters:
    ///   - commit: commit 哈希
    ///   - path: 仓库路径
    /// - Returns: [GitDiffFile]，仅包含文件名和变动类型，diff 为空
    public static func changedFilesDetail(in commit: String, at path: String? = nil) throws -> [GitDiffFile] {
        let output = try Shell.run("git diff-tree --no-commit-id --name-status -r \(commit)", at: path)
        let files = output.split(separator: "\n").map { String($0) }
        return files.compactMap { line in
            let parts = line.split(separator: "\t").map { String($0) }
            guard parts.count >= 2 else { return nil }
            let changeType = parts[0]
            let file = parts[1]
            return GitDiffFile(id: file, file: file, changeType: changeType, diff: "")
        }
    }

    /// 获取未提交文件的变动前后内容
    /// - Parameters:
    ///   - file: 文件路径（相对仓库根目录）
    ///   - repoPath: 仓库本地路径
    /// - Returns: (修改前内容, 修改后内容)
    public static func uncommittedFileContentChange(file: String, repoPath: String) throws -> (before: String?, after: String?) {
        // 获取 HEAD 中的文件内容（修改前）
        let before = try? Shell.run("git show HEAD:\(file)", at: repoPath)
        // 获取工作区中的文件内容（修改后）
        let after = try? String(contentsOfFile: repoPath + "/" + file, encoding: .utf8)
        return (before, after)
    }
    
    /// 检查是否有文件待提交（暂存区是否有内容）
    /// - Parameter path: 仓库路径
    /// - Returns: 是否有文件待提交
    public static func hasFilesToCommit(at path: String? = nil) throws -> Bool {
        let output = try Shell.run("git diff --cached --name-only", at: path)
        return !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview("ShellGit+Diff Demo") {
    ShellGitDiffPreview()
        .inMagicContainer()
} 
