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

/// 折叠块数据
public struct CollapsibleBlock {
    let lines: [DiffLine]
    let isCollapsed: Bool
    let startLineNumber: Int
    let endLineNumber: Int
    
    /// 创建折叠块
    /// - Parameters:
    ///   - lines: 包含的差异行
    ///   - isCollapsed: 是否折叠状态
    ///   - startLineNumber: 起始行号
    ///   - endLineNumber: 结束行号
    init(lines: [DiffLine], isCollapsed: Bool = true, startLineNumber: Int, endLineNumber: Int) {
        self.lines = lines
        self.isCollapsed = isCollapsed
        self.startLineNumber = startLineNumber
        self.endLineNumber = endLineNumber
    }
}

/// 差异项目类型（可以是单行或折叠块）
public enum DiffItem {
    case line(DiffLine)
    case collapsibleBlock(CollapsibleBlock)
}