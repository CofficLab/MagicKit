import SwiftUI
import MagicUI

public extension MagicPlayMan {
    /// 创建音频播放视图
    /// - Returns: 音频播放视图
    func makeAudioView() -> some View {
        AudioPlayerView(
            title: currentAsset?.metadata.title ?? "No Title",
            artist: currentAsset?.metadata.artist,
            artwork: currentThumbnail
        )
    }
    
    /// 创建空状态视图
    /// - Returns: 空状态视图
    func makeEmptyView() -> some View {
        AudioPlayerView(
            title: "No Media Selected",
            artist: "Select a media file to play",
            artwork: nil
        )
    }
}

// MARK: - Audio Player View
private struct AudioPlayerView: View {
    let title: String
    let artist: String?
    let artwork: Image?
    
    var body: some View {
        VStack(spacing: 20) {
            // 封面图
            Group {
                if let artwork = artwork {
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
    }
} 