import SwiftUI

/// 一个功能丰富的按钮组件，支持多种样式、大小和形状
///
/// MagicButton 提供了丰富的自定义选项：
/// - 支持图标和文本组合
/// - 提供主要和次要两种样式
/// - 支持四种尺寸：自动、小、中、大
/// - 提供多种形状选项
/// - 支持禁用状态和提示
/// - 支持弹出内容
///
/// 基本用法：
/// ```swift
/// MagicButton(icon: "star", action: {})
///     .magicTitle("按钮")
///     .magicStyle(.primary)
/// ```
public struct MagicButton: View {
    /// 按钮样式
    public enum Style {
        /// 主要样式，用于强调重要操作
        case primary
        /// 次要样式，用于普通操作
        case secondary
        /// 自定义颜色样式
        case custom(Color)
        /// 自定义背景视图
        case customView(AnyView)
    }
    
    /// 按钮大小
    public enum Size: Equatable {
        /// 迷你尺寸，适用于极度紧凑的布局
        case mini
        /// 自动模式，占据尽可能多的空间
        case auto
        /// 小尺寸，适用于紧凑布局
        case small
        /// 常规尺寸，默认选项
        case regular
        /// 大尺寸，适用于强调显示
        case large
        /// 超大尺寸，适用于特殊场景
        case extraLarge
        /// 巨大尺寸，适用于焦点元素
        case huge
        /// 自定义尺寸
        case custom(CGFloat)
        
        /// 获取固定尺寸的按钮大小
        var fixedSize: CGFloat {
            switch self {
            case .mini:
                return 24
            case .auto:
                return 0 // 自动模式不使用固定值
            case .small:
                return 32
            case .regular:
                return 40
            case .large:
                return 50
            case .extraLarge:
                return 64
            case .huge:
                return 80
            case .custom(let size):
                return size
            }
        }
        
        /// 获取图标大小
        func iconSize(containerSize: CGFloat) -> CGFloat {
            switch self {
            case .mini:
                return 10
            case .auto:
                return 20  // 自动模式下使用默认大小
            case .small:
                return 12
            case .regular:
                return 15
            case .large:
                return 20
            case .extraLarge:
                return 24
            case .huge:
                return 32
            case .custom(let size):
                return size * 0.4
            }
        }
        
        /// 获取字体大小
        var font: Font {
            switch self {
            case .mini:
                return .caption2
            case .auto:
                return .body
            case .small:
                return .caption
            case .regular:
                return .body
            case .large:
                return .title3
            case .extraLarge:
                return .title2
            case .huge:
                return .title
            case .custom:
                return .body
            }
        }
        
        /// 获取水平内边距
        var horizontalPadding: CGFloat {
            switch self {
            case .mini:
                return 6
            case .auto:
                return 16
            case .small:
                return 8
            case .regular:
                return 12
            case .large:
                return 16
            case .extraLarge:
                return 20
            case .huge:
                return 24
            case .custom:
                return 16
            }
        }
        
        /// 获取垂直内边距
        var verticalPadding: CGFloat {
            switch self {
            case .mini:
                return 2
            case .auto:
                return 12
            case .small:
                return 4
            case .regular:
                return 8
            case .large:
                return 12
            case .extraLarge:
                return 16
            case .huge:
                return 20
            case .custom:
                return 12
            }
        }
    }
    
    /// 按钮形状
    public enum Shape {
        /// 圆形，当没有标题时自动采用正圆形状
        case circle
        /// 胶囊形（两端圆角），适用于带文本的按钮
        case capsule
        /// 矩形（无圆角），适用于网格布局
        case rectangle
        /// 圆角矩形（固定圆角），通用选项
        case roundedRectangle
        /// 圆角正方形，适用于图标按钮
        case roundedSquare
        /// 自定义圆角矩形，可以为每个角设置不同的圆角半径
        /// - Parameters:
        ///   - topLeft: 左上角圆角半径
        ///   - topRight: 右上角圆角半径
        ///   - bottomLeft: 左下角圆角半径
        ///   - bottomRight: 右下角圆角半径
        case customRoundedRectangle(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat)
        /// 自定义胶囊形，可以为左右两端设置不同的圆角半径
        /// - Parameters:
        ///   - leftRadius: 左侧圆角半径
        ///   - rightRadius: 右侧圆角半径
        case customCapsule(leftRadius: CGFloat, rightRadius: CGFloat)
        
        /// 获取形状的圆角半径
        var cornerRadius: CGFloat {
            switch self {
            case .circle:
                return .infinity
            case .capsule:
                return .infinity
            case .rectangle:
                return 0
            case .roundedRectangle:
                return 8
            case .roundedSquare:
                return 12
            case .customRoundedRectangle(_, _, _, _):
                return 0 // 由自定义值决定
            case .customCapsule(_, _):
                return 0 // 由自定义值决定
            }
        }
    }
    
    /// 按钮形状的显示时机
    public enum ShapeVisibility {
        /// 始终显示形状
        case always
        /// 仅在悬停时显示形状
        case onHover
    }
    
    /// 加载动画样式
    public enum LoadingStyle {
        case spinner
        case dots
        case pulse
        case none
    }
    
    // MARK: - Properties
    
    /// SF Symbols 图标名称
    let icon: String?
    /// 按钮标题（可选）
    let title: String?
    /// 按钮样式
    let style: Style
    /// 按钮大小
    let size: Size
    /// 按钮形状
    let shape: Shape
    /// 形状显示时机
    let shapeVisibility: ShapeVisibility
    /// 禁用状态的提示文本
    let disabledReason: String?
    /// 弹出内容
    let popoverContent: AnyView?
    /// 点击动作
    let action: (() -> Void)?
    /// 异步点击动作
    let asyncAction: (() async -> Void)?
    /// 自定义背景色
    let customBackgroundColor: Color?
    /// 是否启用防重复点击
    let preventDoubleClick: Bool
    /// 加载动画样式
    let loadingStyle: LoadingStyle
    
    @State private var isHovering = false
    @State private var containerSize: CGFloat = 0
    @State private var showingDisabledPopover = false
    @State private var showingPopover = false
    @State private var showingTooltip = false
    @State private var shouldShowTitle = false
    @State private var isLoading = false
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Initialization
    
    /// 创建一个 MagicButton
    /// - Parameters:
    ///   - icon: SF Symbols 图标名称
    ///   - title: 按钮标题（可选）
    ///   - style: 按钮样式（默认为 .primary）
    ///   - size: 按钮大小（默认为 .regular）
    ///   - shape: 按钮形状（默认为 .circle）
    ///   - shapeVisibility: 形状显示时机（默认为 .always）
    ///   - disabledReason: 禁用状态的提示文本（如果为 nil 则按钮可用）
    ///   - popoverContent: 弹出内容（可选）
    ///   - action: 点击动作
    ///   - customBackgroundColor: 自定义背景色
    ///   - preventDoubleClick: 是否启用防重复点击
    ///   - loadingStyle: 加载动画样式
    public init(
        icon: String? = nil,
        title: String? = nil,
        style: Style = .primary,
        size: Size = .regular,
        shape: Shape = .roundedRectangle,
        shapeVisibility: ShapeVisibility = .always,
        disabledReason: String? = nil,
        popoverContent: AnyView? = nil,
        action: (() -> Void)? = nil,
        customBackgroundColor: Color? = nil,
        preventDoubleClick: Bool = true,
        loadingStyle: LoadingStyle = .spinner
    ) {
        // 确保至少有一个显示内容
        if icon == nil && title == nil {
            self.icon = "circle"
            self.title = nil
        } else {
            self.icon = icon
            self.title = title
        }
        
        self.style = style
        self.size = size
        self.shape = shape
        self.shapeVisibility = shapeVisibility
        self.disabledReason = disabledReason
        self.popoverContent = popoverContent
        self.action = action
        self.customBackgroundColor = customBackgroundColor
        self.preventDoubleClick = preventDoubleClick
        self.loadingStyle = loadingStyle
        self.asyncAction = nil
    }
    
    /// 创建一个支持异步操作的 MagicButton
    /// - Parameters:
    ///   - icon: SF Symbols 图标名称
    ///   - title: 按钮标题（可选）
    ///   - style: 按钮样式（默认为 .primary）
    ///   - size: 按钮大小（默认为 .regular）
    ///   - shape: 按钮形状（默认为 .circle）
    ///   - shapeVisibility: 形状显示时机（默认为 .always）
    ///   - disabledReason: 禁用状态的提示文本（如果为 nil 则按钮可用）
    ///   - popoverContent: 弹出内容（可选）
    ///   - customBackgroundColor: 自定义背景色
    ///   - preventDoubleClick: 是否启用防重复点击
    ///   - loadingStyle: 加载动画样式
    ///   - asyncAction: 异步点击动作
    public init(
        icon: String? = nil,
        title: String? = nil,
        style: Style = .primary,
        size: Size = .regular,
        shape: Shape = .roundedRectangle,
        shapeVisibility: ShapeVisibility = .always,
        disabledReason: String? = nil,
        popoverContent: AnyView? = nil,
        customBackgroundColor: Color? = nil,
        preventDoubleClick: Bool = true,
        loadingStyle: LoadingStyle = .spinner,
        asyncAction: @escaping () async -> Void
    ) {
        // 确保至少有一个显示内容
        if icon == nil && title == nil {
            self.icon = "circle"
            self.title = nil
        } else {
            self.icon = icon
            self.title = title
        }
        
        self.style = style
        self.size = size
        self.shape = shape
        self.shapeVisibility = shapeVisibility
        self.disabledReason = disabledReason
        self.popoverContent = popoverContent
        self.action = nil
        self.customBackgroundColor = customBackgroundColor
        self.preventDoubleClick = preventDoubleClick
        self.loadingStyle = loadingStyle
        self.asyncAction = asyncAction
    }
    
    public var body: some View {
        // 外层容器
        let container = Group {
            if size == .auto {
                containerContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                containerContent
                    .frame(
                        width: isCircularShape ? size.fixedSize : size.fixedSize,
                        height: size.fixedSize
                    )
            }
        }
        
        return container
            .background(shouldShowShape ? buttonShape : nil)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovering = hovering
                    // 只有当按钮是纯图标模式且有标题时才显示tooltip
                    if shouldShowTooltip {
                        showingTooltip = hovering
                    }
                }
            }
            .popover(isPresented: $showingTooltip, arrowEdge: .top) {
                if let tooltipText = title {
                    Text(tooltipText)
                        .font(.caption)
                        .padding(8)
                }
            }
            .scaleEffect(isHovering ? 1.05 : 1.0)
            .shadow(
                color: isHovering ? Color.accentColor.opacity(0.2) : .clear,
                radius: isHovering ? 8 : 0,
                y: isHovering ? 2 : 0
            )
            .onTapGesture {
                guard disabledReason == nil else {
                    showingDisabledPopover = true
                    return
                }
                
                guard !(preventDoubleClick && isLoading) else {
                    return
                }
                
                handleTap()
            }
            .popover(isPresented: $showingPopover) {
                if let content = popoverContent {
                    content
                }
            }
            .popover(isPresented: $showingDisabledPopover) {
                if let reason = disabledReason {
                    Text(reason)
                        .padding()
                }
            }
            .onAppear {
                // 确保初始状态正确设置
                if showingPopover {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.showingPopover = true
                    }
                }
            }
    }
    
    // 内部按钮内容
    @ViewBuilder
    private var containerContent: some View {
        if isLoading && loadingStyle != .none {
            loadingView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        } else {
            GeometryReader { geometry in
                let minSize = min(geometry.size.width, geometry.size.height)
                
                HStack(spacing: 4) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: size.iconSize(containerSize: minSize)))
                    }
                    if shouldShowTitle, let title = title {
                        Text(title)
                            .font(size.font)
                            .lineLimit(1)
                    }
                }
                .foregroundStyle(foregroundColor)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2
                )
                .onAppear {
                    // 如果有标题且按钮宽度足够，或者没有图标，则显示标题
                    shouldShowTitle = (title != nil) && (geometry.size.width > 80 || icon == nil)
                }
            }
            .buttonStyle(MagicButtonStyle())
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        switch loadingStyle {
        case .spinner:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(0.8)
                .frame(width: 20, height: 20)
        case .dots:
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(foregroundColor)
                        .frame(width: 6, height: 6)
                        .scaleEffect(isLoading ? 1.0 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: isLoading
                        )
                }
            }
        case .pulse:
            Circle()
                .fill(foregroundColor)
                .frame(width: 20, height: 20)
                .scaleEffect(isLoading ? 1.2 : 0.8)
                .opacity(isLoading ? 0.6 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                    value: isLoading
                )
        case .none:
            EmptyView()
        }
    }
    
    private var isCircularShape: Bool {
        if case .circle = shape {
            return title == nil
        }
        return false
    }
    
    @ViewBuilder
    private var buttonShape: some View {
        switch shape {
        case .circle:
            if case .customView(let view) = style {
                Circle()
                    .fill(backgroundColor)
                    .overlay(
                        view
                            .clipShape(Circle())
                            .allowsHitTesting(false)
                    )
                    .shadow(color: shadowColor, radius: 8)
            } else {
                Circle()
                    .fill(backgroundColor)
                    .shadow(color: shadowColor, radius: 8)
            }
            
        case .capsule:
            if case .customView(let view) = style {
                Capsule()
                    .fill(backgroundColor)
                    .overlay(
                        view
                            .clipShape(Capsule())
                            .allowsHitTesting(false)
                    )
                    .shadow(color: shadowColor, radius: 8)
            } else {
                Capsule()
                    .fill(backgroundColor)
                    .shadow(color: shadowColor, radius: 8)
            }
            
        case .rectangle:
            if case .customView(let view) = style {
                Rectangle()
                    .fill(backgroundColor)
                    .overlay(
                        view
                            .clipShape(Rectangle())
                            .allowsHitTesting(false)
                    )
                    .shadow(color: shadowColor, radius: 8)
            } else {
                Rectangle()
                    .fill(backgroundColor)
                    .shadow(color: shadowColor, radius: 8)
            }
            
        case .roundedRectangle:
            if case .customView(let view) = style {
                RoundedRectangle(cornerRadius: shape.cornerRadius)
                    .fill(backgroundColor)
                    .overlay(
                        view
                            .clipShape(RoundedRectangle(cornerRadius: shape.cornerRadius))
                            .allowsHitTesting(false)
                    )
                    .shadow(color: shadowColor, radius: 8)
            } else {
                RoundedRectangle(cornerRadius: shape.cornerRadius)
                    .fill(backgroundColor)
                    .shadow(color: shadowColor, radius: 8)
            }
            
        case .roundedSquare:
            if case .customView(let view) = style {
                RoundedRectangle(cornerRadius: shape.cornerRadius)
                    .fill(backgroundColor)
                    .frame(width: buttonSize, height: buttonSize)
                    .overlay(
                        view
                            .clipShape(RoundedRectangle(cornerRadius: shape.cornerRadius))
                            .allowsHitTesting(false)
                    )
                    .shadow(color: shadowColor, radius: 8)
            } else {
                RoundedRectangle(cornerRadius: shape.cornerRadius)
                    .fill(backgroundColor)
                    .frame(width: buttonSize, height: buttonSize)
                    .shadow(color: shadowColor, radius: 8)
            }
            
        case .customRoundedRectangle(let topLeft, let topRight, let bottomLeft, let bottomRight):
            let shape = CustomRoundedRectangle(
                topLeft: topLeft,
                topRight: topRight,
                bottomLeft: bottomLeft,
                bottomRight: bottomRight
            )
            if case .customView(let view) = style {
                shape
                    .fill(backgroundColor)
                    .overlay(
                        view
                            .clipShape(shape)
                            .allowsHitTesting(false)
                    )
                    .shadow(color: shadowColor, radius: 8)
            } else {
                shape
                    .fill(backgroundColor)
                    .shadow(color: shadowColor, radius: 8)
            }
            
        case .customCapsule(let leftRadius, let rightRadius):
            let shape = CustomCapsule(leftRadius: leftRadius, rightRadius: rightRadius)
            if case .customView(let view) = style {
                shape
                    .fill(backgroundColor)
                    .overlay(
                        view
                            .clipShape(shape)
                            .allowsHitTesting(false)
                    )
                    .shadow(color: shadowColor, radius: 8)
            } else {
                shape
                    .fill(backgroundColor)
                    .shadow(color: shadowColor, radius: 8)
            }
        }
    }
    
    private var buttonSize: CGFloat {
        if case .auto = size {
            let availableSize = containerSize - (size.horizontalPadding * 2)
            return min(max(availableSize, Size.small.fixedSize), Size.huge.fixedSize)
        }
        return size.fixedSize
    }
    
    private var foregroundColor: Color {
        if disabledReason != nil || (isLoading && preventDoubleClick) {
            return .gray
        }
        switch style {
        case .primary:
            return isHovering ? .white : .accentColor
        case .secondary:
            return .primary
        case .custom(let color):
            return isHovering ? .white : color
        case .customView:
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if disabledReason != nil || (isLoading && preventDoubleClick) {
            return Color.gray.opacity(0.1)
        }
        
        switch style {
        case .primary:
            return isHovering ? .accentColor : .accentColor.opacity(0.1)
        case .secondary:
            return isHovering ? 
                Color.primary.opacity(colorScheme == .dark ? 0.2 : 0.15) :
                Color.primary.opacity(0.1)
        case .custom(let color):
            return isHovering ? color : color.opacity(0.1)
        case .customView:
            return .clear
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return isHovering ? .accentColor.opacity(0.3) : .clear
        case .secondary:
            return isHovering ? Color.primary.opacity(0.2) : .clear
        case .custom(let color):
            return isHovering ? color.opacity(0.3) : .clear
        case .customView:
            return .clear
        }
    }
    
    private var shouldShowShape: Bool {
        switch shapeVisibility {
        case .always:
            return true
        case .onHover:
            return isHovering
        }
    }
    
    private var shouldShowTooltip: Bool {
        return title != nil && !title!.isEmpty && icon != nil && !shouldShowTitle
    }
    
    // MARK: - Action Handling
    
    private func handleTap() {
        // 处理弹出内容
        if popoverContent != nil {
            showingPopover.toggle()
        }
        
        // 执行动作
        if let asyncAction = asyncAction {
            Task {
                if preventDoubleClick {
                    await MainActor.run {
                        isLoading = true
                    }
                }
                await asyncAction()
                if preventDoubleClick {
                    await MainActor.run {
                        isLoading = false
                    }
                }
            }
        } else {
            if preventDoubleClick {
                isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isLoading = false
                }
            }
            action?()
        }
    }
}

// MARK: - Custom Shapes
private struct CustomRoundedRectangle: Shape {
    let topLeft: CGFloat
    let topRight: CGFloat
    let bottomLeft: CGFloat
    let bottomRight: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - topRight, y: rect.minY + topRight),
            radius: topRight,
            startAngle: Angle(degrees: -90),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        path.addArc(
            center: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY - bottomRight),
            radius: bottomRight,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 90),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY - bottomLeft),
            radius: bottomLeft,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        path.addArc(
            center: CGPoint(x: rect.minX + topLeft, y: rect.minY + topLeft),
            radius: topLeft,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        
        return path
    }
}

private struct CustomCapsule: Shape {
    let leftRadius: CGFloat
    let rightRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX + leftRadius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - rightRadius, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - rightRadius, y: rect.midY),
            radius: rightRadius,
            startAngle: Angle(degrees: -90),
            endAngle: Angle(degrees: 90),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX + leftRadius, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: rect.minX + leftRadius, y: rect.midY),
            radius: leftRadius,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        
        return path
    }
}

private struct MagicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview("MagicButton") {
    MagicButtonPreview()
        .frame(height: 800)
}
