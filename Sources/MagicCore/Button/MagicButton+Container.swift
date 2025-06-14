import SwiftUI

extension MagicButton {
    // 内部按钮内容
    @ViewBuilder
    var containerContent: some View {
        if isLoading && loadingStyle != .none {
            MagicLoadingView(
                style: loadingStyle,
                isLoading: true,
                foregroundColor: foregroundColor
            )
            .contentShape(Rectangle())
        } else {
            GeometryReader { geometry in
                let minSize = min(geometry.size.width, geometry.size.height)

                HStack(spacing: 4) {
                    if let icon = icon {
                        iconView(icon: icon, size: size.iconSize(containerSize: minSize))
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
    
    /// 根据图标类型创建对应的视图
    @ViewBuilder
    private func iconView(icon: MagicButtonIcon, size: CGFloat) -> some View {
        switch icon {
        case .systemName(let name):
            Image(systemName: name)
                .font(.system(size: size))
        #if os(macOS)
        case .customImage(let nsImage):
            // 自定义图标需要稍微放大以匹配 SF Symbols 的视觉大小
            // SF Symbols 的字体大小通常比实际显示大小要小，所以我们需要补偿这个差异
            let adjustedSize = size * 1.4 // 调整倍数以匹配 SF Symbols 的视觉效果
            Image(nsImage: nsImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: adjustedSize, height: adjustedSize)
        #endif
        }
    }
}

struct MagicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    BasicButtonsPreview()
        .inMagicContainer()
}
