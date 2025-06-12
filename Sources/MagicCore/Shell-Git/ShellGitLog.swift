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

    /// 表示带标签的提交
    public struct CommitWithTag {
        public let hash: String
        public let message: String
        public let tags: [String]
    }

    /// 获取提交及其标签列表
    /// - Parameters:
    ///   - limit: 限制条数
    ///   - at: 仓库路径
    /// - Returns: [CommitWithTag]
    public static func commitsWithTags(limit: Int = 20, at path: String? = nil) throws -> [CommitWithTag] {
        // 使用 git log --pretty=format:"%H%x09%s%x09%d" 获取 hash、message、ref
        let log = try Shell.run("git log --pretty=format:%H%x09%s%x09%d -\(limit)", at: path)
        return log.split(separator: "\n").compactMap { line in
            let parts = line.split(separator: "\t", omittingEmptySubsequences: false)
            guard parts.count >= 3 else { return nil }
            let hash = String(parts[0])
            let message = String(parts[1])
            let ref = String(parts[2])
            // 提取 tag 名称
            let tags = ref.matches(for: "tag \\w+[-.\\w]*").map { $0.replacingOccurrences(of: "tag ", with: "") }
            return CommitWithTag(hash: hash, message: message, tags: tags)
        }
    }

    /// 分页获取提交日志
    /// - Parameters:
    ///   - page: 页码（从 1 开始）
    ///   - size: 每页条数
    ///   - oneline: 是否单行显示
    ///   - path: 仓库路径
    /// - Returns: 日志信息数组
    public static func logsWithPagination(page: Int = 1, size: Int = 20, oneline: Bool = true, at path: String? = nil) throws -> [String] {
        let skip = (page - 1) * size
        let format = oneline ? "--oneline" : ""
        let log = try Shell.run("git log \(format) --skip=\(skip) -\(size)", at: path)
        return log.split(separator: "\n").map { String($0) }
    }

    /// 获取提交记录结构体列表
    /// - Parameters:
    ///   - limit: 限制条数
    ///   - at: 仓库路径
    /// - Returns: [GitCommit]
    public static func commitList(limit: Int = 20, at path: String? = nil) throws -> [GitCommit] {
        let format = "--pretty=format:%H%x09%an%x09%ae%x09%ad%x09%s%x09%d"
        let log = try Shell.run("git log \(format) -\(limit)", at: path)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "E MMM d HH:mm:ss yyyy Z"
        return log.split(separator: "\n").compactMap { line in
            let parts = line.split(separator: "\t", omittingEmptySubsequences: false)
            guard parts.count >= 6 else { return nil }
            let hash = String(parts[0])
            let author = String(parts[1])
            let email = String(parts[2])
            let date = dateFormatter.date(from: String(parts[3])) ?? Date()
            let message = String(parts[4])
            let refs = String(parts[5])
            let tags = refs.matches(for: "tag \\w+[-.\\w]*").map { $0.replacingOccurrences(of: "tag ", with: "") }
            return GitCommit(id: hash, hash: hash, author: author, email: email, date: date, message: message, refs: refs.components(separatedBy: ", ").filter{!$0.isEmpty}, tags: tags)
        }
    }
}

// MARK: - String 正则扩展
private extension String {
    func matches(for regex: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: regex) else { return [] }
        let range = NSRange(self.startIndex..., in: self)
        return regex.matches(in: self, range: range).compactMap {
            Range($0.range, in: self).flatMap { String(self[$0]) }
        }
    }
}

#Preview("ShellGit+Log Demo") {
    ShellGitLogPreview()
        .inMagicContainer()
} 