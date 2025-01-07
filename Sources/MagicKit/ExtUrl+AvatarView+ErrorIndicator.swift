import SwiftUI

extension AvatarView {
    /// 错误指示视图组件
    struct ErrorIndicatorView: View {
        let error: Error
        @State private var showError = false
        @State private var isCopied = false
        
        var body: some View {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(.red)
                .popover(isPresented: $showError) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("错误详情")
                            .font(.headline)
                        
                        Divider()
                        
                        Text(error.localizedDescription)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                        
                        Divider()
                        
                        Button(action: {
                            error.localizedDescription.copy()
                            isCopied = true
                            
                            // 2秒后重置复制状态
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isCopied = false
                            }
                        }) {
                            HStack {
                                Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                                Text(isCopied ? "已复制" : "复制错误信息")
                            }
                            .foregroundStyle(isCopied ? .green : .accentColor)
                        }
                        .buttonStyle(.borderless)
                    }
                    .frame(minWidth: 200, maxWidth: 300)
                }
                .onTapGesture {
                    showError = true
                }
        }
    }
}

#Preview {
    AvatarView.ErrorIndicatorView(error: URLError(.badURL))
        .frame(width: 100, height: 100)
} 