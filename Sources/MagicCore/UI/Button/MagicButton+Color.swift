import SwiftUI

extension MagicButton {
    var foregroundColor: Color {
        if disabledReason != nil || (isLoading && preventDoubleClick) {
            return .gray
        }
        switch style {
        case .primary:
            return isHovering ? .white : .accentColor
        case .secondary:
            return .primary
        case let .custom(color):
            return isHovering ? .white : color
        case .customView:
            return .primary
        }
    }

    var backgroundColor: Color {
        if disabledReason != nil || (isLoading && preventDoubleClick) {
            return Color.gray.opacity(0.1)
        }

        switch style {
        case .primary:
            return isHovering ? .accentColor : .accentColor.opacity(0.1)
        case .secondary:
            return isHovering ?
                Color.primary.opacity(colorScheme == .dark ? 0.2 : 0.15) :
                Color.primary.opacity(0.1)
        case let .custom(color):
            return isHovering ? color : color.opacity(0.1)
        case .customView:
            return .clear
        }
    }

    var shadowColor: Color {
        switch style {
        case .primary:
            return isHovering ? .accentColor.opacity(0.3) : .clear
        case .secondary:
            return isHovering ? Color.primary.opacity(0.2) : .clear
        case let .custom(color):
            return isHovering ? color.opacity(0.3) : .clear
        case .customView:
            return .clear
        }
    }
}

#Preview {
    BasicButtonsPreview()
        .inMagicContainer()
}

