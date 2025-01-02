import Foundation
import SwiftUI

public extension MagicPlayMan {
    // MARK: - Playback Mode Management
    
    /// 切换到下一个播放模式
    /// 
    /// 播放模式按以下顺序循环切换：
    /// sequence -> single -> random -> sequence
    func togglePlayMode() {
        playMode = playMode.next
        log("Playback mode changed to: \(playMode.displayName)")
        showToast("Playback mode: \(playMode.displayName)", icon: playMode.icon, style: .info)
    }
    
    /// 设置播放模式
    /// - Parameter mode: 要设置的播放模式
    func setPlayMode(_ mode: MagicPlayMode) {
        playMode = mode
        log("Playback mode set to: \(mode.displayName)")
        showToast("Playback mode: \(mode.displayName)", icon: mode.icon, style: .info)
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
#Preview("Playback Mode") {
    PlayModePreview()
}

private struct PlayModePreview: View {
    @StateObject private var playMan = MagicPlayMan()
    
    var body: some View {
        List {
            currentModeSection
            setModeSection
            logSection
        }
        .navigationTitle("播放模式")
    }
    
    private var currentModeSection: some View {
        Section("当前播放模式") {
            HStack {
                Image(systemName: playMan.playModeIcon)
                Text(playMan.playModeDisplayName)
            }
            
            Button("切换播放模式") {
                playMan.togglePlayMode()
            }
        }
    }
    
    private var setModeSection: some View {
        Section("设置播放模式") {
            PlayModeButtons(playMan: playMan)
        }
    }
    
    private var logSection: some View {
        Section("日志") {
            playMan.makeLogView()
        }
    }
}

private struct PlayModeButtons: View {
    @ObservedObject var playMan: MagicPlayMan
    private let modes = [MagicPlayMode.sequence, .loop, .shuffle]
    
    var body: some View {
        ForEach(modes, id: \.self) { mode in
            PlayModeButton(
                mode: mode,
                action: { playMan.setPlayMode(mode) }
            )
        }
    }
}
