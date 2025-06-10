import SwiftUI

/// 复制状态枚举
enum CopyState {
    case idle
    case copying
    case success
    case failed
}

/// 复制操作的浮动提示视图
struct MagicDiffCopyToast: View {
    let copyState: CopyState
    let message: String
    
    var body: some View {
        if !message.isEmpty {
            VStack {
                Spacer()

                HStack {
                    Spacer()

                    HStack(spacing: 8) {
                        Image(systemName: copyState == .success ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .foregroundColor(copyState == .success ? .green : .red)

                        Text(message)
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
                    .scaleEffect(message.isEmpty ? 0.8 : 1.0)
                    .opacity(message.isEmpty ? 0 : 1)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: message)

                    Spacer()
                }
                .padding(.bottom, 20)
            }
            .allowsHitTesting(false)
        } else {
            EmptyView()
        }
    }
}

/// 复制按钮视图
struct MagicDiffCopyButton: View {
    let copyState: CopyState
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
}