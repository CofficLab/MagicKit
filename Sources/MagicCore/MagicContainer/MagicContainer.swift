import SwiftUI

/// 主题预览容器，提供亮暗主题切换功能
struct MagicContainer<Content: View>: View {
    // MARK: - Properties
    private let content: Content
    private let showsIndicators: Bool
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var isDarkMode: Bool = false
    @State private var selectedSize: PreviewSize = .full
    
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
                Divider().padding(.bottom, 10)
                
                // MARK: Content Area
                ScrollView(.vertical, showsIndicators: showsIndicators) {
                    content
                        .frame(
                            width: selectedSize == .full ? nil : selectedSize.size.width,
                            height: selectedSize == .full ? nil : selectedSize.size.height
                        )
                        .frame(maxWidth: .infinity)
                        .background(selectedSize == .full ? nil : Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: selectedSize == .full ? 0 : 8))
                        .dashedBorder(
                            color: .secondary.opacity(0.8),
                            lineWidth: 2,
                            dash: [8, 4]
                        )
                        .padding(.horizontal, selectedSize == .full ? 16 : 40)
                        .padding(.vertical, selectedSize == .full ? 12 : 20)
                }
            }
        }
        .background(.background)
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
        .frame(minHeight: 750)
        .frame(idealHeight: 1000)
        .onAppear {
            // 初始化时跟随系统主题
            isDarkMode = systemColorScheme == .dark
        }
    }
    
    // MARK: - Toolbar View
    private var toolbar: some View {
        HStack(spacing: 8) {
            // MARK: Size Selector
            Picker("Size", selection: $selectedSize) {
                ForEach(PreviewSize.allCases, id: \.self) { size in
                    HStack {
                        Image(systemName: size.icon)
                        Text(size.rawValue)
                    }
                    .tag(size)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 120)
            
            // MARK: Size Dimensions Label
            if selectedSize != .full {
                Text(selectedSize.dimensions)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            Spacer()
            
            // MARK: Theme Toggle Button
            MagicButton(
                icon: isDarkMode ? "sun.max.fill" : "moon.fill",
                style: .secondary,
                action: { _ in
                    isDarkMode.toggle() }
            )
            .magicShape(.circle)
        }
        .padding(.horizontal)
        .frame(height: 50)
        .background(Color.primary.opacity(0.05))
    }
}

// MARK: - Preview

#if DEBUG
#Preview("MagicContainerPreview") {
    MagicContainerPreview()
}
#endif
