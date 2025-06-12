import Foundation
import OSLog

extension ShellGit {
    /// 添加文件到暂存区
    /// - Parameters:
    ///   - files: 文件路径数组，如果为空则添加所有文件
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func add(_ files: [String] = [], at path: String? = nil) throws -> String {
        let fileList = files.isEmpty ? "." : files.joined(separator: " ")
        return try Shell.run("git add \(fileList)", at: path)
    }
    
    /// 提交更改
    /// - Parameters:
    ///   - message: 提交信息
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func commit(_ message: String, at path: String? = nil) throws -> String {
        return try Shell.run("git commit -m \"\(message)\"", at: path)
    }
    
    /// 获取仓库状态
    /// - Parameter path: 仓库路径
    /// - Returns: 状态信息
    public static func status(at path: String? = nil) throws -> String {
        return try Shell.run("git status --porcelain", at: path)
    }
    
    /// 获取详细状态
    /// - Parameter path: 仓库路径
    /// - Returns: 详细状态信息
    public static func statusVerbose(at path: String? = nil) throws -> String {
        return try Shell.run("git status", at: path)
    }
}
