import SwiftUI
import AVKit

public extension MagicPlayMan {
    /// 创建视频播放视图
    /// - Returns: 视频播放视图
    func makeVideoView() -> some View {
        VideoPlayerView(player: player)
    }
}

// MARK: - Video Player View
private struct VideoPlayerView: View {
    let player: AVPlayer
    
    var body: some View {
        VideoPlayer(player: player)
            .aspectRatio(16/9, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.secondary.opacity(0.1))
            )
    }
}

// MARK: - Preview
#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
        .frame(width: 650, height: 800)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
}

