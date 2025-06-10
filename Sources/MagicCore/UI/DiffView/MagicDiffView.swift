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
    private let enableCollapsing: Bool
    private let minUnchangedLines: Int
    
    /// 创建差异比较视图
    /// - Parameters:
    ///   - oldText: 原始文本
    ///   - newText: 新文本
    ///   - showLineNumbers: 是否显示行号，默认为 true
    ///   - font: 文本字体，默认为等宽字体
    ///   - enableCollapsing: 是否启用折叠功能，默认为 true
    ///   - minUnchangedLines: 最小未变动行数才会折叠，默认为3行
    public init(
        oldText: String,
        newText: String,
        showLineNumbers: Bool = true,
        font: Font = .system(.body, design: .monospaced),
        enableCollapsing: Bool = true,
        minUnchangedLines: Int = 3
    ) {
        self.oldText = oldText
        self.newText = newText
        self.showLineNumbers = showLineNumbers
        self.font = font
        self.enableCollapsing = enableCollapsing
        self.minUnchangedLines = minUnchangedLines
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(diffItems.enumerated()), id: \.offset) { index, item in
                    switch item {
                    case .line(let line):
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
                    
                    case .collapsibleBlock(let block):
                        CollapsibleBlockView(
                            block: block,
                            showLineNumbers: showLineNumbers,
                            font: font
                        )
                    }
                }
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(0)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }
    
    /// 计算差异项目（包含折叠块）
    private var diffItems: [DiffItem] {
        // 处理空文本的情况，避免返回包含空字符串的数组
        let oldLines = oldText.isEmpty ? [] : oldText.components(separatedBy: .newlines)
        let newLines = newText.isEmpty ? [] : newText.components(separatedBy: .newlines)
        
        let diffLines = DiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)
        
        if enableCollapsing {
            return DiffAlgorithm.organizeDiffItems(from: diffLines, minUnchangedLines: minUnchangedLines)
        } else {
            // 不启用折叠时，将所有行转换为普通行项目
            return diffLines.map { .line($0) }
        }
    }
}

// MARK: - Preview
#Preview("MagicDiffPreviewView") {
    MagicDiffPreviewView()
        .inMagicContainer()
}
