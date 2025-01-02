import SwiftUI
import MagicUI

public extension MagicPlayMan {
    /// 创建播放/暂停按钮
    func makePlayPauseButton() -> some View {
        MagicPlayerButton(
            icon: state == .playing ? "pause.fill" : "play.fill",
            size: 50,
            iconSize: 20,
            isActive: state == .playing,
            action: toggle
        )
        .disabled(!hasAsset || state.isLoading)
    }
    
    /// 创建上一曲按钮
    func makePreviousButton() -> some View {
        MagicPlayerButton(
            icon: "backward.end.fill",
            size: 40,
            iconSize: 15,
            action: previous
        )
        .disabled(!hasAsset || currentIndex <= 0)
    }
    
    /// 创建下一曲按钮
    func makeNextButton() -> some View {
        MagicPlayerButton(
            icon: "forward.end.fill",
            size: 40,
            iconSize: 15,
            action: next
        )
        .disabled(!hasAsset || currentIndex >= items.count - 1)
    }
    
    /// 创建快退按钮
    func makeRewindButton() -> some View {
        MagicPlayerButton(
            icon: "gobackward.10",
            size: 40,
            iconSize: 15,
            action: { self.skipBackward() }
        )
        .disabled(!hasAsset || state.isLoading)
    }
    
    /// 创建快进按钮
    func makeForwardButton() -> some View {
        MagicPlayerButton(
            icon: "goforward.10",
            size: 40,
            iconSize: 15,
            action: { self.skipForward() }
        )
        .disabled(!hasAsset || state.isLoading)
    }
    
    /// 创建播放模式按钮
    func makePlayModeButton() -> some View {
        MagicPlayerButton(
            icon: playMode.iconName,
            size: 40,
            iconSize: 15,
            isActive: playMode != .sequence,
            action: togglePlayMode
        )
    }
    
    /// 创建播放列表按钮
    func makePlaylistButton(isPresented: Binding<Bool>) -> some View {
        MagicPlayerButton(
            icon: "list.bullet",
            size: 40,
            iconSize: 15,
            action: { isPresented.wrappedValue.toggle() }
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

