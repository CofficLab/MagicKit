import Foundation

public struct GitDiffFile: Identifiable, Equatable {
    public let id: String // 文件名
    public let file: String
    public let changeType: String // "A" "M" "D" 等
    public let diff: String
} 