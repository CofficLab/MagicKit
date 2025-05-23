import MagicCore
import OSLog
import SwiftUI

// MARK: - Thumbnail View

struct ThumbnailView: View, SuperLog {
    nonisolated static let emoji = "🖥️"

    let url: URL?
    let verbose: Bool
    private let preferredThumbnailSize: CGFloat = 512 // 或其他合适的尺寸
    @State private var loadedArtwork: Image?

    init(url: URL? = nil, verbose: Bool = false) {
        self.url = url
        self.verbose = verbose
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 20) {
                // 封面图
                Group {
                    if let loadedArtwork = loadedArtwork {
                        loadedArtwork
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: min(geo.size.width - 40, geo.size.height - 40),
                                height: min(geo.size.width - 40, geo.size.height - 40)
                            )
                            .onAppear {
                                if verbose {
                                    os_log("\(self.t) artwork loaded")
                                }
                            }
                    } else {
                        Image(systemName: "music.note")
                            .font(.system(size: min(geo.size.width, geo.size.height) * 0.3))
                            .foregroundStyle(.secondary)
                            .onAppear {
                                if verbose {
                                    os_log("\(self.t) artwork default")
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .task(id: url) {
                if let url = url {
                    do {
                        loadedArtwork = try await url.thumbnail(
                            size: CGSize(
                                width: preferredThumbnailSize,
                                height: preferredThumbnailSize
                            ),
                            verbose: true, reason: "MagicPlayMan." + self.className + ".task"
                        )
                    } catch {
                        print("Failed to load thumbnail: \(error.localizedDescription)")
                        loadedArtwork = nil
                    }
                } else {
                    loadedArtwork = nil
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
        .inMagicContainer()
}
