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
}

#Preview("ShellGit+Branch Demo") {
    ShellGitBranchPreview()
        .inMagicContainer()
} 
