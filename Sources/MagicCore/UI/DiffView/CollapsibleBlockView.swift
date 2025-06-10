import SwiftUI

/// 折叠块视图
/// 用于显示可折叠的连续未变动行
struct CollapsibleBlockView: View {
    @State private var block: CollapsibleBlock
    let showLineNumbers: Bool
    let font: Font
    
    /// 创建折叠块视图
    /// - Parameters:
    ///   - block: 折叠块数据
    ///   - showLineNumbers: 是否显示行号
    ///   - font: 字体
    init(block: CollapsibleBlock, showLineNumbers: Bool, font: Font) {
        self._block = State(initialValue: block)
        self.showLineNumbers = showLineNumbers
        self.font = font
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if block.isCollapsed {
                collapsedView
            } else {
                expandedView
            }
        }
    }
    
    /// 折叠状态的视图
    private var collapsedView: some View {
        Button(action: toggleCollapse) {
            HStack(alignment: .center, spacing: 0) {
                if showLineNumbers {
                    collapsedLineNumberView
                }
                
                collapsedContentView
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color.secondary.opacity(0.05))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.secondary.opacity(0.2)),
            alignment: .bottom
        )
    }
    
    /// 展开状态的视图
    private var expandedView: some View {
        VStack(spacing: 0) {
            // 折叠按钮
            Button(action: toggleCollapse) {
                HStack(alignment: .center, spacing: 0) {
                    if showLineNumbers {
                        expandButtonLineNumberView
                    }
                    
                    expandButtonContentView
                }
            }
            .buttonStyle(PlainButtonStyle())
            .background(Color.secondary.opacity(0.05))
            
            // 展开的行
            ForEach(Array(block.lines.enumerated()), id: \.offset) { index, line in
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
    
    /// 折叠状态的行号视图
    @ViewBuilder
    private var collapsedLineNumberView: some View {
        HStack(spacing: 0) {
            // 显示行号范围
            Text("\(block.startLineNumber)")
                .frame(width: 16, alignment: .trailing)
                .foregroundColor(.secondary.opacity(0.7))
            
            Text("\(block.startLineNumber)")
                .frame(width: 16, alignment: .trailing)
                .foregroundColor(.secondary.opacity(0.7))
            
            // 折叠图标
            Image(systemName: "chevron.right")
                .frame(width: 16, alignment: .center)
                .foregroundColor(.secondary)
                .font(.system(.caption, design: .monospaced))
        }
        .font(.system(.caption, design: .monospaced))
        .padding(.horizontal, 6)
        .padding(.vertical, 1)
        .background(Color.secondary.opacity(0.1))
    }
    
    /// 展开按钮的行号视图
    @ViewBuilder
    private var expandButtonLineNumberView: some View {
        HStack(spacing: 0) {
            Text("")
                .frame(width: 16, alignment: .trailing)
            
            Text("")
                .frame(width: 16, alignment: .trailing)
            
            // 展开图标
            Image(systemName: "chevron.down")
                .frame(width: 16, alignment: .center)
                .foregroundColor(.secondary)
                .font(.system(.caption, design: .monospaced))
        }
        .font(.system(.caption, design: .monospaced))
        .padding(.horizontal, 6)
        .padding(.vertical, 1)
        .background(Color.secondary.opacity(0.1))
    }
    
    /// 折叠状态的内容视图
    private var collapsedContentView: some View {
        HStack {
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
            
            Text("\(block.lines.count) 行未变动")
                .font(font)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
    
    /// 展开按钮的内容视图
    private var expandButtonContentView: some View {
        HStack {
            Image(systemName: "chevron.down")
                .foregroundColor(.secondary)
                .font(.caption)
            
            Text("折叠 \(block.lines.count) 行")
                .font(font)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
    
    /// 切换折叠状态
    private func toggleCollapse() {
        withAnimation(.easeInOut(duration: 0.2)) {
            block = CollapsibleBlock(
                lines: block.lines,
                isCollapsed: !block.isCollapsed,
                startLineNumber: block.startLineNumber,
                endLineNumber: block.endLineNumber
            )
        }
    }
}

// MARK: - Preview
#Preview("CollapsibleBlockView") {
    let sampleLines = [
        DiffLine(content: "unchanged line 1", type: .unchanged, oldLineNumber: 5, newLineNumber: 5),
        DiffLine(content: "unchanged line 2", type: .unchanged, oldLineNumber: 6, newLineNumber: 6),
        DiffLine(content: "unchanged line 3", type: .unchanged, oldLineNumber: 7, newLineNumber: 7),
        DiffLine(content: "unchanged line 4", type: .unchanged, oldLineNumber: 8, newLineNumber: 8)
    ]
    
    let block = CollapsibleBlock(
        lines: sampleLines,
        isCollapsed: true,
        startLineNumber: 5,
        endLineNumber: 8
    )
    
    VStack {
        CollapsibleBlockView(
            block: block,
            showLineNumbers: true,
            font: .system(.body, design: .monospaced)
        )
    }
    .padding()
    .frame(height: 600)
}
