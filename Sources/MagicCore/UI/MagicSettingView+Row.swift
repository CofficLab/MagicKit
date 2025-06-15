import SwiftUI

/// A basic setting row that displays a title and optional description
public struct MagicSettingRow<Content: View>: View {
    let title: String
    let description: String?
    let icon: String?
    let content: Content
    let action: (() -> Void)?
    
    @State private var isHovered = false
    @State private var isPressed = false
    
    public init(
        title: String,
        description: String? = nil,
        icon: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.action = action
        self.content = content()
    }
    
    public var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(alignment: .center, spacing: 16) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, height: 24)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                    
                    if let description = description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                content
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background {
            RoundedRectangle(cornerRadius: 6)
                .fill(isPressed ? Color.primary.opacity(0.1) :
                      isHovered ? Color.primary.opacity(0.05) : Color.clear)
                .animation(.easeOut(duration: 0.15), value: isHovered)
                .animation(.easeOut(duration: 0.1), value: isPressed)
        }
        .onHover { hovering in
            isHovered = hovering
        }
        .pressAction { isPressed in
            self.isPressed = isPressed
        }
    }
}

// MARK: - Press Action Modifier
extension View {
    fileprivate func pressAction(onPress: @escaping (Bool) -> Void) -> some View {
        modifier(PressActionModifier(onPress: onPress))
    }
}

fileprivate struct PressActionModifier: ViewModifier {
    let onPress: (Bool) -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress(true) }
                    .onEnded { _ in onPress(false) }
            )
    }
}

// MARK: - Preview
#Preview {
    MagicContainer {
        VStack(spacing: 0) {
            // Basic row with text content
            MagicSettingRow(
                title: "Basic Setting",
                description: "A simple setting row with text content",
                icon: .iconGear
            ) {
                Text("Value")
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Row with button
            MagicSettingRow(
                title: "Action Setting",
                icon: .iconArrowUpCircle
            ) {
                Button("Open") {
                    // Action
                }
            }
            
            Divider()
            
            // Row with image
            MagicSettingRow(
                title: "Image Setting",
                description: "Setting with system image",
                icon: .iconStar
            ) {
                Image(systemName: .iconStarFill)
                    .foregroundColor(.yellow)
            }
            
            Divider()
            
            // Row with custom control
            MagicSettingRow(
                title: "Custom Control",
                description: "Setting with custom control",
                icon: .iconDotCircle
            ) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(.blue)
                        .frame(width: 12, height: 12)
                    Text("Active")
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Row with multiple actions
            MagicSettingRow(
                title: "Multiple Controls",
                icon: .iconPersonCircle
            ) {
                HStack(spacing: 12) {
                    Button("Edit") {
                        // Action
                    }
                    Button("Delete") {
                        // Action
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}
