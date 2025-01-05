import SwiftUI

public struct MagicToast: View {
    let message: String
    let icon: String
    let style: Style
    @State private var isHovering = false
    @State private var isPresented = false
    
    public enum Style {
        case info
        case warning
        case error
        
        var color: Color {
            switch self {
            case .info:
                return .blue
            case .warning:
                return .orange
            case .error:
                return .red
            }
        }
        
        var animation: Animation {
            switch self {
            case .info:
                return .spring(response: 0.3, dampingFraction: 0.6)
            case .warning:
                return .spring(response: 0.35, dampingFraction: 0.5)
            case .error:
                return .spring(response: 0.4, dampingFraction: 0.4)
            }
        }
        
        var iconAnimation: Animation {
            switch self {
            case .info:
                return .smooth
            case .warning:
                return .bouncy
            case .error:
                return .snappy
            }
        }
    }
    
    public init(message: String, icon: String, style: Style = .info) {
        self.message = message
        self.icon = icon
        self.style = style
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: isHovering ? 16 : 14))
                .foregroundStyle(style.color)
                .symbolEffect(.bounce, options: .repeat(2), value: isPresented)
            
            Text(message)
                .font(.callout)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(
                    color: style.color.opacity(0.2),
                    radius: isHovering ? 8 : 5,
                    y: isHovering ? 3 : 2
                )
        }
        .scaleEffect(isHovering ? 1.02 : 1.0)
        .animation(style.animation, value: isHovering)
        .onHover { hovering in
            isHovering = hovering
        }
        .onAppear {
            withAnimation(style.iconAnimation.delay(0.2)) {
                isPresented = true
            }
        }
        .transition(
            .asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .move(edge: .bottom).combined(with: .opacity)
            )
        )
    }
}

// MARK: - Preview
#Preview("MagicToast") {
    MagicToastPreview()
}
