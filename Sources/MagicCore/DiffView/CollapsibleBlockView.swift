import SwiftUI

/// 折叠块视图
/// 用于显示可折叠的连续未变动行
struct CollapsibleBlockView: View {
    @State private var block: CollapsibleBlock
    let showLineNumbers: Bool
    let font: Font
    let displayMode: MagicDiffViewMode
    
    /// 创建折叠块视图
    /// - Parameters:
    ///   - block: 折叠块数据
    ///   - showLineNumbers: 是否显示行号
    ///   - font: 字体
    ///   - displayMode: 显示模式
    init(
        block: CollapsibleBlock, 
        showLineNumbers: Bool, 
        font: Font,
        displayMode: MagicDiffViewMode = .diff
    ) {
        self._block = State(initialValue: block)
        self.showLineNumbers = showLineNumbers
        self.font = font
        self.displayMode = displayMode
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
                    font: font,
                    displayMode: displayMode
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
            // 根据显示模式显示行号
            switch displayMode {
            case .original:
                // 原始模式只显示一列行号
                Text("\(block.startLineNumber)")
                    .font(.system(.body, design: .monospaced))
                    .frame(width: 32, alignment: .trailing)
                    .foregroundColor(.secondary.opacity(0.7))
            case .modified:
                // 修改模式只显示一列行号
                Text("\(block.startLineNumber)")
                    .font(.system(.body, design: .monospaced))
                    .frame(width: 32, alignment: .trailing)
                    .foregroundColor(.secondary.opacity(0.7))
            case .diff:
                // 差异模式显示两列行号
                Text("\(block.startLineNumber)")
                    .font(.system(.body, design: .monospaced))
                    .frame(width: 32, alignment: .trailing)
                    .foregroundColor(.secondary.opacity(0.7))
                Text("\(block.startLineNumber)")
                    .font(.system(.body, design: .monospaced))
                    .frame(width: 32, alignment: .trailing)
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
        .frame(maxHeight: .infinity)
        .font(.system(.caption, design: .monospaced))
        .padding(.horizontal, 6)
        .padding(.vertical, 1)
        .background(Color.secondary.opacity(0.1))
    }
    
    /// 展开按钮的行号视图
    @ViewBuilder
    private var expandButtonLineNumberView: some View {
        HStack(spacing: 0) {
            // 根据显示模式显示空白行号区域
            switch displayMode {
            case .original, .modified:
                // 单列模式显示一个32宽的空白
                Text("")
                    .frame(width: 32, alignment: .trailing)
            case .diff:
                // 差异模式显示两个16宽的空白
                Text("")
                    .frame(width: 32, alignment: .trailing)
                Text("")
                    .frame(width: 32, alignment: .trailing)
            }
        }
        .frame(maxHeight: .infinity)
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

#Preview("MagicDiffPreviewView") {
    MagicDiffPreviewView()
        .inMagicContainer()
}
