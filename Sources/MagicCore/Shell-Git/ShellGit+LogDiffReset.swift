import Foundation
import OSLog

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
    
    /// 重置文件
    /// - Parameters:
    ///   - files: 文件路径数组
    ///   - hard: 是否硬重置
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func reset(_ files: [String] = [], hard: Bool = false, at path: String? = nil) throws -> String {
        if files.isEmpty {
            let option = hard ? "--hard" : ""
            return try Shell.run("git reset \(option)", at: path)
        } else {
            let fileList = files.joined(separator: " ")
            return try Shell.run("git reset \(fileList)", at: path)
        }
    }
}