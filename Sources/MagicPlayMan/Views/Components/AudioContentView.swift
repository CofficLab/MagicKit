import SwiftUI
import MagicKit
import MagicUI

struct AudioContentView: View {
    let asset: MagicAsset
    let artwork: Image?  // 允许外部传入缩略图
    @State private var localArtwork: Image?  // 本地加载的缩略图
    @State private var errorMessage: String?
    
    init(asset: MagicAsset, artwork: Image? = nil) {
        self.asset = asset
        self.artwork = artwork
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // 专辑封面
            Group {
                if let artwork = artwork ?? localArtwork {
                    artwork
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300, maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 5)
                } else if let error = errorMessage {
                    // 错误状态显示
                    VStack(spacing: 12) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // 重试按钮
                        Button {
                            loadArtwork()
                        } label: {
                            Label("Retry", systemImage: "arrow.clockwise")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(width: 300, height: 300)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ProgressView()
                        .frame(width: 300, height: 300)
                }
            }
            .padding()
            
            // 音频信息
            VStack(spacing: 8) {
                Text(asset.metadata.title)
                    .font(.title2)
                    .bold()
                
                if let artist = asset.metadata.artist {
                    Text(artist)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
                if let album = asset.metadata.album {
                    Text(album)
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
            }
            .multilineTextAlignment(.center)
        }
        .task {
            // 如果没有外部传入的缩略图，则尝试加载
            if artwork == nil {
                loadArtwork()
            }
        }
    }
    
    private func loadArtwork() {
        // 重置状态
        localArtwork = nil
        errorMessage = nil
        
        Task {
            do {
                if let image = try await asset.url.thumbnail(size: CGSize(width: 600, height: 600)) {
                    localArtwork = image
                } else {
                    errorMessage = "No artwork available"
                }
            } catch {
                errorMessage = "Failed to load artwork:\n\(error.localizedDescription)"
            }
        }
    }
}

#Preview("Normal State") {
    AudioContentView(
        asset: .init(
            url: .documentsDirectory,
            type: .audio,
            metadata: .init(
                title: "Test Song",
                artist: "Test Artist",
                album: "Test Album"
            )
        )
    )
    .frame(width: 400, height: 500)
    .background(.ultraThinMaterial)
}

#Preview("Error State") {
    let errorAsset = MagicAsset(
        url: URL(string: "invalid://url")!,
        type: .audio,
        metadata: .init(
            title: "Error Test",
            artist: "Error Artist",
            album: "Error Album"
        )
    )
    
    return AudioContentView(asset: errorAsset)
        .frame(width: 400, height: 500)
        .background(.ultraThinMaterial)
} 