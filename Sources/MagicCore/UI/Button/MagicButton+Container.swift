import SwiftUI

extension MagicButton {
    // 内部按钮内容
    @ViewBuilder
    var containerContent: some View {
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
