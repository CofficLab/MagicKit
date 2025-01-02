import SwiftUI
import MagicUI

struct PlaybackControls: View {
    @ObservedObject var playMan: MagicPlayMan
    
    var body: some View {
        HStack(spacing: 16) {
            // 播放模式按钮
            playMan.makePlayModeButton()
            
            Spacer()
            
            // 主控制按钮组
            HStack(spacing: 16) {
                playMan.makePreviousButton()
                playMan.makeRewindButton()
                playMan.makePlayPauseButton()
                playMan.makeForwardButton()
                playMan.makeNextButton()
            }
            
            Spacer()
            
            // 占位，保持对称
            MagicPlayerButton(
                icon: "placeholder", action: {}
            )
            .opacity(0)
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview
#Preview("PlaybackControls") {
    PlaybackControls(playMan: MagicPlayMan())
        .padding()
        .background(.background)
} 
