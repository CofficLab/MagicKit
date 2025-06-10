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
    // 配置属性
    let oldText: String
    let newText: String
    let showLineNumbers: Bool
    let font: Font
    let enableCollapsing: Bool
    let minUnchangedLines: Int
    let defaultLanguage: CodeLanguage

    // 状态管理
    @State private var selectedView: MagicDiffViewMode = .diff
    @State private var selectedLanguage: CodeLanguage
    
    // 复制状态管理
    @State private var copyState: CopyState = .idle
    @State private var copyMessage: String = ""

    /// 创建差异比较视图
    /// - Parameters:
    ///   - oldText: 原始文本
    ///   - newText: 新文本
    ///   - showLineNumbers: 是否显示行号，默认为 true
    ///   - font: 文本字体，默认为等宽字体
    ///   - enableCollapsing: 是否启用折叠功能，默认为 true
    ///   - minUnchangedLines: 最小未变动行数才会折叠，默认为3行
    ///   - defaultLanguage: 默认代码语言，如果为nil则自动检测
    public init(
        oldText: String,
        newText: String,
        showLineNumbers: Bool = true,
        font: Font = .system(.body, design: .monospaced),
        enableCollapsing: Bool = true,
        minUnchangedLines: Int = 3,
        defaultLanguage: CodeLanguage? = nil
    ) {
        self.oldText = oldText
        self.newText = newText
        self.showLineNumbers = showLineNumbers
        self.font = font
        self.enableCollapsing = enableCollapsing
        self.minUnchangedLines = minUnchangedLines
        
        // 如果没有指定默认语言，尝试自动检测
        let detectedLanguage = defaultLanguage ?? SyntaxHighlighter.detectLanguage(newText)
        self.defaultLanguage = detectedLanguage
        self._selectedLanguage = State(initialValue: detectedLanguage)
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 顶部工具栏
                MagicDiffToolbar(
                    selectedView: $selectedView,
                    selectedLanguage: $selectedLanguage,
                    copyState: $copyState,
                    oldText: oldText,
                    newText: newText,
                    onCopy: copyToClipboard
                )
                
                // 主要内容区域
                Group {
                    switch selectedView {
                    case .diff:
                        MagicDiffContentView(
                            diffItems: diffItems,
                            showLineNumbers: showLineNumbers,
                            font: font,
                            selectedLanguage: selectedLanguage
                        )
                    case .original:
                        MagicDiffContentView(
                            diffItems: createDiffItemsFromText(oldText),
                            showLineNumbers: showLineNumbers,
                            font: font,
                            selectedLanguage: selectedLanguage
                        )
                    case .modified:
                        MagicDiffContentView(
                            diffItems: createDiffItemsFromText(newText),
                            showLineNumbers: showLineNumbers,
                            font: font,
                            selectedLanguage: selectedLanguage
                        )
                    }
                }
            }

            // 浮动提示消息
            MagicDiffCopyToast(copyState: copyState, message: copyMessage)
        }
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
    
    /// 复制文本到剪贴板
    /// - Parameter text: 要复制的文本内容
    private func copyToClipboard(text: String) {
        // 设置复制中状态
        withAnimation(.easeInOut(duration: 0.1)) {
            copyState = .copying
        }

        // 模拟复制操作的延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            text.copy()

            // 复制成功
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                copyState = .success
                copyMessage = "内容已复制到剪贴板"
            }

            // 2秒后重置状态
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    copyState = .idle
                    copyMessage = ""
                }
            }
        }
    }
    
    /// 将纯文本转换为DiffItem数组
    private func createDiffItemsFromText(_ text: String) -> [DiffItem] {
        let lines = text.isEmpty ? [] : text.components(separatedBy: .newlines)
        return lines.enumerated().map { index, content in
            let diffLine = DiffLine(
                content: content,
                type: .unchanged,
                oldLineNumber: index + 1,
                newLineNumber: index + 1
            )
            return DiffItem.line(diffLine)
        }
    }
}

// MARK: - Preview

#Preview("MagicDiffPreviewView") {
    MagicDiffPreviewView()
        .inMagicContainer()
}