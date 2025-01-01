import SwiftUI

public struct MagicPlayerButton: View {
    let icon: String
    let action: () -> Void
    var size: CGFloat
    var iconSize: CGFloat
    var isActive: Bool
    
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
        MagicButton(
            icon: icon,
            style: isActive ? .primary : .secondary,
            size: buttonSize,
            shape: .circle,
            action: action
        )
    }
    
    private var buttonSize: MagicButton.Size {
        if size <= 32 {
            return .small
        } else if size >= 50 {
            return .large
        }
        return .regular
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
