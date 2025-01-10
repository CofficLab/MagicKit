import MagicKit
import OSLog
import SwiftUI

// MARK: - Audio Player View

struct AudioPlayerView: View, SuperLog {
    static var emoji = "🖥️"

    let title: String
    let artist: String?
    let url: URL?

    @State private var loadedArtwork: Image?

    init(title: String, artist: String? = nil, url: URL? = nil) {
        self.title = title
        self.artist = artist
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
                        .onAppear {
                            os_log("\(self.t) artwork loaded")
                        }
                } else {
                    Image(systemName: "music.note")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                        .onAppear {
                            os_log("\(self.t) artwork default")
                        }
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
