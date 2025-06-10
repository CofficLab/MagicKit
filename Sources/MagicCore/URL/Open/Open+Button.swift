import SwiftUI

public extension URL {
    /// 创建打开按钮
    /// - Parameters:
    ///   - size: 按钮大小，默认为 28x28
    ///   - showLabel: 是否显示文字标签，默认为 false
    /// - Returns: 打开按钮视图
    func makeOpenButton() -> MagicButton {
        MagicButton(
            icon: isNetworkURL ? .iconSafari : .iconShowInFinder,
            title: isNetworkURL ? "在浏览器中打开" : "在访达中显示",
            style: .secondary,
            shape: .circle,
            action: {
                open()
            }
        )
    }
    
    /// 创建在指定应用程序中打开的按钮
    /// - Parameter appType: 应用程序类型
    /// - Returns: 打开按钮视图
    func makeOpenInButton(_ appType: OpenAppType) -> MagicButton {
        MagicButton(
            icon: appType.icon,
            title: appType.displayName,
            style: .secondary,
            shape: .circle,
            action: {
                #if os(macOS)
                    openIn(appType)
                #else
                    open()
                #endif
            }
        )
    }
}

#Preview("Open Buttons") {
    OpenPreivewView()
        .inMagicContainer()
}
