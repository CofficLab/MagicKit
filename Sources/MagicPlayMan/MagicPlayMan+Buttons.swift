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
}

// MARK: - Preview
#Preview("Player Buttons") {
    struct ButtonsPreview: View {
        @StateObject private var playMan = MagicPlayMan()
        
        var body: some View {
            VStack(spacing: 20) {
                // 播放控制按钮
                HStack(spacing: 16) {
                    playMan.makePreviousButton()
                    playMan.makeRewindButton()
                    playMan.makePlayPauseButton()
                    playMan.makeForwardButton()
                    playMan.makeNextButton()
                }
                
                // 播放模式按钮
                playMan.makePlayModeButton()
            }
            .padding()
            .background(.background)
        }
    }
    
    return ButtonsPreview()
} 
