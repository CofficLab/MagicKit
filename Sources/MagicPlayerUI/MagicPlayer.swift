import SwiftUI
import MagicUI

public struct MagicPlayer: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var isPlaying: Bool
    @Binding var progress: Double
    @Binding var playMode: PlayMode
    let track: MusicTrack?
    var onPlayPause: (() -> Void)?
    var onSeek: ((Double) -> Void)?
    var onNext: (() -> Void)?
    var onPrevious: (() -> Void)?
    var onPlayModeChange: ((PlayMode) -> Void)?
    
    public init(
        isPlaying: Binding<Bool>,
        progress: Binding<Double>,
        playMode: Binding<PlayMode>,
        track: MusicTrack? = nil,
        onPlayPause: (() -> Void)? = nil,
        onSeek: ((Double) -> Void)? = nil,
        onNext: (() -> Void)? = nil,
        onPrevious: (() -> Void)? = nil,
        onPlayModeChange: ((PlayMode) -> Void)? = nil
    ) {
        self._isPlaying = isPlaying
        self._progress = progress
        self._playMode = playMode
        self.track = track
        self.onPlayPause = onPlayPause
        self.onSeek = onSeek
        self.onNext = onNext
        self.onPrevious = onPrevious
        self.onPlayModeChange = onPlayModeChange
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Track info
            if let track = track {
                HStack(spacing: 12) {
                    // Artwork
                    if let artwork = track.artwork {
                        if artwork.hasPrefix("http") {
                            AsyncImage(url: URL(string: artwork)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.secondary.opacity(0.2)
                            }
                            .frame(width: 40, height: 40)
                            .cornerRadius(6)
                        } else {
                            Image(systemName: artwork)
                                .font(.system(size: 20))
                                .foregroundColor(.secondary)
                                .frame(width: 40, height: 40)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(6)
                        }
                    } else {
                        Image(systemName: "music.note")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                            .frame(width: 40, height: 40)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(6)
                    }
                    
                    // Track details
                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title)
                            .font(.system(size: 14, weight: .medium))
                            .lineLimit(1)
                        
                        Text(track.artist)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 4)
            }
            
            // Progress bar
            MagicProgressBar(
                progress: $progress,
                duration: track?.duration ?? 0,
                onSeek: onSeek
            )
            
            // Control buttons
            HStack(spacing: 24) {
                MagicPlayModeButton(
                    mode: $playMode,
                    onChange: onPlayModeChange
                )
                
                MagicPlayerButton(
                    icon: "backward.fill",
                    action: { onPrevious?() }
                )
                
                MagicPlayerButton(
                    icon: isPlaying ? "pause.fill" : "play.fill",
                    size: 50,
                    iconSize: 20,
                    isActive: true,
                    action: {
                        isPlaying.toggle()
                        onPlayPause?()
                    }
                )
                
                MagicPlayerButton(
                    icon: "forward.fill",
                    action: { onNext?() }
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(
                    color: colorScheme == .dark 
                        ? Color.white.opacity(0.05) 
                        : Color.black.opacity(0.1),
                    radius: colorScheme == .dark ? 15 : 10,
                    y: colorScheme == .dark ? 2 : 0
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            colorScheme == .dark 
                                ? Color.white.opacity(0.1) 
                                : Color.clear,
                            lineWidth: 0.5
                        )
                )
        )
    }
}

#Preview("MagicPlayer") {
    struct PreviewWrapper: View {
        @State private var isPlaying = true
        @State private var progress = 0.3
        @State private var playMode = PlayMode.sequence
        
        let sampleTrack = MusicTrack(
            title: "Blinding Lights",
            artist: "The Weeknd",
            duration: 180,
            artwork: "music.note.list"
        )
        
        var body: some View {
            HStack {
                VStack(spacing: 20) {
                    Text("Light Mode")
                        .font(.headline)
                    
                    MagicPlayer(
                        isPlaying: $isPlaying,
                        progress: $progress,
                        playMode: $playMode,
                        track: sampleTrack,
                        onPlayPause: {
                            print("Play/Pause toggled")
                        },
                        onSeek: { newProgress in
                            print("Seeked to: \(newProgress)")
                        },
                        onNext: {
                            print("Next pressed")
                        },
                        onPrevious: {
                            print("Previous pressed")
                        },
                        onPlayModeChange: { newMode in
                            print("Play mode changed to: \(newMode)")
                        }
                    )
                    .frame(width: 300)
                }
                .padding()
                .background(.background)
                .environment(\.colorScheme, .light)
                
                VStack(spacing: 20) {
                    Text("Dark Mode")
                        .font(.headline)
                    
                    MagicPlayer(
                        isPlaying: $isPlaying,
                        progress: $progress,
                        playMode: $playMode,
                        track: sampleTrack,
                        onPlayPause: {
                            print("Play/Pause toggled")
                        },
                        onSeek: { newProgress in
                            print("Seeked to: \(newProgress)")
                        },
                        onNext: {
                            print("Next pressed")
                        },
                        onPrevious: {
                            print("Previous pressed")
                        },
                        onPlayModeChange: { newMode in
                            print("Play mode changed to: \(newMode)")
                        }
                    )
                    .frame(width: 300)
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
