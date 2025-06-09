import SwiftUI

/// MagicButton 的形状视图组件
/// 负责渲染不同形状的按钮背景和阴影效果
struct MagicShape: View {
    let shape: MagicButton.Shape
    let style: MagicButton.Style
    let backgroundColor: Color
    let shadowColor: Color
    let buttonSize: CGFloat
    
    /// 初始化 MagicButtonShape
    /// - Parameters:
    ///   - shape: 按钮形状
    ///   - style: 按钮样式
    ///   - backgroundColor: 背景颜色
    ///   - shadowColor: 阴影颜色
    ///   - buttonSize: 按钮尺寸（用于正方形按钮）
    init(
        shape: MagicButton.Shape,
        style: MagicButton.Style,
        backgroundColor: Color,
        shadowColor: Color,
        buttonSize: CGFloat
    ) {
        self.shape = shape
        self.style = style
        self.backgroundColor = backgroundColor
        self.shadowColor = shadowColor
        self.buttonSize = buttonSize
    }
    
    var body: some View {
        switch shape {
        case .circle:
            circleShape
            
        case .capsule:
            capsuleShape
            
        case .rectangle:
            rectangleShape
            
        case .roundedRectangle:
            roundedRectangleShape
            
        case .roundedSquare:
            roundedSquareShape
            
        case let .customRoundedRectangle(topLeft, topRight, bottomLeft, bottomRight):
            customRoundedRectangleShape(
                topLeft: topLeft,
                topRight: topRight,
                bottomLeft: bottomLeft,
                bottomRight: bottomRight
            )
            
        case let .customCapsule(leftRadius, rightRadius):
            customCapsuleShape(leftRadius: leftRadius, rightRadius: rightRadius)
        }
    }
    
    // MARK: - Shape Views
    
    /// 圆形按钮形状
    @ViewBuilder
    private var circleShape: some View {
        if case let .customView(view) = style {
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
    }
    
    /// 胶囊形按钮形状
    @ViewBuilder
    private var capsuleShape: some View {
        if case let .customView(view) = style {
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
    }
    
    /// 矩形按钮形状
    @ViewBuilder
    private var rectangleShape: some View {
        if case let .customView(view) = style {
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
    }
    
    /// 圆角矩形按钮形状
    @ViewBuilder
    private var roundedRectangleShape: some View {
        if case let .customView(view) = style {
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
    }
    
    /// 圆角正方形按钮形状
    @ViewBuilder
    private var roundedSquareShape: some View {
        if case let .customView(view) = style {
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
    }
    
    /// 自定义圆角矩形按钮形状
    /// - Parameters:
    ///   - topLeft: 左上角圆角半径
    ///   - topRight: 右上角圆角半径
    ///   - bottomLeft: 左下角圆角半径
    ///   - bottomRight: 右下角圆角半径
    @ViewBuilder
    private func customRoundedRectangleShape(
        topLeft: CGFloat,
        topRight: CGFloat,
        bottomLeft: CGFloat,
        bottomRight: CGFloat
    ) -> some View {
        let shape = CustomRoundedRectangle(
            topLeft: topLeft,
            topRight: topRight,
            bottomLeft: bottomLeft,
            bottomRight: bottomRight
        )
        
        if case let .customView(view) = style {
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
    
    /// 自定义胶囊形按钮形状
    /// - Parameters:
    ///   - leftRadius: 左侧圆角半径
    ///   - rightRadius: 右侧圆角半径
    @ViewBuilder
    private func customCapsuleShape(leftRadius: CGFloat, rightRadius: CGFloat) -> some View {
        let shape = CustomCapsule(leftRadius: leftRadius, rightRadius: rightRadius)
        
        if case let .customView(view) = style {
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

// MARK: - Preview

#Preview("MagicButtonShape") {
    VStack(spacing: 20) {
        // 圆形
        MagicShape(
            shape: .circle,
            style: .primary,
            backgroundColor: .blue,
            shadowColor: .gray.opacity(0.3),
            buttonSize: 50
        )
        .frame(width: 50, height: 50)
        
        // 胶囊形
        MagicShape(
            shape: .capsule,
            style: .secondary,
            backgroundColor: .green,
            shadowColor: .gray.opacity(0.3),
            buttonSize: 50
        )
        .frame(width: 100, height: 40)
        
        // 圆角矩形
        MagicShape(
            shape: .roundedRectangle,
            style: .secondary,
            backgroundColor: .orange,
            shadowColor: .gray.opacity(0.3),
            buttonSize: 50
        )
        .frame(width: 120, height: 40)
    }
    .padding()
    .inMagicContainer()
}
