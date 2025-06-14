import SwiftUI

public extension URL {
    /// 创建打开按钮
    /// - Parameters:
    ///   - appType: 应用程序类型，默认为 .auto（智能选择）
    ///   - useRealIcon: 是否使用真实应用图标（仅macOS），默认为false使用系统图标
    /// - Returns: 打开按钮视图
    func makeOpenButton(_ appType: OpenAppType = .auto, useRealIcon: Bool = false) -> MagicButton {
        MagicButton(
            icon: appType.magicButtonIcon(for: self, useRealIcon: useRealIcon),
            title: appType.displayName(for: self),
            style: .secondary,
            shape: .circle,
            action: {completion in
                #if os(macOS)
                    openIn(appType)
                #else
                    if appType == .auto {
                        open()
                    } else {
                        open() // iOS上所有类型都使用默认打开方式
                    }
                #endif
                completion()
            }
        )
    }
}

#Preview("Open Buttons") {
    OpenPreivewView()
        .inMagicContainer()
}
