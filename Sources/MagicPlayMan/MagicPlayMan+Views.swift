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
    
    /// 创建播放进度条视图
    /// - Parameters:
    ///   - style: 进度条样式
    ///   - showTime: 是否显示时间
    /// - Returns: 进度条视图
    func makeProgressView(
        style: ProgressStyle = .default,
        showTime: Bool = true
    ) -> some View {
        PlaybackProgressView(
            playMan: self,
            style: style,
            showTime: showTime
        )
    }
}

// MARK: - Progress Style
public enum ProgressStyle {
    case `default`
    case compact
    case minimal
    
    var height: CGFloat {
        switch self {
        case .default:
            return 6
        case .compact:
            return 4
        case .minimal:
            return 2
        }
    }
}

// MARK: - Playback Progress View
private struct PlaybackProgressView: View {
    @ObservedObject var playMan: MagicPlayMan
    let style: ProgressStyle
    let showTime: Bool
    
    // 计算当前进度
    private var currentProgress: Double {
        playMan.duration > 0 ? playMan.currentTime / playMan.duration : 0
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // 进度条
            MagicProgressBar(
                progress: .init(
                    get: { currentProgress },
                    set: { progress in
                        playMan.seek(to: playMan.duration * progress)
                    }
                ),
                duration: playMan.duration,
                onSeek: { progress in
                    playMan.seek(to: playMan.duration * progress)
                }
            )
        }
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

#Preview("Progress Views") {
    VStack(spacing: 40) {
        // 默认样式
        MagicPlayMan()
            .makeProgressView()
            .padding()
            .background(.background)
        
        // 紧凑样式
        MagicPlayMan()
            .makeProgressView(style: .compact)
            .padding()
            .background(.background)
        
        // 最小样式
        MagicPlayMan()
            .makeProgressView(style: .minimal, showTime: false)
            .padding()
            .background(.background)
    }
    .padding()
} 
