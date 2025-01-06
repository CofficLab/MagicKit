import SwiftUI

// MARK: - MagicButton Modifiers
public extension MagicButton {
    /// 设置按钮图标
    /// - Parameter name: SF Symbols 图标名称
    /// - Returns: 更新后的按钮
    func magicIcon(_ name: String) -> MagicButton {
        MagicButton(
            icon: name,
            title: self.title,
            style: self.style,
            size: self.size,
            shape: self.shape,
            shapeVisibility: self.shapeVisibility,
            disabledReason: self.disabledReason,
            popoverContent: self.popoverContent,
            action: self.action
        )
    }
    
    /// 设置按钮标题
    /// - Parameter text: 标题文本，传入 nil 可以移除标题
    /// - Returns: 更新后的按钮
    func magicTitle(_ text: String?) -> MagicButton {
        MagicButton(
            icon: self.icon,
            title: text,
            style: self.style,
            size: self.size,
            shape: self.shape,
            shapeVisibility: self.shapeVisibility,
            disabledReason: self.disabledReason,
            popoverContent: self.popoverContent,
            action: self.action
        )
    }
    
    /// 设置按钮样式
    /// - Parameter style: 按钮样式（.primary 或 .secondary）
    /// - Returns: 更新后的按钮
    func magicStyle(_ style: Style) -> MagicButton {
        MagicButton(
            icon: self.icon,
            title: self.title,
            style: style,
            size: self.size,
            shape: self.shape,
            shapeVisibility: self.shapeVisibility,
            disabledReason: self.disabledReason,
            popoverContent: self.popoverContent,
            action: self.action
        )
    }
    
    /// 设置按钮大小
    /// - Parameter size: 按钮大小（.auto、.small、.regular 或 .large）
    /// - Returns: 更新后的按钮
    ///
    /// 示例：
    /// ```swift
    /// // 使用固定尺寸
    /// button.magicSize(.regular)
    ///
    /// // 使用自动尺寸（根据容器大小自动调整）
    /// button.magicSize(.auto)
    /// ```
    func magicSize(_ size: Size) -> MagicButton {
        MagicButton(
            icon: self.icon,
            title: self.title,
            style: self.style,
            size: size,
            shape: self.shape,
            shapeVisibility: self.shapeVisibility,
            disabledReason: self.disabledReason,
            popoverContent: self.popoverContent,
            action: self.action
        )
    }
    
    /// 设置按钮形状
    /// - Parameter shape: 按钮形状，支持多种预设和自定义形状
    /// - Returns: 更新后的按钮
    ///
    /// 示例：
    /// ```swift
    /// // 使用预设形状
    /// button.magicShape(.roundedRectangle)
    ///
    /// // 使用自定义圆角矩形
    /// button.magicShape(.customRoundedRectangle(
    ///     topLeft: 8,
    ///     topRight: 16,
    ///     bottomLeft: 16,
    ///     bottomRight: 8
    /// ))
    ///
    /// // 使用自定义胶囊形
    /// button.magicShape(.customCapsule(
    ///     leftRadius: 12,
    ///     rightRadius: 24
    /// ))
    /// ```
    func magicShape(_ shape: Shape) -> MagicButton {
        MagicButton(
            icon: self.icon,
            title: self.title,
            style: self.style,
            size: self.size,
            shape: shape,
            shapeVisibility: self.shapeVisibility,
            disabledReason: self.disabledReason,
            popoverContent: self.popoverContent,
            action: self.action
        )
    }
    
    /// 设置按钮禁用状态
    /// - Parameter reason: 禁用原因，显示在提示中。传入 nil 可以启用按钮
    /// - Returns: 更新后的按钮
    func magicDisabled(_ reason: String?) -> MagicButton {
        MagicButton(
            icon: self.icon,
            title: self.title,
            style: self.style,
            size: self.size,
            shape: self.shape,
            shapeVisibility: self.shapeVisibility,
            disabledReason: reason,
            popoverContent: self.popoverContent,
            action: self.action
        )
    }
    
    /// 设置按钮的弹出内容
    /// - Parameter content: 弹出内容的视图构建器
    /// - Returns: 更新后的按钮
    ///
    /// 示例：
    /// ```swift
    /// button.magicPopover {
    ///     VStack {
    ///         Text("标题")
    ///         Text("详细信息")
    ///     }
    ///     .padding()
    /// }
    /// ```
    func magicPopover<Content: View>(@ViewBuilder content: @escaping () -> Content) -> MagicButton {
        MagicButton(
            icon: self.icon,
            title: self.title,
            style: self.style,
            size: self.size,
            shape: self.shape,
            shapeVisibility: self.shapeVisibility,
            disabledReason: self.disabledReason,
            popoverContent: AnyView(content()),
            action: self.action
        )
    }
    
    /// 设置按钮形状的显示时机
    /// - Parameter visibility: 形状显示时机（.always 或 .onHover）
    /// - Returns: 更新后的按钮
    ///
    /// 示例：
    /// ```swift
    /// // 始终显示形状（默认行为）
    /// button.magicShapeVisibility(.always)
    ///
    /// // 仅在悬停时显示形状
    /// button.magicShapeVisibility(.onHover)
    /// ```
    func magicShapeVisibility(_ visibility: ShapeVisibility) -> MagicButton {
        MagicButton(
            icon: self.icon,
            title: self.title,
            style: self.style,
            size: self.size,
            shape: self.shape,
            shapeVisibility: visibility,
            disabledReason: self.disabledReason,
            popoverContent: self.popoverContent,
            action: self.action
        )
    }
    
    /// 设置按钮的背景色
    /// - Parameter color: 自定义背景色
    /// - Returns: 修改后的按钮
    ///
    /// 示例：
    /// ```swift
    /// // 使用预定义颜色
    /// button.magicBackgroundColor(.blue)
    ///
    /// // 使用自定义颜色
    /// button.magicBackgroundColor(Color(hex: "#FF5733"))
    /// ```
    func magicBackgroundColor(_ color: Color) -> MagicButton {
        MagicButton(
            icon: self.icon,
            title: self.title,
            style: .custom(color),
            size: self.size,
            shape: self.shape,
            shapeVisibility: self.shapeVisibility,
            disabledReason: self.disabledReason,
            popoverContent: self.popoverContent,
            action: self.action
        )
    }
}
