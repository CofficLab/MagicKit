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
        return try Shell.runSync("git log \(format) -\(limit)", at: path)
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
    
    /// 获取最近的提交记录
    /// - Parameters:
    ///   - count: 获取的提交数量
    ///   - path: 仓库路径
    /// - Returns: 提交记录列表
    public static func recentCommits(count: Int = 10, at path: String? = nil) throws -> [GitCommit] {
        let format = "%H|%an|%ae|%at|%s"
        let output = try Shell.runSync("git log -n \(count) --pretty=format:'\(format)'", at: path)
        return output.split(separator: "\n").compactMap { line in
            let parts = String(line).split(separator: "|").map { String($0) }
            guard parts.count >= 5 else { return nil }
            return GitCommit(
                id: parts[0],
                hash: parts[0],
                author: parts[1],
                email: parts[2],
                date: Date(timeIntervalSince1970: TimeInterval(Int(parts[3]) ?? 0)),
                message: parts[4],
                refs: [],
                tags: []
            )
        }
    }
    
    /// 获取指定分支的提交记录
    /// - Parameters:
    ///   - branch: 分支名称
    ///   - count: 获取的提交数量
    ///   - path: 仓库路径
    /// - Returns: 提交记录列表
    public static func commits(in branch: String, count: Int = 10, at path: String? = nil) throws -> [GitCommit] {
        let format = "%H|%an|%ae|%at|%s"
        let output = try Shell.runSync("git log \(branch) -n \(count) --pretty=format:'\(format)'", at: path)
        return output.split(separator: "\n").compactMap { line in
            let parts = String(line).split(separator: "|").map { String($0) }
            guard parts.count >= 5 else { return nil }
            return GitCommit(
                id: parts[0],
                hash: parts[0],
                author: parts[1],
                email: parts[2],
                date: Date(timeIntervalSince1970: TimeInterval(Int(parts[3]) ?? 0)),
                message: parts[4],
                refs: [],
                tags: []
            )
        }
    }
    
    /// 获取提交的详细信息
    /// - Parameters:
    ///   - commit: 提交哈希
    ///   - path: 仓库路径
    /// - Returns: 提交详细信息
    public static func commitDetail(_ commit: String, at path: String? = nil) async throws -> GitCommitDetail {
        let format = "%H|%an|%ae|%at|%s|%b"
        let output = try Shell.runSync("git show \(commit) --pretty=format:'\(format)' --no-patch", at: path)
        let parts = output.split(separator: "|").map { String($0) }
        guard parts.count >= 6 else {
            throw NSError(domain: "ShellGit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid commit format"])
        }
        
        let files = try await changedFilesDetail(in: commit, at: path)
        let diff = try Shell.runSync("git show \(commit)", at: path)
        
        return GitCommitDetail(
            id: parts[0],
            author: parts[1],
            email: parts[2],
            date: Date(timeIntervalSince1970: TimeInterval(Int(parts[3]) ?? 0)),
            message: parts[4],
            body: parts[5],
            files: files,
            diff: diff
        )
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
        let log = try Shell.runSync("git log \(remote)/\(branchName)..\(branchName) --oneline", at: path)
        return log.split(separator: "\n").map { String($0) }
    }

    /// 获取提交及其标签列表
    /// - Parameters:
    ///   - limit: 限制条数
    ///   - at: 仓库路径
    /// - Returns: [CommitWithTag]
    public static func commitsWithTags(limit: Int = 20, at path: String? = nil) throws -> [CommitWithTag] {
        // 使用 git log --pretty=format:"%H%x09%s%x09%d" 获取 hash、message、ref
        let log = try Shell.runSync("git log --pretty=format:%H%x09%s%x09%d -\(limit)", at: path)
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
        let log = try Shell.runSync("git log \(format) --skip=\(skip) -\(size)", at: path)
        return log.split(separator: "\n").map { String($0) }
    }

    /// 获取提交记录结构体列表
    /// - Parameters:
    ///   - limit: 限制条数
    ///   - at: 仓库路径
    /// - Returns: [GitCommit]
    public static func commitList(limit: Int = 20, at path: String? = nil) throws -> [GitCommit] {
        let format = "--pretty=format:%H%x09%an%x09%ae%x09%ad%x09%s%x09%d"
        let log = try Shell.runSync("git log \(format) -\(limit)", at: path)
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

    /// 获取本地未推送到远程的提交日志（结构体版）
    /// - Parameters:
    ///   - remote: 远程仓库名，默认 origin
    ///   - branch: 分支名，默认当前分支
    ///   - path: 仓库路径
    /// - Returns: 未推送的提交日志（[GitCommit]）
    public static func unpushedCommitList(remote: String = "origin", branch: String? = nil, at path: String? = nil) throws -> [GitCommit] {
        let branchName: String
        if let branch = branch {
            branchName = branch
        } else {
            branchName = try currentBranch(at: path)
        }
        let log = try Shell.runSync("git log \(remote)/\(branchName)..\(branchName) --pretty=format:%H%x09%an%x09%ae%x09%ad%x09%s%x09%D", at: path)
        let lines = log.split(separator: "\n").map { String($0) }
        var commits: [GitCommit] = []
        let dateFormatter = ISO8601DateFormatter()
        for line in lines {
            let parts = line.split(separator: "\t").map { String($0) }
            guard parts.count >= 5 else { continue }
            let hash = parts[0]
            let author = parts[1]
            let email = parts[2]
            let dateStr = parts[3]
            let message = parts[4]
            let refs = parts.count > 5 ? parts[5].split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } : []
            let tags = refs.filter { $0.contains("tag:") }.map { $0.replacingOccurrences(of: "tag:", with: "").trimmingCharacters(in: .whitespaces) }
            let date = dateFormatter.date(from: dateStr) ?? Date()
            commits.append(GitCommit(id: hash, hash: hash, author: author, email: email, date: date, message: message, refs: refs, tags: tags))
        }
        return commits
    }

    /// 分页获取提交日志（结构体版）
    /// - Parameters:
    ///   - page: 页码（从 1 开始）
    ///   - size: 每页条数
    ///   - at: 仓库路径
    /// - Returns: [GitCommit]
    public static func commitListWithPagination(page: Int = 1, size: Int = 20, at path: String? = nil) throws -> [GitCommit] {
        let skip = (page - 1) * size
        let format = "--pretty=format:%H%x09%an%x09%ae%x09%ad%x09%s%x09%D"
        let log = try Shell.runSync("git log \(format) --skip=\(skip) -\(size)", at: path)
        let dateFormatter = ISO8601DateFormatter()
        return log.split(separator: "\n").compactMap { line in
            let parts = line.split(separator: "\t", omittingEmptySubsequences: false)
            guard parts.count >= 6 else { return nil }
            let hash = String(parts[0])
            let author = String(parts[1])
            let email = String(parts[2])
            let date = dateFormatter.date(from: String(parts[3])) ?? Date()
            let message = String(parts[4])
            let refs = String(parts[5])
            let tags = refs.components(separatedBy: ", ").filter { $0.contains("tag:") }.map { $0.replacingOccurrences(of: "tag:", with: "").trimmingCharacters(in: .whitespaces) }
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
