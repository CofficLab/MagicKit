import Foundation
import OSLog
import SwiftUI

extension ShellGit {
    /// 切换分支
    /// - Parameters:
    ///   - branch: 分支名称
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func checkout(_ branch: String, at path: String? = nil) throws -> String {
        return try Shell.runSync("git checkout \(branch)", at: path)
    }
    
    /// 创建并切换到新分支
    /// - Parameters:
    ///   - branch: 分支名称
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func checkoutNewBranch(_ branch: String, at path: String? = nil) throws -> String {
        return try Shell.runSync("git checkout -b \(branch)", at: path)
    }
    
    /// 检出指定文件到工作区
    /// - Parameters:
    ///   - files: 要检出的文件路径数组
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func checkoutFiles(_ files: [String], at path: String? = nil) throws -> String {
        let filesStr = files.joined(separator: " ")
        return try Shell.runSync("git checkout -- \(filesStr)", at: path)
    }
    
    /// 检出指定文件（单个文件）
    /// - Parameters:
    ///   - file: 要检出的文件路径
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func checkoutFile(_ file: String, at path: String? = nil) throws -> String {
        return try Shell.runSync("git checkout -- \(file)", at: path)
    }
    
    /// 从指定提交检出文件
    /// - Parameters:
    ///   - commit: 提交哈希
    ///   - file: 文件路径
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func checkoutFileFromCommit(_ commit: String, file: String, at path: String? = nil) throws -> String {
        return try Shell.runSync("git checkout \(commit) -- \(file)", at: path)
    }
    
    /// 切换到指定提交（分离头指针状态）
    /// - Parameters:
    ///   - commit: 提交哈希
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func checkoutCommit(_ commit: String, at path: String? = nil) throws -> String {
        return try Shell.runSync("git checkout \(commit)", at: path)
    }
    
    /// 切换到远程分支并创建本地跟踪分支
    /// - Parameters:
    ///   - remoteBranch: 远程分支名称（如 origin/feature-branch）
    ///   - localBranch: 本地分支名称，如果为空则使用远程分支名
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func checkoutRemoteBranch(_ remoteBranch: String, as localBranch: String? = nil, at path: String? = nil) throws -> String {
        if let localBranch = localBranch {
            return try Shell.runSync("git checkout -b \(localBranch) \(remoteBranch)", at: path)
        } else {
            // 提取远程分支的分支名（去掉 origin/ 前缀）
            let branchName = remoteBranch.components(separatedBy: "/").last ?? remoteBranch
            return try Shell.runSync("git checkout -b \(branchName) \(remoteBranch)", at: path)
        }
    }
    
    /// 强制切换分支（丢弃未提交的更改）
    /// - Parameters:
    ///   - branch: 分支名称
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func checkoutForce(_ branch: String, at path: String? = nil) throws -> String {
        return try Shell.runSync("git checkout -f \(branch)", at: path)
    }
    
    /// 检出所有文件到工作区（撤销所有未暂存的更改）
    /// - Parameter path: 仓库路径
    /// - Returns: 执行结果
    public static func checkoutAllFiles(at path: String? = nil) throws -> String {
        return try Shell.runSync("git checkout -- .", at: path)
    }
}

#Preview("ShellGit+Checkout Demo") {
    ShellGitCheckoutPreview()
        .inMagicContainer()
} 