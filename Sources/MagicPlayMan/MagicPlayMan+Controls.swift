import AVFoundation
import Foundation
import MagicKit
import SwiftUI

public extension MagicPlayMan {
    /// 加载并播放一个 URL
    /// - Parameters:
    ///   - url: 要播放的媒体 URL
    ///   - title: 可选的标题，如果不提供则使用文件名
    ///   - autoPlay: 是否自动开始播放，默认为 true
    /// - Returns: 如果成功加载返回 true，否则返回 false
    @MainActor @discardableResult
    func play(url: URL, autoPlay: Bool = true) -> Bool {
        // 检查 URL 是否有效
        guard url.isFileURL || url.isNetworkURL else {
            log("Invalid URL scheme: \(url.scheme ?? "nil")", level: .error)
            return false
        }

        // 判断媒体类型
        if url.isVideo == false && url.isAudio == false {
            log("Unsupported media type: \(url.pathExtension)", level: .error)
            return false
        }

        // 创建资源元数据
        let metadata = MagicAsset.Metadata(
            title: url.title,
            artist: nil,
            album: nil,
            artwork: nil
        )

        // 创建资源对象
        let asset = MagicAsset(
            url: url,
            metadata: metadata
        )

        self.currentAsset = asset

        // 加载资源
        if autoPlay {
            if isPlaylistEnabled {
                if playlist.play(asset) {
                    loadFromURL(asset.url)
                } else {
                    playlist.append(asset)
                    _ = playlist.play(asset)
                    loadFromURL(asset.url)
                }
            } else {
                loadFromURL(asset.url)
            }
        } else if isPlaylistEnabled {
            append(asset)
        } else {
            log("Cannot append: playlist is disabled", level: .warning)
            return false
        }

        log("▶️ Added URL to playlist: \(url.absoluteString)")
        return true
    }

    /// 加载并播放多个 URL
    /// - Parameters:
    ///   - urls: 要播放的媒体 URL 数组
    ///   - playFirst: 是否立即播放第一个资源，默认为 true
    /// - Returns: 成功加载的 URL 数量
    @MainActor @discardableResult
    func play(
        urls: [URL],
        playFirst: Bool = true
    ) -> Int {
        guard isPlaylistEnabled || urls.count == 1 else {
            log("Cannot play multiple URLs: playlist is disabled", level: .warning)
            return 0
        }

        var successCount = 0

        for (index, url) in urls.enumerated() {
            let shouldAutoPlay = playFirst && index == 0
            if play(url: url, autoPlay: shouldAutoPlay) {
                successCount += 1
            }
        }

        log("Added \(successCount) of \(urls.count) URLs to playlist")
        return successCount
    }

    /// 手动刷新当前资源的缩略图
    func reloadThumbnail() {
        guard let asset = currentAsset else { return }
        loadThumbnail(for: asset.url)
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
    func next() {
        guard hasAsset else { return }

        if isPlaylistEnabled {
            if let nextAsset = _playlist.playNext(mode: playMode) {
                loadFromURL(nextAsset.url)
            }
        } else if events.hasNavigationSubscribers {
            // 如果播放列表被禁用但有订阅者，发送请求下一首事件
            if let currentAsset = currentAsset {
                events.onNextRequested.send(currentAsset)
            }
        }
    }

    /// 播放上一首
    func previous() {
        guard hasAsset else { return }

        if isPlaylistEnabled {
            if let previousAsset = _playlist.playPrevious(mode: playMode) {
                loadFromURL(previousAsset.url)
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
            log("⚠️ Cannot play: no asset loaded", level: .warning)
            return
        }

        if currentTime == duration {
            self.seek(time: 0)
        }

        _player.play()
        state = .playing
        log("▶️ Started playback: \(currentAsset?.title ?? "Unknown")")
        updateNowPlayingInfo()
    }

    /// 暂停播放
    func pause() {
        guard hasAsset else { return }

        _player.pause()
        state = .paused
        log("⏸️ Paused playback")
        updateNowPlayingInfo()
    }

    /// 停止播放
    func stop() {
        _player.pause()
        _player.seek(to: .zero)
        state = .stopped
        log("⏹️ Stopped playback")
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
            log("⚠️ Cannot seek: no asset loaded", level: .warning)
            return
        }

        let targetTime = CMTime(seconds: time, preferredTimescale: 600)
        log("⏩ Seeking to \(Int(time))s")
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
        log("⏩ Skipped forward \(Int(seconds))s")
    }

    /// 快退指定时间
    /// - Parameter seconds: 快退的秒数，默认 10 秒
    func skipBackward(_ seconds: TimeInterval = 10) {
        seek(time: max(currentTime - seconds, 0))
        log("⏪ Skipped backward \(Int(seconds))s")
    }

    /// 调整音量
    /// - Parameter volume: 目标音量，范围 0-1
    func setVolume(_ volume: Float) {
        _player.volume = max(0, min(1, volume))
        log("🔊 Volume set to \(Int(volume * 100))%")
    }

    /// 静音控制
    /// - Parameter muted: 是否静音
    func setMuted(_ muted: Bool) {
        _player.isMuted = muted
        log(muted ? "🔇 Audio muted" : "🔊 Audio unmuted")
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
        log("📑 Playlist enabled")
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
        log("📑 Playlist disabled")

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

    func showToast(_ message: String, icon: String, style: MagicToast.Style) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .showToast,
                object: nil,
                userInfo: [
                    "message": message,
                    "icon": icon,
                    "style": style,
                ]
            )
        }
    }

    func log(_ message: String, level: PlaybackLog.Level = .info) {
        logger.log(message, level: level)
    }

    /// 清理所有缓存
    func clearCache() {
        do {
            try cache?.clear()
            log("🗑️ Cache cleared")
            showToast("Cache cleared successfully", icon: "trash", style: .info)
        } catch {
            log("❌ Failed to clear cache: \(error.localizedDescription)", level: .error)
            showToast("Failed to clear cache", icon: "exclamationmark.triangle", style: .error)
        }
    }

    /// 设置当前资源的喜欢状态
    /// - Parameter isLiked: 是否喜欢
    func setLike(_ isLiked: Bool) {
        guard let asset = currentAsset else {
            log("⚠️ Cannot set like: no asset loaded", level: .warning)
            return
        }

        if isLiked {
            likedAssets.insert(asset.url)
            log("❤️ Added to liked: \(asset.title)")
            showToast("Added to liked", icon: .iconHeartFill, style: .info)
        } else {
            likedAssets.remove(asset.url)
            log("💔 Removed from liked: \(asset.title)")
            showToast("Removed from liked", icon: .iconHeart, style: .info)
        }

        // 通知订阅者喜欢状态变化
        events.onLikeStatusChanged.send((asset: asset, isLiked: isLiked))
        updateNowPlayingInfo()
    }

    /// 设置详细日志模式
    /// - Parameter enabled: 是否启用详细日志
    func setVerboseMode(_ enabled: Bool) {
        self.verbose = enabled
        log("🔍 Verbose mode \(enabled ? "enabled" : "disabled")")
        showToast(
            "Verbose mode \(enabled ? "enabled" : "disabled")",
            icon: enabled ? "text.bubble.fill" : "text.bubble",
            style: .info
        )
    }
}

#Preview("MagicPlayMan") {
    MagicThemePreview {
        MagicPlayMan.PreviewView()
    }
}
