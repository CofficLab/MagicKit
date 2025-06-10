import SwiftUI

/// 差异视图的主要内容组件
struct MagicDiffContentView: View {
    let diffItems: [DiffItem]
    let showLineNumbers: Bool
    let font: Font
    let selectedLanguage: CodeLanguage
    let displayMode: MagicDiffViewMode
    
    var body: some View {
        ScrollView {
            diffViewContent
        }
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(0)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }
    
    /// 差异视图内容
    private var diffViewContent: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(Array(diffItems.enumerated()), id: \.offset) { index, item in
                switch item {
                case let .line(line):
                    diffLineItem(line)
                case let .collapsibleBlock(block):
                    diffBlockItem(block)
                }
            }
        }
    }
    
    /// 差异视图中的单行项目
    @ViewBuilder
    private func diffLineItem(_ line: DiffLine) -> some View {
        DiffLineView(
            line: line,
            showLineNumbers: showLineNumbers,
            font: font,
            codeLanguage: selectedLanguage,
            displayMode: displayMode
        )
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.secondary.opacity(0.1)),
            alignment: .bottom
        )
    }
    
    /// 差异视图中的折叠块项目
    private func diffBlockItem(_ block: CollapsibleBlock) -> some View {
        CollapsibleBlockView(
            block: block,
            showLineNumbers: showLineNumbers,
            font: font,
            displayMode: displayMode
        )
    }
    
    init(
        diffItems: [DiffItem],
        showLineNumbers: Bool,
        font: Font = .system(.body, design: .monospaced),
        selectedLanguage: CodeLanguage = .swift,
        displayMode: MagicDiffViewMode = .diff
    ) {
        self.diffItems = diffItems
        self.showLineNumbers = showLineNumbers
        self.font = font
        self.selectedLanguage = selectedLanguage
        self.displayMode = displayMode
    }
}

// MARK: - Preview

#Preview {
    let oldText = "func hello() {\n    print(\"Hello World\")\n}"
    let newText = "func hello() {\n    print(\"Hello Swift\")\n    print(\"Welcome!\")\n}"
    
    let oldLines = oldText.components(separatedBy: .newlines)
    let newLines = newText.components(separatedBy: .newlines)
    
    let diffLines = DiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)
    let diffItems = diffLines.map { DiffItem.line($0) }
    
    return MagicDiffContentView(
        diffItems: diffItems,
        showLineNumbers: true,
        font: .system(.body, design: .monospaced),
        selectedLanguage: .swift,
        displayMode: .diff
    )
}

#Preview("MagicDiffPreviewView") {
    MagicDiffPreviewView()
        .inMagicContainer()
}