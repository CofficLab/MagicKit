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

    // 复制状态管理
    @State private var copyState: CopyState = .idle
    @State private var copyMessage: String = ""
    @State private var selectedView: Int = 0

    /// 复制状态枚举
    private enum CopyState {
        case idle
        case copying
        case success
        case failed
    }

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
        ZStack {
            VStack(spacing: 0) {
                // 顶部工具栏
                HStack {
                    // 左侧：视图切换选择器
                    Picker("", selection: $selectedView) {
                        Text("差异").tag(0)
                        Text("原文本").tag(1)
                        Text("新文本").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth: 300)

                    Spacer()

                    // 右侧：复制按钮（仅在文本视图时显示）
                    if selectedView != 0 {
                        Button(action: {
                            let textToCopy = selectedView == 1 ? oldText : newText
                            copyToClipboard(text: textToCopy)
                        }) {
                            HStack(spacing: 4) {
                                // 根据复制状态显示不同图标
                                Group {
                                    switch copyState {
                                    case .idle:
                                        Image(systemName: "doc.on.doc")
                                    case .copying:
                                        Image(systemName: "doc.on.doc")
                                            .rotationEffect(.degrees(copyState == .copying ? 360 : 0))
                                            .animation(.linear(duration: 0.5).repeatForever(autoreverses: false), value: copyState)
                                    case .success:
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                            .scaleEffect(copyState == .success ? 1.2 : 1.0)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: copyState)
                                    case .failed:
                                        Image(systemName: "xmark")
                                            .foregroundColor(.red)
                                            .scaleEffect(copyState == .failed ? 1.2 : 1.0)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: copyState)
                                    }
                                }

                                // 根据复制状态显示不同文本
                                Text(copyButtonText)
                                    .animation(.easeInOut(duration: 0.2), value: copyState)
                            }
                            .font(.caption)
                            .foregroundColor(copyButtonColor)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(copyButtonBackgroundColor)
                        .cornerRadius(6)
                        .scaleEffect(copyState == .copying ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: copyState)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.secondary.opacity(0.05))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.secondary.opacity(0.3)),
                    alignment: .bottom
                )

                // 主要内容区域
                Group {
                    switch selectedView {
                    case 0:
                        diffView
                    case 1:
                        simpleTextView(text: oldText)
                    case 2:
                        simpleTextView(text: newText)
                    default:
                        diffView
                    }
                }
            }

            // 浮动提示消息
            if !copyMessage.isEmpty {
                VStack {
                    Spacer()

                    HStack {
                        Spacer()

                        HStack(spacing: 8) {
                            Image(systemName: copyState == .success ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundColor(copyState == .success ? .green : .red)

                            Text(copyMessage)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(NSColor.controlBackgroundColor))
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .scaleEffect(copyMessage.isEmpty ? 0.8 : 1.0)
                        .opacity(copyMessage.isEmpty ? 0 : 1)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: copyMessage)

                        Spacer()
                    }
                    .padding(.bottom, 20)
                }
                .allowsHitTesting(false)
            }
        }
    }

    /// 差异视图
    private var diffView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(diffItems.enumerated()), id: \.offset) { _, item in
                    switch item {
                    case let .line(line):
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

                    case let .collapsibleBlock(block):
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

    /// 简化的文本视图（不包含工具栏）
    /// - Parameter text: 要显示的文本内容
    /// - Returns: 格式化的文本视图
    private func simpleTextView(text: String) -> some View {
        ScrollView([.horizontal, .vertical]) {
            HStack(alignment: .top, spacing: 0) {
                // 行号列（如果启用）
                if showLineNumbers {
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach(Array(text.components(separatedBy: .newlines).enumerated()), id: \.offset) { index, _ in
                            Text("\(index + 1)")
                                .font(font)
                                .foregroundColor(.secondary)
                                .frame(minWidth: 30, alignment: .trailing)
                                .padding(.trailing, 8)
                        }
                    }
                    .background(Color.secondary.opacity(0.05))
                    .overlay(
                        Rectangle()
                            .frame(width: 1)
                            .foregroundColor(Color.secondary.opacity(0.3)),
                        alignment: .trailing
                    )
                }

                // 文本内容列
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(text.components(separatedBy: .newlines).enumerated()), id: \.offset) { _, line in
                        HStack {
                            Text(line.isEmpty ? " " : line)
                                .font(font)
                                .foregroundColor(.primary)
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.leading, showLineNumbers ? 8 : 12)
                .padding(.trailing, 12)
                .padding(.vertical, 8)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(0)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }

    /// 原始文本视图（保留用于向后兼容）
    /// - Parameters:
    ///   - text: 要显示的文本内容
    ///   - title: 视图标题
    /// - Returns: 格式化的文本视图
    private func textView(text: String, title: String) -> some View {
        VStack(spacing: 0) {
            // 顶部工具栏，包含复制按钮
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Button(action: {
                    copyToClipboard(text: text)
                }) {
                    HStack(spacing: 4) {
                        // 根据复制状态显示不同图标
                        Group {
                            switch copyState {
                            case .idle:
                                Image(systemName: "doc.on.doc")
                            case .copying:
                                Image(systemName: "doc.on.doc")
                                    .rotationEffect(.degrees(copyState == .copying ? 360 : 0))
                                    .animation(.linear(duration: 0.5).repeatForever(autoreverses: false), value: copyState)
                            case .success:
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                                    .scaleEffect(copyState == .success ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: copyState)
                            case .failed:
                                Image(systemName: "xmark")
                                    .foregroundColor(.red)
                                    .scaleEffect(copyState == .failed ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: copyState)
                            }
                        }

                        // 根据复制状态显示不同文本
                        Text(copyButtonText)
                            .animation(.easeInOut(duration: 0.2), value: copyState)
                    }
                    .font(.caption)
                    .foregroundColor(copyButtonColor)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(copyButtonBackgroundColor)
                .cornerRadius(6)
                .scaleEffect(copyState == .copying ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: copyState)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.secondary.opacity(0.05))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color.secondary.opacity(0.3)),
                alignment: .bottom
            )

            // 文本内容区域
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if showLineNumbers {
                        // 带行号的文本视图
                        let lines = text.isEmpty ? [] : text.components(separatedBy: .newlines)
                        ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                            HStack(alignment: .top, spacing: 8) {
                                // 行号
                                Text("\(index + 1)")
                                    .font(font)
                                    .foregroundColor(.secondary)
                                    .frame(minWidth: 40, alignment: .trailing)
                                    .padding(.horizontal, 8)
                                    .background(Color.secondary.opacity(0.1))

                                // 文本内容
                                Text(line.isEmpty ? " " : line)
                                    .font(font)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 8)

                                Spacer()
                            }
                            .overlay(
                                Rectangle()
                                    .frame(height: 0.5)
                                    .foregroundColor(Color.secondary.opacity(0.1)),
                                alignment: .bottom
                            )
                        }
                    } else {
                        // 无行号的文本视图
                        Text(text)
                            .font(font)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
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

    /// 复制按钮文本
    private var copyButtonText: String {
        switch copyState {
        case .idle:
            return "复制"
        case .copying:
            return "复制中..."
        case .success:
            return "已复制"
        case .failed:
            return "复制失败"
        }
    }

    /// 复制按钮颜色
    private var copyButtonColor: Color {
        switch copyState {
        case .idle, .copying:
            return .blue
        case .success:
            return .green
        case .failed:
            return .red
        }
    }

    /// 复制按钮背景颜色
    private var copyButtonBackgroundColor: Color {
        switch copyState {
        case .idle, .copying:
            return Color.blue.opacity(0.1)
        case .success:
            return Color.green.opacity(0.1)
        case .failed:
            return Color.red.opacity(0.1)
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
