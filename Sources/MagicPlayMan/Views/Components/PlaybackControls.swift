import SwiftUI
import MagicUI

struct PlaybackControls: View {
    let isPlaying: Bool
    let hasAsset: Bool
    let isLoading: Bool
    let canSeek: Bool
    let playMode: MagicPlayMode
    let onPlayPause: () -> Void
    let onSkipForward: () -> Void
    let onSkipBackward: () -> Void
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onTogglePlayMode: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            MagicPlayModeButton(mode: playMode, action: onTogglePlayMode)
            
            MagicPlayerButton(
                icon: "backward.end.fill",
                action: onPrevious
            )
            
            MagicPlayerButton(
                icon: "backward.fill",
                action: onSkipBackward
            )
            .disabled(!canSeek)
            
            MagicPlayerButton(
                icon: isPlaying ? "pause.fill" : "play.fill",
                size: 50,
                iconSize: 20,
                isActive: isPlaying,
                action: onPlayPause
            )
            .disabled(!hasAsset || isLoading)
            
            MagicPlayerButton(
                icon: "forward.fill",
                action: onSkipForward
            )
            .disabled(!canSeek)
            
            MagicPlayerButton(
                icon: "forward.end.fill",
                action: onNext
            )
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        PlaybackControls(
            isPlaying: true,
            hasAsset: true,
            isLoading: false,
            canSeek: true,
            playMode: .sequence,
            onPlayPause: {},
            onSkipForward: {},
            onSkipBackward: {},
            onNext: {},
            onPrevious: {},
            onTogglePlayMode: {}
        )
        
        PlaybackControls(
            isPlaying: false,
            hasAsset: true,
            isLoading: true,
            canSeek: false,
            playMode: .loop,
            onPlayPause: {},
            onSkipForward: {},
            onSkipBackward: {},
            onNext: {},
            onPrevious: {},
            onTogglePlayMode: {}
        )
    }
    .padding()
    .background(.ultraThinMaterial)
} 
