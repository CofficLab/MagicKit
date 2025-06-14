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
            case let .custom(size):
                return size
            }
        }

        /// 获取图标大小
        func iconSize(containerSize: CGFloat) -> CGFloat {
            switch self {
            case .mini:
                return 10
            case .auto:
                return 20 // 自动模式下使用默认大小
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
            case let .custom(size):
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
            case .customRoundedRectangle:
                return 0 // 由自定义值决定
            case .customCapsule:
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
    public typealias LoadingStyle = MagicLoadingView.Style

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
    /// 点击动作（可以是简单动作或带完成回调的动作）
    let action: ((@escaping () -> Void) -> Void)?
    /// 自定义背景色
    let customBackgroundColor: Color?
    /// 是否启用防重复点击
    let preventDoubleClick: Bool
    /// 加载动画样式
    let loadingStyle: LoadingStyle

    @State internal var isHovering = false
    @State internal var containerSize: CGFloat = 0
    @State internal var showingDisabledPopover = false
    @State internal var showingPopover = false
    @State internal var shouldShowTitle = false
    @State internal var isLoading = false
    @Environment(\.colorScheme) var colorScheme

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
    ///   - customBackgroundColor: 自定义背景色
    ///   - preventDoubleClick: 是否启用防重复点击
    ///   - loadingStyle: 加载动画样式
    ///   - action: 点击动作，接收一个完成回调参数。调用完成回调来结束loading状态
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
        action: ((@escaping () -> Void) -> Void)? = nil
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
    }
    
    /// 创建一个简单的 MagicButton（向后兼容）
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
    ///   - action: 简单点击动作，不需要完成回调
    public static func simple(
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
        action: @escaping () -> Void
    ) -> MagicButton {
        return MagicButton(
            icon: icon,
            title: title,
            style: style,
            size: size,
            shape: shape,
            shapeVisibility: shapeVisibility,
            disabledReason: disabledReason,
            popoverContent: popoverContent,
            customBackgroundColor: customBackgroundColor,
            preventDoubleClick: preventDoubleClick,
            loadingStyle: loadingStyle
        ) { completion in
            action()
            completion()
        }
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
            .background(shouldShowShape ? Rectangle()
                .fill(Color.clear)
                .magicShape(
                    shape,
                    style: style,
                    backgroundColor: backgroundColor,
                    shadowColor: shadowColor,
                    buttonSize: buttonSize
                ) : nil)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovering = hovering
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

    private var isCircularShape: Bool {
        if case .circle = shape {
            return title == nil
        }
        return false
    }

    private var buttonSize: CGFloat {
        if case .auto = size {
            let availableSize = containerSize - (size.horizontalPadding * 2)
            return min(max(availableSize, Size.small.fixedSize), Size.huge.fixedSize)
        }
        return size.fixedSize
    }

    private var shouldShowShape: Bool {
        switch shapeVisibility {
        case .always:
            return true
        case .onHover:
            return isHovering
        }
    }
}

#Preview {
    BasicButtonsPreview()
        .inMagicContainer()
}
