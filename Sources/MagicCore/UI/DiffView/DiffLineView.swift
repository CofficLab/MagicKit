import SwiftUI

/// 差异行视图
struct DiffLineView: View {
    let line: DiffLine
    let showLineNumbers: Bool
    let font: Font
    let codeLanguage: CodeLanguage
    let displayMode: MagicDiffViewMode
    
    init(
        line: DiffLine,
        showLineNumbers: Bool,
        font: Font = .system(.body, design: .monospaced),
        codeLanguage: CodeLanguage = .swift,
        displayMode: MagicDiffViewMode = .diff
    ) {
        self.line = line
        self.showLineNumbers = showLineNumbers
        self.font = font
        self.codeLanguage = codeLanguage
        self.displayMode = displayMode
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if showLineNumbers {
                lineNumberView
            }
            
            contentView
        }
        .background(backgroundColor)
    }
    
    @ViewBuilder
    private var lineNumberView: some View {
        HStack(spacing: 0) {
            // 根据显示模式显示行号
            switch displayMode {
            case .original:
                // 原始模式只显示旧行号
                Text(line.oldLineNumber?.description ?? "")
                    .frame(width: 32, alignment: .trailing)
                    .foregroundColor(.secondary.opacity(0.7))
            case .modified:
                // 修改模式只显示新行号
                Text(line.newLineNumber?.description ?? "")
                    .frame(width: 32, alignment: .trailing)
                    .foregroundColor(.secondary.opacity(0.7))
            case .diff:
                // 差异模式显示两列行号
                Text(line.oldLineNumber?.description ?? "")
                    .frame(width: 16, alignment: .trailing)
                    .foregroundColor(.secondary.opacity(0.7))
                Text(line.newLineNumber?.description ?? "")
                    .frame(width: 16, alignment: .trailing)
                    .foregroundColor(.secondary.opacity(0.7))
            }
            
            // 差异标识
            Text(diffSymbol)
                .frame(width: 16, alignment: .center)
                .foregroundColor(symbolColor)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.medium)
        }
        .font(.system(.caption, design: .monospaced))
        .padding(.horizontal, 6)
        .padding(.vertical, 1)
        .background(lineNumberBackgroundColor)
    }
    
    private var contentView: some View {
        SyntaxHighlighter.highlight(
            text: line.content.isEmpty ? " " : line.content,
            rules: codeLanguage.rules
        )
        .font(font)
        .foregroundStyle(textColor)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 0)
    }
    
    private var backgroundColor: Color {
        switch line.type {
        case .unchanged:
            return Color.clear
        case .added:
            return Color.green.opacity(0.15)
        case .removed:
            return Color.red.opacity(0.15)
        case .modified:
            return Color.orange.opacity(0.15)
        }
    }
    
    private var lineNumberBackgroundColor: Color {
        switch line.type {
        case .unchanged:
            return Color.secondary.opacity(0.05)
        case .added:
            return Color.green.opacity(0.25)
        case .removed:
            return Color.red.opacity(0.25)
        case .modified:
            return Color.orange.opacity(0.25)
        }
    }
    
    private var textColor: Color {
        switch line.type {
        case .unchanged:
            return .primary
        case .added:
            return .green
        case .removed:
            return .red
        case .modified:
            return .orange
        }
    }
    
    private var diffSymbol: String {
        switch line.type {
        case .unchanged:
            return " "
        case .added:
            return "+"
        case .removed:
            return "-"
        case .modified:
            return "~"
        }
    }
    
    private var symbolColor: Color {
        switch line.type {
        case .unchanged:
            return .clear
        case .added:
            return .green
        case .removed:
            return .red
        case .modified:
            return .orange
        }
    }
}

// MARK: - Preview
#Preview("MagicDiffPreviewView") {
    MagicDiffPreviewView()
        .inMagicContainer()
}