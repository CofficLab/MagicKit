import SwiftUI

public extension URL {
    /// 创建打开按钮
    /// - Parameters:
    ///   - appType: 应用程序类型，默认为 .auto（智能选择）
    ///   - useRealIcon: 是否使用真实应用图标（仅macOS），默认为false使用系统图标
    /// - Returns: 打开按钮视图
    func makeOpenButton(_ appType: OpenAppType = .auto, useRealIcon: Bool = false) -> some View {
        #if os(macOS)
        if useRealIcon, let realIcon = appType.realIcon(for: self, useRealIcon: true) as? NSImage {
            return AnyView(
                Button(action: {
                    openIn(appType)
                }) {
                    Image(nsImage: realIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .help(appType.displayName(for: self))
                }
                .buttonStyle(.plain)
            )
        } else {
            return AnyView(
                MagicButton(
                    icon: appType.icon(for: self),
                    title: appType.displayName(for: self),
                    style: .secondary,
                    shape: .circle,
                    action: {completion in
                        openIn(appType)
                        completion()
                    }
                )
            )
        }
        #else
        return AnyView(
            MagicButton(
                icon: appType.icon(for: self),
                title: appType.displayName(for: self),
                style: .secondary,
                shape: .circle,
                action: {completion in
                    if appType == .auto {
                        open()
                    } else {
                        open() // iOS上所有类型都使用默认打开方式
                    }
                    completion()
                }
            )
        )
        #endif
    }
}

#Preview("Open Buttons") {
    OpenPreivewView()
        .inMagicContainer()
}
