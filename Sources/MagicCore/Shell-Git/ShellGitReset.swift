import Foundation
import OSLog
import SwiftUI

extension ShellGit {
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

#Preview("ShellGit+Reset Demo") {
    ShellGitResetPreview()
        .inMagicContainer()
} 