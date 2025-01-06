import SwiftUI

/// 主题预览容器，提供亮暗主题切换功能
public struct MagicThemePreview<Content: View>: View {
    private let content: Content
    private let showsIndicators: Bool
    @State private var isDarkMode = false
    
    /// 创建主题预览容器
    /// - Parameters:
    ///   - showsIndicators: 是否显示滚动条，默认为 true
    ///   - content: 要预览的内容视图
    public init(
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.showsIndicators = showsIndicators
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            HStack {
                Spacer()
                
                MagicButton(
                    icon: isDarkMode ? "sun.max.fill" : "moon.fill",
                    style: .secondary,
                    action: { isDarkMode.toggle() }
                )
                .magicShape(.roundedSquare)
                .padding()
            }
            .frame(height: 50)
            .background(.ultraThinMaterial)
            
            // 分隔线
            Divider()
            
            // 内容区域
            ScrollView(.vertical, showsIndicators: showsIndicators) {
                content
                    .frame(maxWidth: .infinity)
            }
        }
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
        .frame(maxHeight: .infinity)
        .background(isDarkMode ? Color(nsColor: .darkGray) : Color(nsColor: .windowBackgroundColor))
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
        
        // 示例 2：简单内容
        MagicThemePreview {
            VStack {
                Image(systemName: "star.fill")
                    .font(.title)
                Text("Star")
            }
            .padding()
        }
        .tabItem {
            Image(systemName: "2.circle.fill")
            Text("简单")
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
