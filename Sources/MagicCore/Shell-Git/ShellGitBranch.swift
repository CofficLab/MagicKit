import Foundation
import OSLog
import SwiftUI

extension ShellGit {
    /// 获取分支列表
    /// - Parameters:
    ///   - includeRemote: 是否包含远程分支
    ///   - path: 仓库路径
    /// - Returns: 分支列表
    public static func branches(includeRemote: Bool = false, at path: String? = nil) throws -> String {
        let option = includeRemote ? "-a" : ""
        return try Shell.run("git branch \(option)", at: path)
    }

    /// 获取分支列表并返回字符串数组
    /// - Parameters:
    ///   - includeRemote: 是否包含远程分支
    ///   - path: 仓库路径
    /// - Returns: 分支名称字符串数组
    public static func branchesArray(includeRemote: Bool = false, at path: String? = nil) throws -> [String] {
        let branchesString = try branches(includeRemote: includeRemote, at: path)
        return branchesString.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "* ", with: "") }.filter { !$0.isEmpty }
    }
    
    /// 获取当前分支
    /// - Parameter path: 仓库路径
    /// - Returns: 当前分支名
    public static func currentBranch(at path: String? = nil) throws -> String {
        return try Shell.run("git branch --show-current", at: path)
    }
    
    /// 创建新分支
    /// - Parameters:
    ///   - name: 分支名称
    ///   - checkout: 是否切换到新分支
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func createBranch(_ name: String, checkout: Bool = false, at path: String? = nil) throws -> String {
        let command = checkout ? "git checkout -b \(name)" : "git branch \(name)"
        return try Shell.run(command, at: path)
    }
    
    /// 切换分支
    /// - Parameters:
    ///   - name: 分支名称
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func checkout(_ name: String, at path: String? = nil) throws -> String {
        return try Shell.run("git checkout \(name)", at: path)
    }
    
    /// 删除分支
    /// - Parameters:
    ///   - name: 分支名称
    ///   - force: 是否强制删除
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func deleteBranch(_ name: String, force: Bool = false, at path: String? = nil) throws -> String {
        let option = force ? "-D" : "-d"
        return try Shell.run("git branch \(option) \(name)", at: path)
    }
    
    /// 合并分支
    /// - Parameters:
    ///   - branch: 要合并的分支
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func merge(_ branch: String, at path: String? = nil) throws -> String {
        return try Shell.run("git merge \(branch)", at: path)
    }

    /// 获取分支结构体列表
    /// - Parameters:
    ///   - includeRemote: 是否包含远程分支
    ///   - path: 仓库路径
    /// - Returns: 分支结构体数组
    public static func branchList(includeRemote: Bool = false, at path: String? = nil) throws -> [GitBranch] {
        let branchesString = try branches(includeRemote: includeRemote, at: path)
        let lines = branchesString.split(separator: "\n").map { String($0) }
        let currentBranchName = try? currentBranch(at: path)
        var result: [GitBranch] = []
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let isCurrent = trimmed.hasPrefix("*")
            let name = trimmed.replacingOccurrences(of: "* ", with: "")
            // 获取上游、最新 commit hash/message 可后续扩展
            result.append(GitBranch(id: name, name: name, isCurrent: currentBranchName == name, upstream: nil, latestCommitHash: "", latestCommitMessage: ""))
        }
        return result
    }

    /// 获取当前分支（结构体版）
    /// - Parameter path: 仓库路径
    /// - Returns: 当前分支 GitBranch 结构体
    public static func currentBranchInfo(at path: String? = nil) throws -> GitBranch? {
        let name = try currentBranch(at: path).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return nil }
        // 可扩展：获取上游、最新 commit hash/message
        return GitBranch(id: name, name: name, isCurrent: true, upstream: nil, latestCommitHash: "", latestCommitMessage: "")
    }
}

#Preview("ShellGit+Branch Demo") {
    ShellGitBranchPreview()
        .inMagicContainer()
} 
