import MagicUI
import SwiftUI

public extension MagicPlayMan {
    /// 创建播放/暂停按钮
    func makePlayPauseButton() -> some View {
        MagicButton(
            icon: state == .playing ? "pause.fill" : "play.fill",
            style: state == .playing ? .primary : .secondary,
            size: .large,
            shape: .circle,
            disabledReason: !hasAsset ? "No media loaded" :
                state.isLoading ? "Loading..." : nil,
            action: toggle
        )
    }

    /// 创建上一曲按钮
    func makePreviousButton() -> some View {
        MagicButton(
            icon: "backward.end.fill",
            style: .secondary,
            size: .regular,
            shape: .circle,
            disabledReason: !hasAsset ? "No media loaded" :
                currentIndex <= 0 ? "This is the first track" : nil,
            action: previous
        )
    }

    /// 创建下一曲按钮
    func makeNextButton() -> some View {
        MagicButton(
            icon: "forward.end.fill",
            style: .secondary,
            size: .regular,
            shape: .circle,
            disabledReason: !hasAsset ? "No media loaded" :
                currentIndex >= items.count - 1 ? "This is the last track" : nil,
            action: next
        )
    }

    /// 创建快退按钮
    func makeRewindButton() -> some View {
        MagicButton(
            icon: "gobackward.10",
            style: .secondary,
            size: .regular,
            shape: .circle,
            disabledReason: !hasAsset ? "No media loaded" :
                state.isLoading ? "Loading..." : nil,
            action: {
                self.skipBackward()
            }
        )
    }

    /// 创建快进按钮
    func makeForwardButton() -> some View {
        MagicButton(
            icon: "goforward.10",
            style: .secondary,
            size: .regular,
            shape: .circle,
            disabledReason: !hasAsset ? "No media loaded" :
                state.isLoading ? "Loading..." : nil,
            action: {
                self.skipForward()
            }
        )
    }

    /// 创建播放模式按钮
    func makePlayModeButton() -> some View {
        MagicButton(
            icon: playMode.iconName,
            style: playMode != .sequence ? .primary : .secondary,
            size: .regular,
            shape: .circle,
            action: togglePlayMode
        )
    }

    /// 创建播放列表按钮
    func makePlaylistButton() -> some View {
        MagicButton(
            icon: "list.bullet",
            style: .secondary,
            size: .regular,
            shape: .circle,
            disabledReason: !self.isPlaylistEnabled ? "Playlist is disabled\nEnable playlist to view and manage tracks" : nil,
            popoverContent: self.isPlaylistEnabled ? AnyView(
                ZStack {
                    self.makePlaylistView()
                        .frame(width: 300, height: 400)
                        .padding()
                }
            ) : nil,
            action: {}
        )
    }

    /// 创建播放列表启用/禁用按钮
    func makePlaylistToggleButton() -> some View {
        MagicButton(
            icon: self.isPlaylistEnabled ? "list.bullet.circle.fill" : "list.bullet.circle",
            style: self.isPlaylistEnabled ? .primary : .secondary,
            size: .regular,
            shape: .circle,
            action: { [self] in
                self.setPlaylistEnabled(!self.isPlaylistEnabled)
            }
        )
        .symbolEffect(.bounce, value: self.isPlaylistEnabled)
    }

    /// 创建支持的格式按钮
    func makeSupportedFormatsButton() -> some View {
        MagicButton(
            icon: "music.note",
            style: .secondary,
            size: .regular,
            shape: .circle,
            popoverContent: AnyView(
                FormatInfoView(
                    formats: SupportedFormat.allFormats
                )
            ),
            action: {}
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
