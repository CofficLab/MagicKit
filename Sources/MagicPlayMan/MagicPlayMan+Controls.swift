import Foundation
import AVFoundation
import SwiftUI

public extension MagicPlayMan {
    /// 开始播放
    func play() {
        guard hasAsset else {
            log("Cannot play: no asset loaded", level: .warning)
            return
        }
        
        _player.play()
        state = .playing
        log("Started playback: \(currentAsset?.title ?? "Unknown")")
        updateNowPlayingInfo()
    }
    
    /// 暂停播放
    func pause() {
        guard hasAsset else { return }
        
        _player.pause()
        state = .paused
        log("Paused playback")
        updateNowPlayingInfo()
    }
    
    /// 停止播放
    func stop() {
        _player.pause()
        _player.seek(to: .zero)
        state = .stopped
        log("Stopped playback")
        updateNowPlayingInfo()
    }
    
    /// 切换播放状态
    /// 如果当前正在播放则暂停，如果当前已暂停则开始播放
    func toggle() {
        switch state {
        case .playing:
            pause()
        case .paused, .stopped:
            play()
        case .loading, .failed, .idle:
            // 在这些状态下不执行任何操作
            log("Cannot toggle playback in current state: \(state)", level: .warning)
            break
        }
    }
    
    /// 跳转到指定进度
    /// - Parameter progress: 目标进度，范围 0-1
    func seek(to progress: Double) {
        guard hasAsset else { return }
        
        let targetTime = duration * progress
        seek(to: targetTime)
    }
    
    /// 跳转到指定时间
    /// - Parameter time: 目标时间（秒）
    func seek(time: TimeInterval) {
        guard hasAsset else { return }
        
        let targetTime = CMTime(seconds: time, preferredTimescale: 600)
        _player.seek(to: targetTime) { [weak self] finished in
            guard let self = self, finished else { return }
            self.currentTime = time
            self.updateNowPlayingInfo()
        }
    }
    
    /// 快进指定时间
    /// - Parameter seconds: 快进的秒数，默认 10 秒
    func skipForward(_ seconds: TimeInterval = 10) {
        seek(to: currentTime + seconds)
        log("Skipped forward \(Int(seconds))s")
    }
    
    /// 快退指定时间
    /// - Parameter seconds: 快退的秒数，默认 10 秒
    func skipBackward(_ seconds: TimeInterval = 10) {
        seek(to: max(currentTime - seconds, 0))
        log("Skipped backward \(Int(seconds))s")
    }
    
    /// 调整音量
    /// - Parameter volume: 目标音量，范围 0-1
    func setVolume(_ volume: Float) {
        _player.volume = max(0, min(1, volume))
        log("Volume set to \(Int(volume * 100))%")
    }
    
    /// 静音控制
    /// - Parameter muted: 是否静音
    func setMuted(_ muted: Bool) {
        _player.isMuted = muted
        log(muted ? "Audio muted" : "Audio unmuted")
    }
    
    internal func updateState(_ newState: PlaybackState) {
        state = newState
    }
    internal func updateCurrentTime(_ time: TimeInterval) {
        currentTime = time
    }
}

// MARK: - Preview
#Preview("Playback Controls") {
    ControlsPreview()
}

private struct ControlsPreview: View {
    @StateObject private var playMan = MagicPlayMan()
    
    var body: some View {
        VStack(spacing: 20) {
            // 播放状态
            playMan.makeStateView()
            
            // 播放控制按钮
            HStack(spacing: 20) {
                Button("Play") { playMan.play() }
                    .buttonStyle(.bordered)
                
                Button("Pause") { playMan.pause() }
                    .buttonStyle(.bordered)
                
                Button("Stop") { playMan.stop() }
                    .buttonStyle(.bordered)
                
                Button("Toggle") { playMan.toggle() }
                    .buttonStyle(.bordered)
            }
            
            // 快进快退控制
            HStack(spacing: 20) {
                Button("Skip -10s") { playMan.skipBackward() }
                    .buttonStyle(.bordered)
                
                Button("Skip +10s") { playMan.skipForward() }
                    .buttonStyle(.bordered)
            }
            
            // 音量控制
            HStack(spacing: 20) {
                Button("Mute") { playMan.setMuted(true) }
                    .buttonStyle(.bordered)
                
                Button("Unmute") { playMan.setMuted(false) }
                    .buttonStyle(.bordered)
                
                Button("50% Volume") { playMan.setVolume(0.5) }
                    .buttonStyle(.bordered)
            }
            
            // 日志显示
            playMan.makeLogView()
                .frame(height: 400)
        }
        .padding()
        .onAppear {
            // 加载测试媒体
            playMan.play(
                url: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/fd/37/41/fd374113-bf05-692f-e157-5c364af08d9d/mzaf_15384825730917775750.plus.aac.p.m4a")!,
                title: "Test Audio"
            )
        }
    }
} 
