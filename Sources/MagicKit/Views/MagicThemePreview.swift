import SwiftUI

// MARK: - MagicThemePreview
/// 主题预览容器，提供亮暗主题切换功能
public struct MagicThemePreview<Content: View>: View {
    // MARK: - Properties
    private let content: Content
    private let showsIndicators: Bool
    @State private var isDarkMode = false
    @State private var selectedSize: PreviewSize = .full
    
    // Add this enum
    private enum PreviewSize: String, CaseIterable {
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
                return CGSize(width: 375, height: 667)
            case .iPhone:
                return CGSize(width: 390, height: 844)
            case .iPhonePlus:
                return CGSize(width: 428, height: 926)
            case .iPhoneMax:
                return CGSize(width: 430, height: 932)
            case .iPadMini:
                return CGSize(width: 744, height: 1133)
            case .iPad:
                return CGSize(width: 820, height: 1180)
            case .iPadPro11:
                return CGSize(width: 834, height: 1194)
            case .iPadPro12:
                return CGSize(width: 1024, height: 1366)
            case .mac:
                return CGSize(width: 1024, height: 768)
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
    }
    
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
                            maxWidth: selectedSize == .full ? .infinity : selectedSize.size.width,
                            maxHeight: selectedSize == .full ? .infinity : selectedSize.size.height
                        )
                        .frame(maxWidth: .infinity)
                        .background(selectedSize == .full ? nil : Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: selectedSize == .full ? 0 : 8))
                        .overlay(
                            Group {
                                if selectedSize != .full {
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(style: StrokeStyle(
                                            lineWidth: 2,
                                            dash: [8, 4]
                                        ))
                                        .foregroundStyle(.secondary.opacity(0.8))
                                        .padding(20)
                                }
                            }
                        )
                        .padding(.horizontal, selectedSize == .full ? 0 : 40)
                        .padding(.vertical, selectedSize == .full ? 0 : 20)
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
