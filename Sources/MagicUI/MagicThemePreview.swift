import SwiftUI

/// 主题预览容器，将内容视图分别以亮色和暗色主题并排显示
public struct MagicThemePreview<Content: View>: View {
    private let content: Content
    private let spacing: CGFloat
    private let showsIndicators: Bool
    
    /// 创建主题预览容器
    /// - Parameters:
    ///   - spacing: 亮暗主题之间的间距，默认为 0
    ///   - showsIndicators: 是否显示滚动条，默认为 true
    ///   - content: 要预览的内容视图
    public init(
        spacing: CGFloat = 0,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.spacing = spacing
        self.showsIndicators = showsIndicators
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: showsIndicators) {
                HStack(spacing: spacing) {
                    // 亮色主题
                    content
                        .frame(maxWidth: .infinity, minHeight: geometry.size.height)
                        .background(Color(nsColor: .windowBackgroundColor))
                        .environment(\.colorScheme, .light)
                    
                    // 暗色主题
                    content
                        .frame(maxWidth: .infinity, minHeight: geometry.size.height)
                        .background(Color(nsColor: .darkGray))
                        .environment(\.colorScheme, .dark)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Preview
#Preview("MagicThemePreview") {
    TabView {
        // 示例 1：基本用法
        MagicThemePreview {
            Text("Hello, World!")
                .padding()
        }
        .tabItem {
            Image(systemName: "1.circle.fill")
            Text("基本")
        }
        
        // 示例 2：带间距
        MagicThemePreview(spacing: 1) {
            VStack {
                Image(systemName: "star.fill")
                    .font(.title)
                Text("Star")
            }
            .padding()
        }
        .tabItem {
            Image(systemName: "2.circle.fill")
            Text("间距")
        }
        
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
        .tabItem {
            Image(systemName: "3.circle.fill")
            Text("复杂")
        }
        
        // 示例 4：长内容滚动
        MagicThemePreview {
            VStack(spacing: 16) {
                ForEach(1...20, id: \.self) { index in
                    HStack {
                        Circle()
                            .fill(.blue.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Text("\(index)")
                                    .foregroundStyle(.blue)
                            }
                        
                        VStack(alignment: .leading) {
                            Text("Item \(index)")
                                .font(.headline)
                            Text("This is a long description for item \(index) to demonstrate scrolling behavior")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
        }
        .tabItem {
            Image(systemName: "4.circle.fill")
            Text("滚动")
        }
    }
} 
