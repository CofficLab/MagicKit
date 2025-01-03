import Foundation
import AVFoundation
import SwiftUI

@MainActor
public extension MagicPlayMan {
    /// 添加资源到播放列表并播放
    func play(asset: MagicAsset) {
        if !isPlaylistEnabled {
            load(asset: asset)
            return
        }
        
        if playlist.play(asset) {
            load(asset: asset)
        } else {
            playlist.append(asset)
            _ = playlist.play(asset)
            load(asset: asset)
        }
    }
    
    /// 添加资源到播放列表
    func append(_ asset: MagicAsset) {
        guard isPlaylistEnabled else {
            log("Cannot append: playlist is disabled", level: .warning)
            return
        }
        playlist.append(asset)
    }
    
    /// 清空播放列表
    func clearPlaylist() {
        guard isPlaylistEnabled else {
            log("Cannot clear: playlist is disabled", level: .warning)
            return
        }
        playlist.clear()
    }
    
    /// 播放下一曲
    func next() {
        guard isPlaylistEnabled else {
            log("Cannot play next: playlist is disabled", level: .warning)
            return
        }
        if let nextAsset = playlist.playNext(mode: playMode) {
            load(asset: nextAsset)
        }
    }
    
    /// 播放上一曲
    func previous() {
        guard isPlaylistEnabled else {
            log("Cannot play previous: playlist is disabled", level: .warning)
            return
        }
        if let prevAsset = playlist.playPrevious(mode: playMode) {
            load(asset: prevAsset)
        }
    }
    
    /// 从播放列表中移除指定索引的资源
    func removeFromPlaylist(at index: Int) {
        guard isPlaylistEnabled else {
            log("Cannot remove: playlist is disabled", level: .warning)
            return
        }
        playlist.remove(at: index)
    }
    
    /// 移动播放列表中的资源
    func moveInPlaylist(from: Int, to: Int) {
        guard isPlaylistEnabled else {
            log("Cannot move: playlist is disabled", level: .warning)
            return
        }
        playlist.move(from: from, to: to)
    }
    
    /// 开始播放
    func play() {
        guard hasAsset else {
            log("Cannot play: no asset loaded", level: .warning)
            return
        }
        
        if currentTime == duration {
            self.seek(time: 0)
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
    
    /// 跳转到指定时间
    /// - Parameter time: 目标时间（秒）
    func seek(time: TimeInterval) {
        guard hasAsset else { 
            log("Cannot seek: no asset loaded", level: .warning)
            return 
        }
        
        let targetTime = CMTime(seconds: time, preferredTimescale: 600)
        log("Seeking to \(Int(time))s")
        _player.seek(to: targetTime) { [weak self] finished in
            guard let self = self, finished else { return }
            Task { @MainActor in
                self.currentTime = time
                self.updateNowPlayingInfo()
            }
        }
    }
    
    /// 快进指定时间
    /// - Parameter seconds: 快进的秒数，默认 10 秒
    func skipForward(_ seconds: TimeInterval = 10) {
        seek(time: currentTime + seconds)
        log("Skipped forward \(Int(seconds))s")
    }
    
    /// 快退指定时间
    /// - Parameter seconds: 快退的秒数，默认 10 秒
    func skipBackward(_ seconds: TimeInterval = 10) {
        seek(time: max(currentTime - seconds, 0))
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
        Task { @MainActor in
            state = newState
        }
    }
    
    internal func updateCurrentTime(_ time: TimeInterval) {
        Task { @MainActor in
            currentTime = time
        }
    }
}

#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
        .frame(width: 650, height: 800)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
}
