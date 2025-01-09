import Foundation
import MagicUI
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
    
    /// 播放下一首
    public func next() {
        guard hasAsset else { return }
        
        if isPlaylistEnabled {
            if let nextAsset = _playlist.playNext(mode: playMode) {
                load(asset: nextAsset)
            }
        } else if events.hasNavigationSubscribers {
            // 如果播放列表被禁用但有订阅者，发送请求下一首事件
            if let currentAsset = currentAsset {
                events.onNextRequested.send(currentAsset)
            }
        }
    }
    
    /// 播放上一首
    public func previous() {
        guard hasAsset else { return }
        
        if isPlaylistEnabled {
            if let previousAsset = _playlist.playPrevious(mode: playMode) {
                load(asset: previousAsset)
            }
        } else if events.hasNavigationSubscribers {
            // 如果播放列表被禁用但有订阅者，发送请求上一首事件
            if let currentAsset = currentAsset {
                events.onPreviousRequested.send(currentAsset)
            }
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
    
    /// 启用播放列表功能
    func enablePlaylist() {
        guard !isPlaylistEnabled else { return }
        
        isPlaylistEnabled = true
        log("Playlist enabled")
        showToast(
            "Playlist enabled",
            icon: "list.bullet.circle.fill",
            style: .info
        )
    }
    
    /// 禁用播放列表功能
    /// 禁用时会保留当前播放的资源（如果有），清除其他资源
    func disablePlaylist() {
        guard isPlaylistEnabled else { return }
        
        isPlaylistEnabled = false
        log("Playlist disabled")
        
        // 如果禁用播放列表，保留当前播放的资源
        if let currentAsset = currentAsset {
            items = [currentAsset]
            currentIndex = 0
        } else {
            items.removeAll()
            currentIndex = -1
        }
        
        showToast(
            "Playlist disabled",
            icon: "list.bullet.circle",
            style: .info
        )
    }
    
    /// 设置播放列表启用状态
    /// - Parameter enabled: 是否启用播放列表
    func setPlaylistEnabled(_ enabled: Bool) {
        if enabled {
            enablePlaylist()
        } else {
            disablePlaylist()
        }
    }
    
    /// 切换当前资源的喜欢状态
    func toggleLike() {
        guard let asset = currentAsset else { return }
        setLike(!likedAssets.contains(asset.url))
    }
    
    /// 设置当前资源的喜欢状态
    /// - Parameter isLiked: 是否喜欢
    func setLike(_ isLiked: Bool) {
        guard let asset = currentAsset else { 
            log("Cannot set like: no asset loaded", level: .warning)
            return 
        }
        
        if isLiked {
            likedAssets.insert(asset.url)
            log("Added to liked: \(asset.title)")
            showToast("Added to liked", icon: .iconHeartFill, style: .info)
        } else {
            likedAssets.remove(asset.url)
            log("Removed from liked: \(asset.title)")
            showToast("Removed from liked", icon: .iconHeart, style: .info)
        }
        
        // 通知订阅者喜欢状态变化
        events.onLikeStatusChanged.send((asset: asset, isLiked: isLiked))
        updateNowPlayingInfo()
    }
}

#Preview("MagicPlayMan") {
    MagicThemePreview {
        MagicPlayMan.PreviewView()
    }
}
