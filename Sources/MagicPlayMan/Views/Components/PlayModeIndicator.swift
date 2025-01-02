import SwiftUI
import MagicUI

struct PlayModeIndicator: View {
    let mode: PlaybackManager.PlayMode
    
    var body: some View {
        Label(
            title: { Text(modeName).font(.caption) },
            icon: { Image(systemName: modeIcon) }
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.primary.opacity(0.05))
        .clipShape(Capsule())
    }
    
    private var modeName: String {
        switch mode {
        case .sequence: return "Sequential"
        case .loop: return "Loop One"
        case .shuffle: return "Shuffle"
        case .repeatAll: return "Repeat All"
        }
    }
    
    private var modeIcon: String {
        switch mode {
        case .sequence: return "arrow.right"
        case .loop: return "repeat.1"
        case .shuffle: return "shuffle"
        case .repeatAll: return "repeat"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PlayModeIndicator(mode: .sequence)
        PlayModeIndicator(mode: .loop)
        PlayModeIndicator(mode: .shuffle)
        PlayModeIndicator(mode: .repeatAll)
    }
    .padding()
    .background(.ultraThinMaterial)
} 