import Foundation
import OSLog
import SwiftUI

/// Git命令执行类
/// 提供常用的Git操作功能
public class ShellGit: SuperLog {
    public static let emoji = "🔧"
    
    /// 初始化Git仓库
    /// - Parameter path: 仓库路径
    /// - Returns: 执行结果
    static func initRepository(at path: String) throws -> String {
        return try Shell.run("git init", at: path)
    }
    
    /// 克隆远程仓库
    /// - Parameters:
    ///   - url: 远程仓库URL
    ///   - path: 本地路径
    /// - Returns: 执行结果
    static func clone(_ url: String, to path: String? = nil) throws -> String {
        let command = path != nil ? "git clone \(url) \(path!)" : "git clone \(url)"
        return try Shell.run(command)
    }
    
    /// 添加文件到暂存区
    /// - Parameters:
    ///   - files: 文件路径数组，如果为空则添加所有文件
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    static func add(_ files: [String] = [], at path: String? = nil) throws -> String {
        let fileList = files.isEmpty ? "." : files.joined(separator: " ")
        return try Shell.run("git add \(fileList)", at: path)
    }
    
    /// 提交更改
    /// - Parameters:
    ///   - message: 提交信息
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    static func commit(_ message: String, at path: String? = nil) throws -> String {
        return try Shell.run("git commit -m \"\(message)\"", at: path)
    }
    
    /// 推送到远程仓库
    /// - Parameters:
    ///   - remote: 远程仓库名称，默认为origin
    ///   - branch: 分支名称，默认为当前分支
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    static func push(remote: String = "origin", branch: String? = nil, at path: String? = nil) throws -> String {
        let command = branch != nil ? "git push \(remote) \(branch!)" : "git push \(remote)"
        return try Shell.run(command, at: path)
    }
    
    /// 从远程仓库拉取
    /// - Parameters:
    ///   - remote: 远程仓库名称，默认为origin
    ///   - branch: 分支名称，默认为当前分支
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    static func pull(remote: String = "origin", branch: String? = nil, at path: String? = nil) throws -> String {
        let command = branch != nil ? "git pull \(remote) \(branch!)" : "git pull \(remote)"
        return try Shell.run(command, at: path)
    }
    
    /// 获取仓库状态
    /// - Parameter path: 仓库路径
    /// - Returns: 状态信息
    static func status(at path: String? = nil) throws -> String {
        return try Shell.run("git status --porcelain", at: path)
    }
    
    /// 获取详细状态
    /// - Parameter path: 仓库路径
    /// - Returns: 详细状态信息
    static func statusVerbose(at path: String? = nil) throws -> String {
        return try Shell.run("git status", at: path)
    }
    
    /// 获取提交日志
    /// - Parameters:
    ///   - limit: 限制条数
    ///   - oneline: 是否单行显示
    ///   - path: 仓库路径
    /// - Returns: 日志信息
    static func log(limit: Int = 10, oneline: Bool = true, at path: String? = nil) throws -> String {
        let format = oneline ? "--oneline" : ""
        return try Shell.run("git log \(format) -\(limit)", at: path)
    }
    
    /// 获取分支列表
    /// - Parameters:
    ///   - includeRemote: 是否包含远程分支
    ///   - path: 仓库路径
    /// - Returns: 分支列表
    static func branches(includeRemote: Bool = false, at path: String? = nil) throws -> String {
        let option = includeRemote ? "-a" : ""
        return try Shell.run("git branch \(option)", at: path)
    }
    
    /// 获取当前分支
    /// - Parameter path: 仓库路径
    /// - Returns: 当前分支名
    static func currentBranch(at path: String? = nil) throws -> String {
        return try Shell.run("git branch --show-current", at: path)
    }
    
    /// 创建新分支
    /// - Parameters:
    ///   - name: 分支名称
    ///   - checkout: 是否切换到新分支
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    static func createBranch(_ name: String, checkout: Bool = false, at path: String? = nil) throws -> String {
        let command = checkout ? "git checkout -b \(name)" : "git branch \(name)"
        return try Shell.run(command, at: path)
    }
    
    /// 切换分支
    /// - Parameters:
    ///   - name: 分支名称
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    static func checkout(_ name: String, at path: String? = nil) throws -> String {
        return try Shell.run("git checkout \(name)", at: path)
    }
    
    /// 删除分支
    /// - Parameters:
    ///   - name: 分支名称
    ///   - force: 是否强制删除
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    static func deleteBranch(_ name: String, force: Bool = false, at path: String? = nil) throws -> String {
        let option = force ? "-D" : "-d"
        return try Shell.run("git branch \(option) \(name)", at: path)
    }
    
    /// 合并分支
    /// - Parameters:
    ///   - branch: 要合并的分支
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    static func merge(_ branch: String, at path: String? = nil) throws -> String {
        return try Shell.run("git merge \(branch)", at: path)
    }
    
    /// 获取差异
    /// - Parameters:
    ///   - staged: 是否查看暂存区差异
    ///   - path: 仓库路径
    /// - Returns: 差异信息
    static func diff(staged: Bool = false, at path: String? = nil) throws -> String {
        let option = staged ? "--cached" : ""
        return try Shell.run("git diff \(option)", at: path)
    }
    
    /// 获取文件差异
    /// - Parameters:
    ///   - file: 文件路径
    ///   - staged: 是否查看暂存区差异
    ///   - path: 仓库路径
    /// - Returns: 文件差异信息
    static func diffFile(_ file: String, staged: Bool = false, at path: String? = nil) throws -> String {
        let option = staged ? "--cached" : ""
        return try Shell.run("git diff \(option) \(file)", at: path)
    }
    
    /// 重置文件
    /// - Parameters:
    ///   - files: 文件路径数组
    ///   - hard: 是否硬重置
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    static func reset(_ files: [String] = [], hard: Bool = false, at path: String? = nil) throws -> String {
        if files.isEmpty {
            let option = hard ? "--hard" : ""
            return try Shell.run("git reset \(option)", at: path)
        } else {
            let fileList = files.joined(separator: " ")
            return try Shell.run("git reset \(fileList)", at: path)
        }
    }
    
    /// 暂存更改
    /// - Parameters:
    ///   - message: 暂存信息
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    static func stash(_ message: String? = nil, at path: String? = nil) throws -> String {
        let command = message != nil ? "git stash push -m \"\(message!)\"" : "git stash"
        return try Shell.run(command, at: path)
    }
    
    /// 恢复暂存
    /// - Parameters:
    ///   - index: 暂存索引，默认为最新
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    static func stashPop(index: Int = 0, at path: String? = nil) throws -> String {
        return try Shell.run("git stash pop stash@{\(index)}", at: path)
    }
    
    /// 获取暂存列表
    /// - Parameter path: 仓库路径
    /// - Returns: 暂存列表
    static func stashList(at path: String? = nil) throws -> String {
        return try Shell.run("git stash list", at: path)
    }
    
    /// 添加远程仓库
    /// - Parameters:
    ///   - name: 远程仓库名称
    ///   - url: 远程仓库URL
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    static func addRemote(_ name: String, url: String, at path: String? = nil) throws -> String {
        return try Shell.run("git remote add \(name) \(url)", at: path)
    }
    
    /// 获取远程仓库列表
    /// - Parameters:
    ///   - verbose: 是否显示详细信息
    ///   - path: 仓库路径
    /// - Returns: 远程仓库列表
    static func remotes(verbose: Bool = false, at path: String? = nil) throws -> String {
        let option = verbose ? "-v" : ""
        return try Shell.run("git remote \(option)", at: path)
    }
    
    /// 删除远程仓库
    /// - Parameters:
    ///   - name: 远程仓库名称
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    static func removeRemote(_ name: String, at path: String? = nil) throws -> String {
        return try Shell.run("git remote remove \(name)", at: path)
    }
    
    /// 获取标签列表
    /// - Parameter path: 仓库路径
    /// - Returns: 标签列表
    static func tags(at path: String? = nil) throws -> String {
        return try Shell.run("git tag", at: path)
    }
    
    /// 创建标签
    /// - Parameters:
    ///   - name: 标签名称
    ///   - message: 标签信息
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    static func createTag(_ name: String, message: String? = nil, at path: String? = nil) throws -> String {
        let command = message != nil ? "git tag -a \(name) -m \"\(message!)\"" : "git tag \(name)"
        return try Shell.run(command, at: path)
    }
    
    /// 删除标签
    /// - Parameters:
    ///   - name: 标签名称
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    static func deleteTag(_ name: String, at path: String? = nil) throws -> String {
        return try Shell.run("git tag -d \(name)", at: path)
    }
    
    /// 检查是否为Git仓库
    /// - Parameter path: 路径
    /// - Returns: 是否为Git仓库
    static func isGitRepository(at path: String? = nil) -> Bool {
        do {
            _ = try Shell.run("git rev-parse --git-dir", at: path)
            return true
        } catch {
            return false
        }
    }
    
    /// 获取仓库根目录
    /// - Parameter path: 路径
    /// - Returns: 仓库根目录路径
    static func repositoryRoot(at path: String? = nil) throws -> String {
        return try Shell.run("git rev-parse --show-toplevel", at: path)
    }
    
    /// 获取最新提交哈希
    /// - Parameters:
    ///   - short: 是否返回短哈希
    ///   - path: 仓库路径
    /// - Returns: 提交哈希
    static func lastCommitHash(short: Bool = false, at path: String? = nil) throws -> String {
        let option = short ? "--short" : ""
        return try Shell.run("git rev-parse \(option) HEAD", at: path)
    }
    
    /// 获取用户配置
    /// - Parameters:
    ///   - global: 是否获取全局配置
    ///   - path: 仓库路径
    /// - Returns: 用户配置信息
    static func getUserConfig(global: Bool = false, at path: String? = nil) throws -> (name: String, email: String) {
        let scope = global ? "--global" : ""
        let name = try Shell.run("git config \(scope) user.name", at: path)
        let email = try Shell.run("git config \(scope) user.email", at: path)
        return (name: name, email: email)
    }
    
    /// 配置用户信息
    /// - Parameters:
    ///   - name: 用户名
    ///   - email: 邮箱
    ///   - global: 是否全局配置
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    static func configUser(name: String, email: String, global: Bool = false, at path: String? = nil) throws -> String {
        let scope = global ? "--global" : ""
        let nameResult = try Shell.run("git config \(scope) user.name \"\(name)\"", at: path)
        let emailResult = try Shell.run("git config \(scope) user.email \"\(email)\"", at: path)
        return "Name: \(nameResult)\nEmail: \(emailResult)"
    }
}

// MARK: - Preview

#Preview("ShellGit Demo") {
    ShellGitPreviewView()
        .inMagicContainer()
}
