import SwiftUI
import MagicKit

// MARK: - Audio Player View
struct AudioPlayerView: View {
    let title: String
    let artist: String?
    let artwork: Image?
    @State private var loadedArtwork: Image?
    let url: URL?
    
    init(title: String, artist: String? = nil, artwork: Image? = nil, url: URL? = nil) {
        self.title = title
        self.artist = artist
        self.artwork = artwork
        self.url = url
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 封面图
            Group {
                if let loadedArtwork = loadedArtwork {
                    loadedArtwork
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if let artwork = artwork {
                    artwork
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "music.note")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 200, height: 200)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.secondary.opacity(0.1))
            )
            
            // 标题和艺术家
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                
                if let artist = artist {
                    Text(artist)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .task {
            if let url = url {
                do {
                    loadedArtwork = try await url.thumbnail(size: CGSize(width: 600, height: 600), verbose: true)
                } catch {
                    print("Failed to load thumbnail: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Preview
#Preview("MagicPlayMan") {
    MagicThemePreview {
        MagicPlayMan.PreviewView()
    }
}
