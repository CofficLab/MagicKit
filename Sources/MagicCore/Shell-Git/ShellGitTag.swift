import Foundation
import OSLog
import SwiftUI

extension ShellGit {
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
    
    /// 获取指定 commit 的所有标签
    /// - Parameters:
    ///   - commit: commit 哈希
    ///   - path: 仓库路径
    /// - Returns: 标签数组
    public static func tags(for commit: String, at path: String? = nil) throws -> [String] {
        let output = try Shell.run("git tag --points-at \(commit)", at: path)
        return output.split(separator: "\n").map { String($0) }.filter { !$0.isEmpty }
    }
    
    /// 获取标签结构体列表
    /// - Parameter path: 仓库路径
    /// - Returns: 标签结构体数组
    public static func tagList(at path: String? = nil) throws -> [GitTag] {
        let tagNames = try tags(at: path).split(separator: "\n").map { String($0) }
        var tags: [GitTag] = []
        for name in tagNames {
            // 获取 commit hash
            let commitHash = (try? Shell.run("git rev-list -n 1 \(name)", at: path)) ?? ""
            // 获取作者、日期、message
            let tagInfo = (try? Shell.run("git for-each-ref refs/tags/\(name) --format='%(taggername)::%(taggerdate)::%(subject)'", at: path)) ?? "::"
            let parts = tagInfo.replacingOccurrences(of: "'", with: "").split(separator: "::").map { String($0) }
            let author = parts.count > 0 ? parts[0] : nil
            let date = parts.count > 1 ? ISO8601DateFormatter().date(from: parts[1]) : nil
            let message = parts.count > 2 ? parts[2] : nil
            tags.append(GitTag(id: name, name: name, commitHash: commitHash, author: author, date: date, message: message))
        }
        return tags
    }
    
    /// 获取指定 commit 的所有标签（结构体版）
    /// - Parameters:
    ///   - commit: commit 哈希
    ///   - path: 仓库路径
    /// - Returns: [GitTag]
    public static func tagList(for commit: String, at path: String? = nil) throws -> [GitTag] {
        let tagNames = try tags(for: commit, at: path)
        var tags: [GitTag] = []
        for name in tagNames {
            let commitHash = (try? Shell.run("git rev-list -n 1 \(name)", at: path)) ?? ""
            let tagInfo = (try? Shell.run("git for-each-ref refs/tags/\(name) --format='%(taggername)::%(taggerdate)::%(subject)'", at: path)) ?? "::"
            let parts = tagInfo.replacingOccurrences(of: "'", with: "").split(separator: "::").map { String($0) }
            let author = parts.count > 0 ? parts[0] : nil
            let date = parts.count > 1 ? ISO8601DateFormatter().date(from: parts[1]) : nil
            let message = parts.count > 2 ? parts[2] : nil
            tags.append(GitTag(id: name, name: name, commitHash: commitHash, author: author, date: date, message: message))
        }
        return tags
    }
} 