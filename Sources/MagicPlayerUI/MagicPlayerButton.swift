import SwiftUI

public struct MagicPlayerButton: View {
    let icon: String
    let action: () -> Void
    var size: CGFloat = 40
    var iconSize: CGFloat = 15
    var isActive: Bool = false
    @State private var isHovering = false
    @Environment(\.colorScheme) private var colorScheme
    
    public init(
        icon: String,
        size: CGFloat = 40,
        iconSize: CGFloat = 15,
        isActive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.iconSize = iconSize
        self.isActive = isActive
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: iconSize))
                .foregroundColor(isActive ? .white : .primary)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(
                            isActive 
                                ? Color.accentColor 
                                : (isHovering 
                                    ? Color.primary.opacity(colorScheme == .dark ? 0.2 : 0.15)
                                    : Color.primary.opacity(0.1))
                        )
                        .shadow(
                            color: isActive 
                                ? Color.accentColor.opacity(0.3) 
                                : (isHovering ? Color.primary.opacity(0.2) : .clear),
                            radius: 8
                        )
                )
                .scaleEffect(isHovering ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
        }
        .buttonStyle(MagicButtonStyle())
        .onHover { hovering in
            isHovering = hovering
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

#Preview("MagicPlayerButton") {
    struct PreviewWrapper: View {
        var body: some View {
            HStack {
                VStack(spacing: 20) {
                    Text("Light Mode")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        MagicPlayerButton(
                            icon: "backward.fill",
                            action: {}
                        )
                        
                        MagicPlayerButton(
                            icon: "play.fill",
                            size: 50,
                            iconSize: 20,
                            isActive: true,
                            action: {}
                        )
                        
                        MagicPlayerButton(
                            icon: "forward.fill",
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
                    
                    HStack(spacing: 20) {
                        MagicPlayerButton(
                            icon: "backward.fill",
                            action: {}
                        )
                        
                        MagicPlayerButton(
                            icon: "play.fill",
                            size: 50,
                            iconSize: 20,
                            isActive: true,
                            action: {}
                        )
                        
                        MagicPlayerButton(
                            icon: "forward.fill",
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