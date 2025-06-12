import Foundation

/// 表示一个 Git 标签
public struct GitTag: Identifiable, Equatable {
    /// 标签名（唯一标识）
    public let id: String
    /// 标签名
    public let name: String
    /// 标签指向的 commit 哈希
    public let commitHash: String
    /// 标签作者（如有）
    public let author: String?
    /// 标签日期（如有）
    public let date: Date?
    /// 标签信息（如有）
    public let message: String?
} 