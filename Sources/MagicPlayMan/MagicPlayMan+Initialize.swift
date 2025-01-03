import AVFoundation
import Combine
import Foundation
import SwiftUI
import MagicUI
import MediaPlayer

public extension MagicPlayMan {
    /// 初始化播放器
    /// - Parameter cacheDirectory: 自定义缓存目录。如果为 nil，则使用系统默认缓存目录
    convenience init(cacheDirectory: URL? = nil) {
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
                case .paused:
                    if case .playing = self.state {
                        self.state = self.currentTime == 0 ? .stopped : .paused
                    }
                case .waitingToPlayAtSpecifiedRate:
                    self.isBuffering = true
                    if case .playing = self.state {
                        self.state = .loading(.buffering)
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
                if let isEmpty = isEmpty {
                    self?.isBuffering = isEmpty
                }
            }
            .store(in: &cancellables)
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
