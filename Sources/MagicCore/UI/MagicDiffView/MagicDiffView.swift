import SwiftUI

/// 用于比较两个字符串差异的视图组件，类似GitHub Desktop的diff视图
///
/// `MagicDiffView` 提供了一个直观的界面来展示两个文本之间的差异，
/// 支持行级别的比较，并用不同颜色标识添加、删除和修改的内容。
///
/// 基本使用示例：
/// ```swift
/// MagicDiffView(
///     oldText: "Hello World\nThis is line 2",
///     newText: "Hello Swift\nThis is line 2\nNew line 3"
/// )
/// ```
public struct MagicDiffView: View {
    private let oldText: String
    private let newText: String
    private let showLineNumbers: Bool
    private let font: Font
    
    /// 创建差异比较视图
    /// - Parameters:
    ///   - oldText: 原始文本
    ///   - newText: 新文本
    ///   - showLineNumbers: 是否显示行号，默认为 true
    ///   - font: 文本字体，默认为等宽字体
    public init(
        oldText: String,
        newText: String,
        showLineNumbers: Bool = true,
        font: Font = .system(.body, design: .monospaced)
    ) {
        self.oldText = oldText
        self.newText = newText
        self.showLineNumbers = showLineNumbers
        self.font = font
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(diffLines.enumerated()), id: \.offset) { index, line in
                    DiffLineView(
                        line: line,
                        showLineNumbers: showLineNumbers,
                        font: font
                    )
                    .overlay(
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(Color.secondary.opacity(0.1)),
                        alignment: .bottom
                    )
                }
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }
    
    /// 计算差异行
    private var diffLines: [DiffLine] {
        let oldLines = oldText.components(separatedBy: .newlines)
        let newLines = newText.components(separatedBy: .newlines)
        
        return DiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)
    }
}