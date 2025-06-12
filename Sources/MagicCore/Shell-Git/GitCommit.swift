import Foundation

/// 表示一次 Git 提交记录
public struct GitCommit: Identifiable, Equatable {
    /// 提交哈希（唯一标识）
    public let id: String
    /// 提交哈希
    public let hash: String
    /// 作者名称
    public let author: String
    /// 作者邮箱
    public let email: String
    /// 提交日期
    public let date: Date
    /// 提交信息
    public let message: String
    /// 关联的引用（如分支、tag 等）
    public let refs: [String]
    /// 关联的标签名
    public let tags: [String]
}

/// 表示带标签的提交
public struct CommitWithTag {
    public let hash: String
    public let message: String
    public let tags: [String]
}


/// 提交详细信息
public struct GitCommitDetail {
    public let id: String
    public let author: String
    public let email: String
    public let date: Date
    public let message: String
    public let body: String
    public let files: [GitDiffFile]
    public let diff: String
}