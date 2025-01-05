import SwiftUI

/// 一个功能丰富的按钮组件，支持多种样式、大小和形状
///
/// MagicButton 提供了丰富的自定义选项：
/// - 支持图标和文本组合
/// - 提供主要和次要两种样式
/// - 支持三种尺寸：小、中、大
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
    }
    
    /// 按钮大小
    public enum Size {
        /// 小尺寸，适用于紧凑布局
        case small
        /// 常规尺寸，默认选项
        case regular
        /// 大尺寸，适用于强调显示
        case large
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
            case .customRoundedRectangle(_, _, _, _):
                return 0 // 由自定义值决定
            case .customCapsule(_, _):
                return 0 // 由自定义值决定
            }
        }
    }
    
    // MARK: - Properties
    
    /// SF Symbols 图标名称
    let icon: String
    /// 按钮标题（可选）
    let title: String?
    /// 按钮样式
    let style: Style
    /// 按钮大小
    let size: Size
    /// 按钮形状
    let shape: Shape
    /// 禁用状态的提示文本
    let disabledReason: String?
    /// 弹出内容
    let popoverContent: AnyView?
    /// 点击动作
    let action: () -> Void
    
    @State private var isHovering = false
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingDisabledPopover = false
    
    // MARK: - Initialization
    
    /// 创建一个 MagicButton
    /// - Parameters:
    ///   - icon: SF Symbols 图标名称
    ///   - title: 按钮标题（可选）
    ///   - style: 按钮样式（默认为 .primary）
    ///   - size: 按钮大小（默认为 .regular）
    ///   - shape: 按钮形状（默认为 .circle）
    ///   - disabledReason: 禁用状态的提示文本（如果为 nil 则按钮可用）
    ///   - popoverContent: 弹出内容（可选）
    ///   - action: 点击动作
    public init(
        icon: String,
        title: String? = nil,
        style: Style = .primary,
        size: Size = .regular,
        shape: Shape = .roundedRectangle,
        disabledReason: String? = nil,
        popoverContent: AnyView? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.style = style
        self.size = size
        self.shape = shape
        self.disabledReason = disabledReason
        self.popoverContent = popoverContent
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            if disabledReason != nil {
                showingDisabledPopover = true
            } else if popoverContent != nil {
                showingDisabledPopover.toggle()
            } else {
                action()
            }
        }) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: iconSize))
                if let title = title {
                    Text(title)
                        .font(font)
                }
            }
            .foregroundStyle(foregroundColor)
            .frame(width: isCircularShape ? buttonSize : nil, 
                   height: isCircularShape ? buttonSize : nil)
            .padding(.horizontal, isCircularShape ? 0 : horizontalPadding)
            .padding(.vertical, isCircularShape ? 0 : verticalPadding)
            .background(buttonShape)
            .scaleEffect(isHovering ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
            .opacity(disabledReason != nil ? 0.5 : 1.0)
        }
        .buttonStyle(MagicButtonStyle())
        .onHover { hovering in
            isHovering = hovering && disabledReason == nil
        }
        .popover(isPresented: $showingDisabledPopover, arrowEdge: .top) {
            if let reason = disabledReason {
                Text(reason)
                    .font(.callout)
                    .padding()
            } else if let content = popoverContent {
                content
            }
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
            Circle()
                .fill(backgroundColor)
                .shadow(color: shadowColor, radius: 8)
            
        case .capsule:
            Capsule()
                .fill(backgroundColor)
                .shadow(color: shadowColor, radius: 8)
            
        case .rectangle:
            Rectangle()
                .fill(backgroundColor)
                .shadow(color: shadowColor, radius: 8)
            
        case .roundedRectangle:
            RoundedRectangle(cornerRadius: shape.cornerRadius)
                .fill(backgroundColor)
                .shadow(color: shadowColor, radius: 8)
            
        case .customRoundedRectangle(let topLeft, let topRight, let bottomLeft, let bottomRight):
            CustomRoundedRectangle(
                topLeft: topLeft,
                topRight: topRight,
                bottomLeft: bottomLeft,
                bottomRight: bottomRight
            )
            .fill(backgroundColor)
            .shadow(color: shadowColor, radius: 8)
            
        case .customCapsule(let leftRadius, let rightRadius):
            CustomCapsule(leftRadius: leftRadius, rightRadius: rightRadius)
                .fill(backgroundColor)
                .shadow(color: shadowColor, radius: 8)
        }
    }
    
    private var buttonSize: CGFloat {
        switch size {
        case .small:
            return 32
        case .regular:
            return 40
        case .large:
            return 50
        }
    }
    
    private var iconSize: CGFloat {
        switch size {
        case .small:
            return 12
        case .regular:
            return 15
        case .large:
            return 20
        }
    }
    
    private var font: Font {
        switch size {
        case .small:
            return .caption
        case .regular:
            return .body
        case .large:
            return .title3
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .small:
            return 8
        case .regular:
            return 12
        case .large:
            return 16
        }
    }
    
    private var verticalPadding: CGFloat {
        switch size {
        case .small:
            return 4
        case .regular:
            return 8
        case .large:
            return 12
        }
    }
    
    private var foregroundColor: Color {
        if disabledReason != nil {
            return .gray
        }
        switch style {
        case .primary:
            return isHovering ? .white : .accentColor
        case .secondary:
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if disabledReason != nil {
            return Color.gray.opacity(0.1)
        }
        switch style {
        case .primary:
            return isHovering ? .accentColor : .accentColor.opacity(0.1)
        case .secondary:
            return isHovering ? 
                Color.primary.opacity(colorScheme == .dark ? 0.2 : 0.15) :
                Color.primary.opacity(0.1)
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return isHovering ? .accentColor.opacity(0.3) : .clear
        case .secondary:
            return isHovering ? Color.primary.opacity(0.2) : .clear
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
}
