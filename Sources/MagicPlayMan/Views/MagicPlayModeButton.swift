import SwiftUI

struct MagicPlayModeButton: View {
    let mode: PlaybackManager.PlayMode
    let action: () -> Void
    
    @State private var isHovering = false
    @Environment(\.colorScheme) private var colorScheme
    
    init(mode: PlaybackManager.PlayMode, action: @escaping () -> Void) {
        self.mode = mode
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: 16))
                .foregroundStyle(isHovering ? .primary : .secondary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.primary.opacity(isHovering ? 0.1 : 0.05))
                )
                .overlay(
                    Circle()
                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .help(modeDescription)
    }
    
    private var iconName: String {
        switch mode {
        case .sequence:
            return "arrow.right"
        case .loop:
            return "repeat.1"
        case .shuffle:
            return "shuffle"
        case .repeatAll:
            return "repeat"
        }
    }
    
    private var modeDescription: String {
        switch mode {
        case .sequence:
            return "Sequential Play"
        case .loop:
            return "Single Track Loop"
        case .shuffle:
            return "Shuffle Play"
        case .repeatAll:
            return "Repeat All"
        }
    }
}

#Preview("MagicPlayModeButton") {
    struct PreviewWrapper: View {
        @State private var mode: PlaybackManager.PlayMode = .sequence
        
        var body: some View {
            HStack(spacing: 20) {
                VStack(spacing: 20) {
                    Text("Light Mode")
                        .font(.headline)
                    
                    ForEach([
                        PlaybackManager.PlayMode.sequence,
                        .loop,
                        .shuffle,
                        .repeatAll
                    ], id: \.self) { mode in
                        MagicPlayModeButton(mode: mode) {
                            print("Toggle mode: \(mode)")
                        }
                    }
                }
                .padding()
                .background(.background)
                .environment(\.colorScheme, .light)
                
                VStack(spacing: 20) {
                    Text("Dark Mode")
                        .font(.headline)
                    
                    ForEach([
                        PlaybackManager.PlayMode.sequence,
                        .loop,
                        .shuffle,
                        .repeatAll
                    ], id: \.self) { mode in
                        MagicPlayModeButton(mode: mode) {
                            print("Toggle mode: \(mode)")
                        }
                    }
                }
                .padding()
                .background(.background)
                .environment(\.colorScheme, .dark)
            }
        }
    }
    
    return PreviewWrapper()
} 