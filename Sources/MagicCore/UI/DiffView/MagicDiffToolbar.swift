import SwiftUI

/// 差异视图的工具栏组件
struct MagicDiffToolbar: View {
    @Binding var selectedView: MagicDiffViewMode
    @Binding var selectedLanguage: CodeLanguage
    @Binding var copyState: CopyState
    
    let oldText: String
    let newText: String
    var onCopy: (String) -> Void
    
    var body: some View {
        HStack {
            // 左侧：视图切换选择器和语言选择器
            HStack(spacing: 16) {
                // 视图切换选择器
                Picker("", selection: $selectedView) {
                    ForEach(MagicDiffViewMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(maxWidth: 300)
                
                // 语言选择器
                languagePickerView
                .frame(maxWidth: 150)
            }

            Spacer()

            // 右侧：复制按钮（仅在文本视图时显示）
            if selectedView != .diff {
                MagicDiffCopyButton(
                    copyState: copyState,
                    action: {
                        let textToCopy = selectedView == .original ? oldText : newText
                        onCopy(textToCopy)
                    }
                )
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
    }
    
    /// 语言选择器视图
    private var languagePickerView: some View {
        Picker("语言", selection: $selectedLanguage) {
            ForEach(CodeLanguage.allCases, id: \.self) { language in
                Text(language.displayName).tag(language)
            }
        }
    }
}

#Preview {
    MagicDiffToolbar(
        selectedView: .constant(.diff),
        selectedLanguage: .constant(.swift),
        copyState: .constant(.idle),
        oldText: "Hello World",
        newText: "Hello Swift",
        onCopy: { _ in }
    )
}