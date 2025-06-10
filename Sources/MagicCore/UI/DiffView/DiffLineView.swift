import SwiftUI

/// 差异行视图
struct DiffLineView: View {
    let line: DiffLine
    let showLineNumbers: Bool
    let font: Font
    
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
            // 旧行号
            Text(line.oldLineNumber?.description ?? "")
                .frame(width: 16, alignment: .trailing)
                .foregroundColor(.secondary.opacity(0.7))
            
            // 新行号
            Text(line.newLineNumber?.description ?? "")
                .frame(width: 16, alignment: .trailing)
                .foregroundColor(.secondary.opacity(0.7))
            
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
        Text(line.content.isEmpty ? " " : line.content)
            .font(font)
            .foregroundColor(textColor)
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
