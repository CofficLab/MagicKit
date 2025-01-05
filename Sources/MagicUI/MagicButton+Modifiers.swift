import SwiftUI

// MARK: - MagicButton Modifiers
public extension MagicButton {
    /// 设置按钮图标
    func magicIcon(_ name: String) -> MagicButton {
        MagicButton(
            icon: name,
            title: self.title,
            style: self.style,
            size: self.size,
            shape: self.shape,
            disabledReason: self.disabledReason,
            popoverContent: self.popoverContent,
            action: self.action
        )
    }
    
    /// 设置按钮标题
    func magicTitle(_ text: String?) -> MagicButton {
        MagicButton(
            icon: self.icon,
            title: text,
            style: self.style,
            size: self.size,
            shape: self.shape,
            disabledReason: self.disabledReason,
            popoverContent: self.popoverContent,
            action: self.action
        )
    }
    
    /// 设置按钮样式
    func magicStyle(_ style: Style) -> MagicButton {
        MagicButton(
            icon: self.icon,
            title: self.title,
            style: style,
            size: self.size,
            shape: self.shape,
            disabledReason: self.disabledReason,
            popoverContent: self.popoverContent,
            action: self.action
        )
    }
    
    /// 设置按钮大小
    func magicSize(_ size: Size) -> MagicButton {
        MagicButton(
            icon: self.icon,
            title: self.title,
            style: self.style,
            size: size,
            shape: self.shape,
            disabledReason: self.disabledReason,
            popoverContent: self.popoverContent,
            action: self.action
        )
    }
    
    /// 设置按钮形状
    func magicShape(_ shape: Shape) -> MagicButton {
        MagicButton(
            icon: self.icon,
            title: self.title,
            style: self.style,
            size: self.size,
            shape: shape,
            disabledReason: self.disabledReason,
            popoverContent: self.popoverContent,
            action: self.action
        )
    }
    
    /// 设置按钮禁用状态
    func magicDisabled(_ reason: String?) -> MagicButton {
        MagicButton(
            icon: self.icon,
            title: self.title,
            style: self.style,
            size: self.size,
            shape: self.shape,
            disabledReason: reason,
            popoverContent: self.popoverContent,
            action: self.action
        )
    }
    
    /// 设置按钮弹出内容
    func magicPopover<Content: View>(@ViewBuilder content: @escaping () -> Content) -> MagicButton {
        MagicButton(
            icon: self.icon,
            title: self.title,
            style: self.style,
            size: self.size,
            shape: self.shape,
            disabledReason: self.disabledReason,
            popoverContent: AnyView(content()),
            action: self.action
        )
    }
} 