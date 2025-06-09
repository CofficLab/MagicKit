import Foundation

/// 差异类型
public enum DiffType {
    case unchanged
    case added
    case removed
    case modified
}

/// 差异行数据
public struct DiffLine {
    let content: String
    let type: DiffType
    let oldLineNumber: Int?
    let newLineNumber: Int?
}