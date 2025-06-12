import Foundation
import OSLog

/// Git命令执行类
/// 提供常用的Git操作功能
public class ShellGit: SuperLog {
    public static let emoji = "🔧"
    
    /// 初始化Git仓库
    /// - Parameter path: 仓库路径
    /// - Returns: 执行结果
    public static func initRepository(at path: String) throws -> String {
        return try Shell.run("git init", at: path)
    }
    
    /// 克隆远程仓库
    /// - Parameters:
    ///   - url: 远程仓库URL
    ///   - path: 本地路径
    /// - Returns: 执行结果
    public static func clone(_ url: String, to path: String? = nil) throws -> String {
        let command = path != nil ? "git clone \(url) \(path!)" : "git clone \(url)"
        return try Shell.run(command)
    }
}