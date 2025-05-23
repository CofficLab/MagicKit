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
        
        var gradientColors: [Color] {
            switch self {
            case .info:
                return [Color.blue.opacity(0.8), Color.blue.opacity(0.7)]
            case .warning:
                return [Color.orange.opacity(0.8), Color.orange.opacity(0.7)]
            case .error:
                return [Color.red.opacity(0.8), Color.red.opacity(0.7)]
            }
        }
        
        var font: Font {
            return .largeTitle
        }
        
        var cornerRadius: CGFloat {
            return 12
        }
        
        var iconColor: Color {
            return .white
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
    }
    
    public init(message: String, icon: String, style: Style = .info) {
        self.message = message
        self.icon = icon
        self.style = style
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .foregroundColor(style.iconColor)
                .padding(.top, 16)
            
            Text(message)
                .font(style.font)
                .foregroundColor(.white)
                .padding(.vertical, 10)
        }
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .fill(LinearGradient(gradient: Gradient(colors: style.gradientColors), startPoint: .leading, endPoint: .trailing))
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .scaleEffect(isHovering ? 1.05 : 1.0)
        .animation(style.animation, value: isHovering)
        .onHover { hovering in
            isHovering = hovering
        }
        .onAppear {
            withAnimation(style.animation.delay(0.2)) {
                isPresented = true
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Preview
#Preview("MagicToast") {
    MagicToastPreview()
}
