import SwiftUI
import OSLog

/// 差异视图的主要内容组件
struct DiffContentView: View, SuperLog {
    public nonisolated static let emoji = "📋"
    
    let diffItems: [DiffItem]
    let showLineNumbers: Bool
    let font: Font
    let selectedLanguage: CodeLanguage
    let displayMode: MagicDiffViewMode
    let verbose: Bool
    
    var body: some View {
        ScrollView {
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
    }
    
    /// 差异视图中的单行项目
    @ViewBuilder
    private func diffLineItem(_ line: DiffLine) -> some View {
        DiffLineView(
            line: line,
            showLineNumbers: showLineNumbers,
            font: font,
            codeLanguage: selectedLanguage,
            displayMode: displayMode,
            verbose: verbose
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
        selectedLanguage: CodeLanguage,
        displayMode: MagicDiffViewMode = .diff,
        verbose: Bool = false
    ) {
        self.diffItems = diffItems
        self.showLineNumbers = showLineNumbers
        self.font = font
        self.selectedLanguage = selectedLanguage
        self.displayMode = displayMode
        self.verbose = verbose
    }
}

// MARK: - Preview

#Preview("MagicDiffPreviewView") {
    MagicDiffPreviewView()
        .inMagicContainer()
}
