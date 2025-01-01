import SwiftUI

public struct MagicButton: View {
    public enum Style {
        case primary
        case secondary
    }
    
    public enum Size {
        case small
        case regular
        case large
    }
    
    public enum Shape {
        case circle
        case capsule
    }
    
    let icon: String
    let title: String?
    let style: Style
    let size: Size
    let shape: Shape
    let action: () -> Void
    @State private var isHovering = false
    @Environment(\.colorScheme) private var colorScheme
    
    public init(
        icon: String,
        title: String? = nil,
        style: Style = .primary,
        size: Size = .regular,
        shape: Shape = .circle,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.style = style
        self.size = size
        self.shape = shape
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: iconSize))
                if let title = title {
                    Text(title)
                        .font(font)
                }
            }
            .foregroundStyle(foregroundColor)
            .frame(width: shape == .circle && title == nil ? buttonSize : nil, 
                   height: shape == .circle && title == nil ? buttonSize : nil)
            .padding(.horizontal, shape == .circle && title == nil ? 0 : horizontalPadding)
            .padding(.vertical, shape == .circle && title == nil ? 0 : verticalPadding)
            .background(buttonShape)
            .scaleEffect(isHovering ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
        }
        .buttonStyle(MagicButtonStyle())
        .onHover { hovering in
            isHovering = hovering
        }
    }
    
    @ViewBuilder
    private var buttonShape: some View {
        switch shape {
        case .circle:
            Circle()
                .fill(backgroundColor)
                .shadow(
                    color: shadowColor,
                    radius: 8
                )
        case .capsule:
            Capsule()
                .fill(backgroundColor)
                .shadow(
                    color: shadowColor,
                    radius: 8
                )
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
        switch style {
        case .primary:
            return isHovering ? .white : .accentColor
        case .secondary:
            return .primary
        }
    }
    
    private var backgroundColor: Color {
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

private struct MagicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview("MagicButton") {
    struct PreviewWrapper: View {
        var body: some View {
            HStack {
                VStack(spacing: 20) {
                    Text("Light Mode")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        MagicButton(
                            icon: "play.fill",
                            title: "Play",
                            style: .primary,
                            size: .regular,
                            shape: .circle,
                            action: {}
                        )
                        
                        MagicButton(
                            icon: "trash",
                            title: "Clear",
                            style: .secondary,
                            size: .small,
                            shape: .circle,
                            action: {}
                        )
                    }
                }
                .padding()
                .background(.background)
                .environment(\.colorScheme, .light)
                
                VStack(spacing: 20) {
                    Text("Dark Mode")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        MagicButton(
                            icon: "play.fill",
                            title: "Play",
                            style: .primary,
                            size: .regular,
                            shape: .circle,
                            action: {}
                        )
                        
                        MagicButton(
                            icon: "trash",
                            title: "Clear",
                            style: .secondary,
                            size: .small,
                            shape: .circle,
                            action: {}
                        )
                    }
                }
                .padding()
                .background(.background)
                .environment(\.colorScheme, .dark)
            }
            .previewLayout(.sizeThatFits)
        }
    }
    
    return PreviewWrapper()
}
