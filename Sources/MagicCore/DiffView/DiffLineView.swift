import OSLog
import SwiftUI

/// 差异视图中的单行视图
struct DiffLineView: View, SuperLog {
    public nonisolated static let emoji = "📄"

    let line: DiffLine
    let showLineNumbers: Bool
    let font: Font
    let codeLanguage: CodeLanguage
    let displayMode: MagicDiffViewMode
    let verbose: Bool

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 0) {
            if showLineNumbers {
                lineNumberView
            }

            contentView
        }
        .background(backgroundColor)
        .onHover { hovering in
            isHovered = hovering
        }
        .contextMenu {
            Button(action: {
                copyLine()
            }) {
                Label("复制行", systemImage: "doc.on.doc")
            }

            if !line.content.isEmpty {
                Button(action: {
                    copyContent(line.content)
                }) {
                    Label("复制内容", systemImage: "text.cursor")
                }
            }
        }
    }

    /// 行号视图
    private var lineNumberView: some View {
        HStack(spacing: 4) {
            if let oldNumber = line.oldLineNumber {
                Text("\(oldNumber)")
                    .font(font)
                    .foregroundColor(.primary)
                    .frame(width: 30, alignment: .trailing)
            } else {
                Text("")
                    .font(font)
                    .frame(width: 30)
            }

            if let newNumber = line.newLineNumber {
                Text("\(newNumber)")
                    .font(font)
                    .foregroundColor(.secondary)
                    .frame(width: 30, alignment: .trailing)
            } else {
                Text("")
                    .font(font)
                    .frame(width: 30)
            }
        }
        .padding(.horizontal, 8)
        .frame(maxHeight: .infinity)
    }

    /// 内容视图
    private var contentView: some View {
        Group {
            if !line.content.isEmpty {
                if displayMode == .diff {
                    switch line.type {
                    case .added:
                        SyntaxHighlighter.highlight(
                            text: line.content,
                            rules: codeLanguage.rules,
                            verbose: verbose
                        )
                        .font(font)
                        .foregroundColor(.green)
                        .padding(.leading, 4)
                    case .removed:
                        SyntaxHighlighter.highlight(
                            text: line.content,
                            rules: codeLanguage.rules,
                            verbose: verbose
                        )
                        .font(font)
                        .foregroundColor(.red)
                        .padding(.leading, 4)
                    case .unchanged:
                        SyntaxHighlighter.highlight(
                            text: line.content,
                            rules: codeLanguage.rules,
                            verbose: verbose
                        )
                        .font(font)
                        .foregroundColor(.primary)
                        .padding(.leading, 4)
                    case .modified:
                        SyntaxHighlighter.highlight(
                            text: line.content,
                            rules: codeLanguage.rules,
                            verbose: verbose
                        )
                        .font(font)
                        .foregroundColor(.orange)
                        .padding(.leading, 4)
                    }
                } else {
                    SyntaxHighlighter.highlight(
                        text: line.content,
                        rules: codeLanguage.rules,
                        verbose: verbose
                    )
                    .font(font)
                    .foregroundColor(.primary)
                    .padding(.leading, 4)
                }
            } else {
                Text("")
                    .font(font)
                    .padding(.leading, 4)
            }
        }
        .frame(maxHeight: .infinity)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 2)
    }

    /// 背景颜色
    private var backgroundColor: Color {
        if isHovered {
            return Color(NSColor.controlBackgroundColor).opacity(0.5)
        }

        switch line.type {
        case .added:
            return Color.green.opacity(0.1)
        case .removed:
            return Color.red.opacity(0.1)
        case .unchanged:
            return Color.clear
        case .modified:
            return Color.orange.opacity(0.1)
        }
    }

    /// 复制整行
    private func copyLine() {
        if !line.content.isEmpty {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(line.content, forType: .string)

            if verbose {
                os_log("\(Self.t)复制行: \(line.content)")
            }
        }
    }

    /// 复制内容
    private func copyContent(_ content: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)

        if verbose {
            os_log("\(Self.t)复制内容: \(content)")
        }
    }

    init(
        line: DiffLine,
        showLineNumbers: Bool,
        font: Font = .system(.body, design: .monospaced),
        codeLanguage: CodeLanguage = .swift,
        displayMode: MagicDiffViewMode = .diff,
        verbose: Bool = false
    ) {
        self.line = line
        self.showLineNumbers = showLineNumbers
        self.font = font
        self.codeLanguage = codeLanguage
        self.displayMode = displayMode
        self.verbose = verbose
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("MagicDiffPreviewView") {
        MagicDiffPreviewView()
            .inMagicContainer()
    }

    #Preview {
        let line = DiffLine(
            content: "print(\"Hello World\")",
            type: .added,
            oldLineNumber: nil,
            newLineNumber: 1
        )

        DiffLineView(
            line: line,
            showLineNumbers: true,
            font: .system(.body, design: .monospaced),
            codeLanguage: .swift,
            displayMode: .diff,
            verbose: true
        )
    }
#endif
