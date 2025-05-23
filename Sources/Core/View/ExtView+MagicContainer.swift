import SwiftUI

public extension View {
    /// 为预览视图添加通用容器
    func inMagicContainer() -> some View {
        MagicThemePreview {
            self
        }
    }
}

enum PreviewSize: String, CaseIterable {
    case full = "全屏"
    case iPhoneSE = "iPhone SE"
    case iPhone = "iPhone 14"
    case iPhonePlus = "iPhone 14 Plus"
    case iPhoneMax = "iPhone 14 Pro Max"
    case iPadMini = "iPad mini"
    case iPad = "iPad"
    case iPadPro11 = "iPad Pro 11"
    case iPadPro12 = "iPad Pro 12.9"
    case mac = "Mac"
    
    var size: CGSize {
        switch self {
        case .full:
            return CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
        case .iPhoneSE:
            return .iPhoneSE
        case .iPhone:
            return .iPhone
        case .iPhonePlus:
            return .iPhonePlus
        case .iPhoneMax:
            return .iPhoneMax
        case .iPadMini:
            return .iPadMini
        case .iPad:
            return .iPad
        case .iPadPro11:
            return .iPadPro11
        case .iPadPro12:
            return .iPadPro12
        case .mac:
            return .mac
        }
    }
    
    var icon: String {
        switch self {
        case .full:
            return "rectangle"
        case .iPhoneSE, .iPhone, .iPhonePlus, .iPhoneMax:
            return "iphone"
        case .iPadMini, .iPad, .iPadPro11, .iPadPro12:
            return "ipad"
        case .mac:
            return "desktopcomputer"
        }
    }
    
    var dimensions: String {
        let size = self.size
        if size.width == .infinity || size.height == .infinity {
            return "自适应"
        }
        return String(format: "%.0f × %.0f", size.width, size.height)
    }
}

// MARK: - MagicThemePreview
/// 主题预览容器，提供亮暗主题切换功能
struct MagicThemePreview<Content: View>: View {
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
        Text("Hello, World!")
            .padding()
            .inMagicContainer()
            .tabItem {
                Image(systemName: "1.circle.fill")
                Text("基本")
            }
        
        // MARK: Simple Content Example
        VStack {
            Image(systemName: "star.fill")
                .font(.title)
            Text("Star")
        }
        .padding()
        .inMagicContainer()
        .tabItem {
            Image(systemName: "2.circle.fill")
            Text("简单")
        }
        
        // MARK: Complex Content Example
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
        .inMagicContainer()
        .tabItem {
            Image(systemName: "3.circle.fill")
            Text("复杂")
        }
        
        // MARK: Scrolling Content Example
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
        .inMagicContainer()
        .tabItem {
            Image(systemName: "4.circle.fill")
            Text("滚动")
        }
    }
} 
