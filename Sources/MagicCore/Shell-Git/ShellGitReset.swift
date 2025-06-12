import Foundation
import OSLog
import SwiftUI

extension ShellGit {
    /// 重置文件或文件夹到指定状态
    /// - Parameters:
    ///   - files: 要重置的文件路径数组，如果为空则重置所有文件
    ///   - mode: 重置模式 (--hard, --soft, --mixed)
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func reset(_ files: [String] = [], mode: String? = nil, at path: String? = nil) throws -> String {
        var command = "git reset"
        if let mode = mode {
            command += " \(mode)"
        }
        if !files.isEmpty {
            command += " -- " + files.joined(separator: " ")
        }
        return try Shell.run(command, at: path)
    }
    
    /// 硬重置到指定提交
    /// - Parameters:
    ///   - commitHash: 提交哈希值，如果为空则重置到HEAD
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func resetHard(_ commitHash: String? = nil, at path: String? = nil) throws -> String {
        let target = commitHash ?? "HEAD"
        return try Shell.run("git reset --hard \(target)", at: path)
    }
    
    /// 软重置到指定提交
    /// - Parameters:
    ///   - commitHash: 提交哈希值，如果为空则重置到HEAD
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func resetSoft(_ commitHash: String? = nil, at path: String? = nil) throws -> String {
        let target = commitHash ?? "HEAD"
        return try Shell.run("git reset --soft \(target)", at: path)
    }
    
    /// 混合重置到指定提交
    /// - Parameters:
    ///   - commitHash: 提交哈希值，如果为空则重置到HEAD
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func resetMixed(_ commitHash: String? = nil, at path: String? = nil) throws -> String {
        let target = commitHash ?? "HEAD"
        return try Shell.run("git reset --mixed \(target)", at: path)
    }
    
    /// 重置指定文件到HEAD状态
    /// - Parameters:
    ///   - file: 文件路径
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func resetFile(_ file: String, at path: String? = nil) throws -> String {
        return try Shell.run("git reset HEAD \(file)", at: path)
    }
    
    /// 重置所有暂存区文件
    /// - Parameter path: 仓库路径
    /// - Returns: 执行结果
    public static func resetStaged(at path: String? = nil) throws -> String {
        return try Shell.run("git reset HEAD", at: path)
    }
}

#Preview("ShellGit+Reset Demo") {
    ShellGitResetPreview()
        .inMagicContainer()
} 