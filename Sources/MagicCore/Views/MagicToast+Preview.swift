import SwiftUI

// MARK: - Basic Preview
private struct BasicToastPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("基础样式")
                .font(.headline)
            
            MagicToast(
                message: "操作成功",
                icon: "checkmark.circle",
                style: .info
            )
            
            MagicToast(
                message: "点击查看详情",
                icon: "hand.tap",
                style: .info
            )
        }
        .padding()
    }
}

// MARK: - Style Preview
private struct StyleToastPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("不同样式")
                .font(.headline)
            
            Group {
                Text("信息").font(.subheadline)
                MagicToast(
                    message: "这是一条提示信息",
                    icon: "info.circle",
                    style: .info
                )
            }
            
            Group {
                Text("警告").font(.subheadline)
                MagicToast(
                    message: "请注意这个警告",
                    icon: "exclamationmark.triangle",
                    style: .warning
                )
            }
            
            Group {
                Text("错误").font(.subheadline)
                MagicToast(
                    message: "出现了一个错误",
                    icon: "xmark.circle",
                    style: .error
                )
            }
        }
        .padding()
    }
}

// MARK: - Long Text Preview
private struct LongTextToastPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("长文本")
                .font(.headline)
            
            MagicToast(
                message: "这是一条比较长的提示信息，用来测试 Toast 的自适应宽度和换行效果",
                icon: "text.bubble",
                style: .info
            )
            
            MagicToast(
                message: "Another long message in English to test the text wrapping and adaptive width of the toast",
                icon: "text.bubble",
                style: .info
            )
        }
        .padding()
    }
}

// MARK: - Animation Preview
private struct AnimationToastPreview: View {
    @State private var showToast = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("动画效果")
                .font(.headline)
            
            Button("显示/隐藏 Toast") {
                withAnimation {
                    showToast.toggle()
                }
            }
            
            if showToast {
                Group {
                    MagicToast(
                        message: "信息提示动画",
                        icon: "info.circle",
                        style: .info
                    )
                    
                    MagicToast(
                        message: "警告提示动画",
                        icon: "exclamationmark.triangle",
                        style: .warning
                    )
                    
                    MagicToast(
                        message: "错误提示动画",
                        icon: "xmark.circle",
                        style: .error
                    )
                }
            }
        }
        .padding()
    }
}

// MARK: - Main Preview
struct MagicToastPreview: View {
    var body: some View {
        TabView {
            MagicThemePreview {
                BasicToastPreview()
            }
            .tabItem {
                Image(systemName: "1.circle.fill")
                Text("基础")
            }
            
            MagicThemePreview {
                StyleToastPreview()
            }
            .tabItem {
                Image(systemName: "2.circle.fill")
                Text("样式")
            }
            
            MagicThemePreview {
                LongTextToastPreview()
            }
            .tabItem {
                Image(systemName: "3.circle.fill")
                Text("长文本")
            }
            
            MagicThemePreview {
                AnimationToastPreview()
            }
            .tabItem {
                Image(systemName: "4.circle.fill")
                Text("动画")
            }
        }
    }
}

#Preview("MagicToast") {
    MagicToastPreview()
}