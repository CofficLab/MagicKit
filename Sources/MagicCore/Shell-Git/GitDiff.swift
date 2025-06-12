import Foundation

/// 表示一次 diff 结果中的单个文件变动
public struct GitDiffFile: Identifiable, Equatable, Hashable {
    /// 文件名（唯一标识）
    public let id: String
    /// 文件名
    public let file: String
    /// 变动类型（A: 新增, M: 修改, D: 删除等）
    public let changeType: String
    /// 该文件的 diff 内容
    public let diff: String
} 