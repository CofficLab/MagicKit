import SwiftUI

// MARK: - MagicThemePreview
/// 主题预览容器，提供亮暗主题切换功能
public struct MagicThemePreview<Content: View>: View {
    // MARK: - Properties
    private let content: Content
    private let showsIndicators: Bool
    @State private var isDarkMode = false
    
    // MARK: - Initialization
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
    
    // MARK: - Body
    public var body: some View {
        ZStack {
            // MARK: Content Layer
            VStack(spacing: 0) {
                // MARK: Toolbar
                toolbar
                
                // MARK: Divider
                Divider()
                
                // MARK: Content Area
                ScrollView(.vertical, showsIndicators: showsIndicators) {
                    content
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .background(.background)
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
        .frame(minHeight: 800)
        .frame(idealHeight: 1200)
    }
    
    // MARK: - Toolbar View
    private var toolbar: some View {
        HStack(spacing: 8) {
            Spacer()
            
            // MARK: Theme Toggle Button
            MagicButton(
                icon: isDarkMode ? "sun.max.fill" : "moon.fill",
                style: .secondary,
                action: { isDarkMode.toggle() }
            )
            .magicShape(.circle)
        }
        .padding(.horizontal)
        .frame(height: 50)
        .background(Color.primary.opacity(0.05))
    }
}

// MARK: - Preview
#Preview("MagicThemePreview") {
    TabView {
        // MARK: Basic Example
        MagicThemePreview {
            Text("Hello, World!")
                .padding()
        }
        .tabItem {
            Image(systemName: "1.circle.fill")
            Text("基本")
        }
        
        // MARK: Simple Content Example
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
        
        // MARK: Complex Content Example
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
        
        // MARK: Scrolling Content Example
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
