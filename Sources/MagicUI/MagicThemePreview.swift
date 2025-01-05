import SwiftUI

/// 主题预览容器，将内容视图分别以亮色和暗色主题并排显示
public struct MagicThemePreview<Content: View>: View {
    private let content: Content
    private let spacing: CGFloat
    
    /// 创建主题预览容器
    /// - Parameters:
    ///   - spacing: 亮暗主题之间的间距，默认为 0
    ///   - content: 要预览的内容视图
    public init(
        spacing: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.spacing = spacing
    }
    
    public var body: some View {
        HStack(spacing: spacing) {
            // 亮色主题
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .windowBackgroundColor))
                .environment(\.colorScheme, .light)
            
            // 暗色主题
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .darkGray))
                .environment(\.colorScheme, .dark)
        }
    }
}

// MARK: - Preview
#Preview("MagicThemePreview") {
    VStack(spacing: 20) {
        // 示例 1：基本用法
        MagicThemePreview {
            Text("Hello, World!")
                .padding()
        }
        .frame(height: 100)
        
        // 示例 2：带间距
        MagicThemePreview(spacing: 1) {
            VStack {
                Image(systemName: "star.fill")
                    .font(.title)
                Text("Star")
            }
            .padding()
        }
        .frame(height: 100)
        
        // 示例 3：复杂内容
        MagicThemePreview {
            VStack(spacing: 12) {
                Circle()
                    .fill(.blue.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "hand.wave.fill")
                            .font(.title)
                            .foregroundStyle(.blue)
                    }
                
                Text("Welcome")
                    .font(.headline)
                
                Text("This is a demo of MagicThemePreview")
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .frame(height: 200)
    }
    .padding()
} 