import Foundation

/// 表示一次 Git stash 记录
public struct GitStash: Identifiable, Equatable {
    /// stash 索引（如 0, 1, 2...）
    public let id: Int
    /// 描述信息
    public let description: String
    /// 关联的 commit 哈希
    public let commitHash: String
    /// 创建日期（如能解析）
    public let date: Date?
} 