import Foundation
import SwiftUI
import MagicKit

// MARK: - Empty Playlist View
public struct EmptyPlaylistView: View {
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("No Items in Playlist")
                    .font(.headline)
                
                Text("Add some media files to get started")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}

// MARK: - Playlist Content View
public struct PlaylistContentView: View {
    @ObservedObject var playMan: MagicPlayMan
    
    public var body: some View {
        List {
            ForEach(playMan.items) { asset in
                PlaylistItemRow(
                    asset: asset,
                    isPlaying: asset == playMan.currentAsset
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    playMan.play(asset: asset)
                }
            }
            .onMove { from, to in
                playMan.moveInPlaylist(from: from.first ?? 0, to: to)
            }
            .onDelete { indexSet in
                for index in indexSet.sorted(by: >) {
                    playMan.removeFromPlaylist(at: index)
                }
            }
        }
        .listStyle(.plain)
        .background(.background)
    }
}

// MARK: - Playlist Item Row
private struct PlaylistItemRow: View {
    let asset: MagicAsset
    let isPlaying: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // 媒体类型图标
            Image(systemName: asset.url.isAudio ? "music.note" : "film")
                .font(.system(size: 24))
                .foregroundStyle(isPlaying ? Color.accentColor : .secondary)
                .frame(width: 32)
            
            // 标题和艺术家
            VStack(alignment: .leading, spacing: 4) {
                Text(asset.metadata.title)
                    .font(.headline)
                    .foregroundStyle(isPlaying ? Color.primary : .secondary)
                
                if let artist = asset.metadata.artist {
                    Text(artist)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // 播放状态指示器
            if isPlaying {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview
#Preview("MagicPlayMan") {
    MagicThemePreview {
        MagicPlayMan.PreviewView()
    }
}

