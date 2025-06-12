import Foundation
import OSLog
import SwiftUI

extension ShellGit {
    /// 推送到远程仓库
    /// - Parameters:
    ///   - remote: 远程仓库名称，默认为origin
    ///   - branch: 分支名称，默认为当前分支
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    @discardableResult
    public static func push(remote: String = "origin", branch: String? = nil, at path: String? = nil) throws -> String {
        let command = branch != nil ? "git push \(remote) \(branch!)" : "git push \(remote)"
        return try Shell.run(command, at: path)
    }
    
    /// 从远程仓库拉取
    /// - Parameters:
    ///   - remote: 远程仓库名称，默认为origin
    ///   - branch: 分支名称，默认为当前分支
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    @discardableResult
    public static func pull(remote: String = "origin", branch: String? = nil, at path: String? = nil) throws -> String {
        let command = branch != nil ? "git pull \(remote) \(branch!)" : "git pull \(remote)"
        return try Shell.run(command, at: path)
    }
    
    /// 添加远程仓库
    /// - Parameters:
    ///   - name: 远程仓库名称
    ///   - url: 远程仓库URL
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func addRemote(_ name: String, url: String, at path: String? = nil) throws -> String {
        return try Shell.run("git remote add \(name) \(url)", at: path)
    }
    
    /// 获取远程仓库列表
    /// - Parameters:
    ///   - verbose: 是否显示详细信息
    ///   - path: 仓库路径
    /// - Returns: 远程仓库列表，字符串形式
    public static func remotes(verbose: Bool = false, at path: String? = nil) throws -> String {
        let option = verbose ? "-v" : ""
        return try Shell.run("git remote \(option)", at: path)
    }

    /// 获取远程仓库列表-数组
    /// - Parameters:
    ///   - verbose: 是否显示详细信息
    ///   - path: 仓库路径
    /// - Returns: 远程仓库列表，字符串数组形式
    public static func remotesArray(verbose: Bool = false, at path: String? = nil) throws -> [String] {
        let output = try remotes(verbose: verbose, at: path)
        return output.split(separator: "\n").map { String($0) }
    }

    /// 获取第一个远程仓库的URL
    /// - Parameter path: 仓库路径
    /// - Returns: 第一个远程仓库的URL，如果不存在则返回nil
    public static func firstRemoteURL(at path: String? = nil) throws -> String? {
        let output = try Shell.run("git remote -v", at: path)
        let lines = output.split(separator: "\n").map { String($0) }
        guard let firstLine = lines.first else { return nil }
        // 示例输出: origin	https://github.com/user/repo.git (fetch)
        let components = firstLine.split(separator: "\t").map { String($0) }
        guard components.count > 1 else { return nil }
        let urlPart = components[1]
        let url = urlPart.split(separator: " ").first.map { String($0) }
        return url
    }
    
    /// 删除远程仓库
    /// - Parameters:
    ///   - name: 远程仓库名称
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func removeRemote(_ name: String, at path: String? = nil) throws -> String {
        return try Shell.run("git remote remove \(name)", at: path)
    }
}

#Preview("ShellGit+Remote Demo") {
    ShellGitRemotePreview()
        .inMagicContainer()
} 
