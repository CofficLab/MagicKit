import SwiftUI
import AVKit

// MARK: - Video Player View
struct VideoPlayerView: View {
    let player: AVPlayer
    
    var body: some View {
        VideoPlayer(player: player)
            .aspectRatio(16/9, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.secondary.opacity(0.1))
            )
    }
}

// MARK: - Preview
#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
}

