import Foundation
import OSLog
import SwiftUI

extension ShellGit {
    /// 获取提交日志
    /// - Parameters:
    ///   - limit: 限制条数
    ///   - oneline: 是否单行显示
    ///   - path: 仓库路径
    /// - Returns: 日志信息
    public static func log(limit: Int = 10, oneline: Bool = true, at path: String? = nil) throws -> String {
        let format = oneline ? "--oneline" : ""
        return try Shell.run("git log \(format) -\(limit)", at: path)
    }
    
    /// 获取提交日志（字符串数组）
    /// - Parameters:
    ///   - limit: 限制条数
    ///   - oneline: 是否单行显示
    ///   - path: 仓库路径
    /// - Returns: 日志信息数组
    public static func logArray(limit: Int = 10, oneline: Bool = true, at path: String? = nil) throws -> [String] {
        let logString = try log(limit: limit, oneline: oneline, at: path)
        return logString.split(separator: "\n").map { String($0) }
    }
    
    /// 获取本地未推送到远程的提交日志
    /// - Parameters:
    ///   - remote: 远程仓库名，默认 origin
    ///   - branch: 分支名，默认当前分支
    ///   - path: 仓库路径
    /// - Returns: 未推送的提交日志（字符串数组）
    public static func unpushedCommits(remote: String = "origin", branch: String? = nil, at path: String? = nil) throws -> [String] {
        let branchName: String
        if let branch = branch {
            branchName = branch
        } else {
            branchName = try currentBranch(at: path)
        }
        let log = try Shell.run("git log \(remote)/\(branchName)..\(branchName) --oneline", at: path)
        return log.split(separator: "\n").map { String($0) }
    }
}

#Preview("ShellGit+Log Demo") {
    ShellGitLogPreview()
        .inMagicContainer()
} 