import SwiftUI
import MagicUI

public extension MagicPlayMan {
    /// 创建播放状态视图
    func makeStateView() -> some View {
        state.makeStateView(assetTitle: currentAsset?.title)
    }
    
    /// 创建日志视图
    func makeLogView() -> some View {
        logger.makeLogView()
    }
    
    /// 创建播放列表视图
    func makePlaylistView() -> some View {
        playlist.makeListView(
            onSelect: { [weak self] asset in
                self?.play(asset: asset)
            },
            onRemove: { [weak self] index in
                self?.removeFromPlaylist(at: index)
            },
            onMove: { [weak self] from, to in
                self?.moveInPlaylist(from: from, to: to)
            }
        )
    }
    
    /// 视频播放视图
    var videoView: some View {
        VideoPlayerView(player: player)
            .opacity(currentAsset?.type == .video ? 1 : 0)
    }
    
    /// 音频播放视图
    var audioView: some View {
        MagicAudioView(
            title: currentAsset?.metadata.title ?? "No Title",
            artist: currentAsset?.metadata.artist
        )
        .opacity(currentAsset?.type == .audio ? 1 : 0)
    }
    
    /// 空状态视图
    var emptyView: some View {
        MagicAudioView(
            title: "No Media Selected",
            artist: "Select a media file to play"
        )
    }
}

// MARK: - Preview
#Preview("MagicPlayMan Views") {
    ViewsPreview()
}

private struct ViewsPreview: View {
    @StateObject private var playMan = MagicPlayMan()
    
    var body: some View {
        VStack(spacing: 20) {
            // 状态视图
            Group {
                Text("State View")
                    .font(.headline)
                playMan.makeStateView()
            }
            
            // 播放列表视图
            Group {
                Text("Playlist View")
                    .font(.headline)
                playMan.makePlaylistView()
                    .frame(height: 200)
            }
            
            // 音频/视频视图
            Group {
                Text("Media View")
                    .font(.headline)
                if playMan.currentAsset == nil {
                    playMan.emptyView
                } else if playMan.currentAsset?.type == .video {
                    playMan.videoView
                } else {
                    playMan.audioView
                }
            }
            .frame(height: 200)
            
            // 日志视图
            Group {
                Text("Log View")
                    .font(.headline)
                playMan.makeLogView()
                    .frame(height: 200)
            }
        }
        .padding()
        .onAppear {
            // 添加一些测试数据
            playMan.log("Initializing player...")
            playMan.log("Loading test media...", level: .warning)
            playMan.log("Failed to load media", level: .error)
        }
    }
} 