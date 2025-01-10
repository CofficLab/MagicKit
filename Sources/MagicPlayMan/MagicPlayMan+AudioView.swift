import MagicKit
import OSLog
import SwiftUI

// MARK: - Audio Player View

struct AudioPlayerView: View, SuperLog {
    static var emoji = "🖥️"

    let title: String
    let artist: String?
    let url: URL?

    init(title: String, artist: String? = nil, url: URL? = nil) {
        self.title = title
        self.artist = artist
        self.url = url
    }

    var body: some View {
        VStack(spacing: 20) {
            // 使用优化后的 ThumbnailView
            ThumbnailView(url: url)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)

            // 标题和艺术家
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)

                if let artist = artist {
                    Text(artist)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Preview

#Preview("MagicPlayMan") {
    MagicThemePreview {
        MagicPlayMan.PreviewView()
    }
}
