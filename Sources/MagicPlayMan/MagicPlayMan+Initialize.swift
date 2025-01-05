import AVFoundation
import Combine
import Foundation
import SwiftUI
import MagicUI
import MediaPlayer

public extension MagicPlayMan {
    /// 初始化播放器
    /// - Parameters:
    ///   - cacheDirectory: 自定义缓存目录。如果为 nil，则使用系统默认缓存目录
    ///   - playlistEnabled: 是否启用播放列表，默认为 true
    convenience init(
        cacheDirectory: URL? = nil,
        playlistEnabled: Bool = true
    ) {
        self.init()
        
        // 初始化缓存，如果失败则禁用缓存功能
        do {
            self.cache = try AssetCache(directory: cacheDirectory)
            if let cacheDir = self.cache?.directory {
                log("Cache directory: \(cacheDir.path)")
            }
        } catch {
            self.cache = nil
            log("Cache disabled", level: .warning)
        }
        
        // 完成初始化后再设置其他内容
        setupPlayer()
        setupObservers()
        setupRemoteControl()
        
        // 设置播放列表状态
        self.isPlaylistEnabled = playlistEnabled
        if !playlistEnabled {
            log("Playlist disabled")
        }
        
        // 修改监听方式
        _playlist.$items
            .sink { [weak self] items in
                self?.items = items
            }
            .store(in: &cancellables)
        
        _playlist.$currentIndex
            .sink { [weak self] index in
                self?.currentIndex = index
            }
            .store(in: &cancellables)
        
        // 监听日志变化
        logger.$logs
            .assign(to: &$logs)
    }
}

// MARK: - Internal Setup Methods

internal extension MagicPlayMan {
    /// 设置播放器
    func setupPlayer() {
        timeObserver = _player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            if self.duration > 0 {
                self.progress = self.currentTime / self.duration
            }
        }
    }
    
    /// 设置观察者
    func setupObservers() {
        // 监听播放状态
        _player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .playing:
                    if case .loading = self.state {
                        self.state = .playing
                    }
                    self.isBuffering = false
                    self.events.onStateChanged.send(self.state)
                case .paused:
                    if case .playing = self.state {
                        self.state = self.currentTime == 0 ? .stopped : .paused
                        self.events.onStateChanged.send(self.state)
                    }
                case .waitingToPlayAtSpecifiedRate:
                    self.isBuffering = true
                    if case .playing = self.state {
                        self.state = .loading(.buffering)
                        self.events.onStateChanged.send(self.state)
                    }
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // 监听缓冲状态
        _player.publisher(for: \.currentItem?.isPlaybackBufferEmpty)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                guard let self = self else { return }
                if let isEmpty = isEmpty {
                    self.isBuffering = isEmpty
                    self.events.onBufferingStateChanged.send(isEmpty)
                }
            }
            .store(in: &cancellables)
            
        // 监听播放完成
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if let currentAsset = self.currentAsset {
                    self.log("播放完成：\(currentAsset.title)")
                    
                    // 如果是单曲循环模式，重新播放当前曲目
                    if self.playMode == .loop {
                        self.log("单曲循环模式，重新播放：\(currentAsset.title)")
                        Task { @MainActor in
                            self.seek(time: 0)
                            self.play()
                        }
                        return
                    }
                    
                    if !self.isPlaylistEnabled {
                        // 如果播放列表被禁用，通知调用者播放完成
                        self.log("播放列表已禁用，等待订阅者处理下一首")
                        self.events.onNextRequested.send(currentAsset)
                    } else if let nextAsset = self._playlist.playNext(mode: self.playMode) {
                        // 如果播放列表启用，播放下一首
                        self.log("播放列表已启用，即将播放下一首：\(nextAsset.title)")
                        Task { @MainActor in
                            self.load(asset: nextAsset)
                        }
                    } else {
                        self.log("播放列表已到末尾", level: .warning)
                    }
                }
            }
            .store(in: &cancellables)
    }
}

#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
} 
