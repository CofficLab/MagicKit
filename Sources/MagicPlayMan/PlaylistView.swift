import SwiftUI

public struct PlaylistView: View {
    let playlist: [MagicAsset]
    let currentIndex: Int
    let onSelect: (MagicAsset) -> Void
    let onRemove: (Int) -> Void
    let onMove: (Int, Int) -> Void
    
    public init(
        playlist: [MagicAsset],
        currentIndex: Int,
        onSelect: @escaping (MagicAsset) -> Void,
        onRemove: @escaping (Int) -> Void,
        onMove: @escaping (Int, Int) -> Void
    ) {
        self.playlist = playlist
        self.currentIndex = currentIndex
        self.onSelect = onSelect
        self.onRemove = onRemove
        self.onMove = onMove
    }
    
    public var body: some View {
        List {
            let items = Array(playlist.enumerated())
            ForEach(items, id: \.element.id) { index, asset in
                PlaylistRow(
                    asset: asset,
                    isPlaying: index == currentIndex,
                    onSelect: { onSelect(asset) }
                )
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(index == currentIndex ? 
                              Color.primary.opacity(0.1) : 
                              Color.clear)
                )
            }
            .onMove { from, to in
                guard let source = from.first else { return }
                onMove(source, to)
            }
            .onDelete { indexSet in
                guard let index = indexSet.first else { return }
                onRemove(index)
            }
        }
        .listStyle(.plain)
    }
}

private struct PlaylistRow: View {
    let asset: MagicAsset
    let isPlaying: Bool
    let onSelect: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack {
            // 媒体类型图标
            Image(systemName: asset.url.isAudio ? "music.note" : "film")
                .symbolEffect(.bounce, value: isPlaying)
                .foregroundColor(isPlaying ? .accentColor : .secondary)
            
            // 标题和艺术家
            VStack(alignment: .leading) {
                Text(asset.metadata.title)
                    .foregroundColor(isPlaying ? .accentColor : .primary)
                if let artist = asset.metadata.artist {
                    Text(artist)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 时长
            Text(formatDuration(asset.metadata.duration))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary.opacity(isHovering ? 0.05 : 0))
        )
        .onTapGesture(count: 2) {
            onSelect()
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview("PlaylistView") {
    struct PreviewWrapper: View {
        @State private var playlist: [MagicAsset] = [
            MagicAsset(
                url: URL(string: "https://example.com/1.mp3")!,
                metadata: MagicAsset.Metadata(
                    title: "Song 1",
                    artist: "Artist 1",
                    duration: 180
                )
            ),
            MagicAsset(
                url: URL(string: "https://example.com/2.mp4")!,
                metadata: MagicAsset.Metadata(
                    title: "Video 1",
                    artist: "Director 1",
                    duration: 300
                )
            )
        ]
        @State private var currentIndex = 0
        
        var body: some View {
            PlaylistView(
                playlist: playlist,
                currentIndex: currentIndex,
                onSelect: { _ in },
                onRemove: { _ in },
                onMove: { _, _ in }
            )
            .frame(width: 300, height: 200)
        }
    }
    
    return PreviewWrapper()
} 
