import SwiftUI

public struct MagicToast: View {
    let message: String
    let icon: String
    let style: Style
    
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
    }
    
    public init(message: String, icon: String, style: Style = .info) {
        self.message = message
        self.icon = icon
        self.style = style
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(style.color)
            
            Text(message)
                .font(.callout)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

#Preview {
    MagicToast(message: "Cheers", icon: "checkmark.circle")
        .padding(.horizontal, 20)
        .frame(width: 500, height: 500)
        .background(Color.white)
}
