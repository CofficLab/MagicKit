import Foundation
import MagicCore
import SwiftUI

public extension MagicPlayMan {
    // MARK: - Playback Mode Management

    /// 切换到下一个播放模式
    ///
    /// 播放模式按以下顺序循环切换：
    /// sequence -> single -> random -> sequence
    func togglePlayMode() {
        changePlayMode(self.playMode.next)
        log("Playback mode changed to: \(playMode.displayName)")
        showToast("Playback mode: \(playMode.displayName)", icon: playMode.icon, style: .info)
    }

    /// 获取当前播放模式的显示名称
    var playModeDisplayName: String {
        playMode.displayName
    }

    /// 获取当前播放模式的图标名称
    var playModeIcon: String {
        playMode.icon
    }
}

// MARK: - Preview

#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
        .inMagicContainer()
}
