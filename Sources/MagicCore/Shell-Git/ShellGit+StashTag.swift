import Foundation
import OSLog

extension ShellGit {
    /// 暂存更改
    /// - Parameters:
    ///   - message: 暂存信息
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func stash(_ message: String? = nil, at path: String? = nil) throws -> String {
        let command = message != nil ? "git stash push -m \"\(message!)\"" : "git stash"
        return try Shell.run(command, at: path)
    }
    
    /// 恢复暂存
    /// - Parameters:
    ///   - index: 暂存索引，默认为最新
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func stashPop(index: Int = 0, at path: String? = nil) throws -> String {
        return try Shell.run("git stash pop stash@{\(index)}", at: path)
    }
    
    /// 获取暂存列表
    /// - Parameter path: 仓库路径
    /// - Returns: 暂存列表
    public static func stashList(at path: String? = nil) throws -> String {
        return try Shell.run("git stash list", at: path)
    }
    
    /// 获取标签列表
    /// - Parameter path: 仓库路径
    /// - Returns: 标签列表
    public static func tags(at path: String? = nil) throws -> String {
        return try Shell.run("git tag", at: path)
    }
    
    /// 创建标签
    /// - Parameters:
    ///   - name: 标签名称
    ///   - message: 标签信息
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func createTag(_ name: String, message: String? = nil, at path: String? = nil) throws -> String {
        let command = message != nil ? "git tag -a \(name) -m \"\(message!)\"" : "git tag \(name)"
        return try Shell.run(command, at: path)
    }
    
    /// 删除标签
    /// - Parameters:
    ///   - name: 标签名称
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func deleteTag(_ name: String, at path: String? = nil) throws -> String {
        return try Shell.run("git tag -d \(name)", at: path)
    }
}