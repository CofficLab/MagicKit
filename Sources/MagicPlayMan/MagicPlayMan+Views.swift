import MagicUI
import SwiftUI

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
        Group {
            if items.isEmpty {
                EmptyPlaylistView()
            } else {
                PlaylistContentView(playMan: self)
            }
        }
    }

    func makeAssetView() -> some View {
        return Group {
            if currentAsset == nil {
                makeEmptyView()
            } else if currentAsset?.type == .video {
                makeVideoView()
            } else {
                makeAudioView()
            }
        }
    }

    /// 创建播放进度条视图
    /// - Returns: 进度条视图
    func makeProgressView() -> some View {
        MagicProgressBar(
            currentTime: .init(
                get: { self.currentTime },
                set: { time in
                    self.seek(time: time)
                }
            ),
            duration: duration,
            onSeek: { time in
                self.seek(time: time)
            }
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
