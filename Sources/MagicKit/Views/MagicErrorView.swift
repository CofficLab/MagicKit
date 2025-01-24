import SwiftUI

/// 用于展示详细错误信息的视图组件
public struct MagicErrorView: View {
    let error: Error
    @State private var showCopied = false
    
    public init(error: Error) {
        self.error = error
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 错误图标和标题
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.title2)
                
                Text("错误详情")
                    .font(.headline)
                
                Spacer()
                
                // 复制按钮
                Button {
                    copyErrorInfo()
                } label: {
                    Label(showCopied ? "已复制" : "复制", systemImage: showCopied ? "checkmark.circle.fill" : "doc.on.doc")
                        .foregroundStyle(showCopied ? .green : .blue)
                        .animation(.default, value: showCopied)
                }
                .buttonStyle(.borderless)
            }
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // 错误描述
                    ErrorSection(title: "错误描述", content: error.localizedDescription)
                    
                    // 失败原因
                    if let failureReason = (error as? LocalizedError)?.failureReason {
                        ErrorSection(title: "失败原因", content: failureReason)
                    }
                    
                    // 恢复建议
                    if let recoverySuggestion = (error as? LocalizedError)?.recoverySuggestion {
                        ErrorSection(title: "恢复建议", content: recoverySuggestion)
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: 300, maxWidth: 400)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 5)
    }
    
    private func copyErrorInfo() {
        var errorInfo = [String]()
        
        errorInfo.append("错误描述：\n\(error.localizedDescription)")
        
        if let failureReason = (error as? LocalizedError)?.failureReason {
            errorInfo.append("\n失败原因：\n\(failureReason)")
        }
        
        if let recoverySuggestion = (error as? LocalizedError)?.recoverySuggestion {
            errorInfo.append("\n恢复建议：\n\(recoverySuggestion)")
        }
        
        let fullErrorInfo = errorInfo.joined(separator: "\n")
        fullErrorInfo.copy()
        
        showCopied = true
        
        // 2秒后重置复制状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopied = false
        }
    }
}

/// 错误信息区域组件
private struct ErrorSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(content)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // MagicError 预览
        MagicErrorView(error: MagicError.networkError("无法连接到服务器"))
        
        // PlaybackError 预览
        MagicErrorView(error: NSError(domain: "PlaybackError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Connection timeout"]))
        
        // HttpError 预览
        MagicErrorView(error: HttpError.HttpStatusError(404))
    }
    .padding()
    .background(.background)
}
