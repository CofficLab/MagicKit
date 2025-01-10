import Foundation
import MediaPlayer
import AVFoundation
import SwiftUI
import MagicKit

#if os(macOS)
import AppKit
#else
import UIKit
#endif

// 平台相关的类型别名
#if os(macOS)
typealias PlatformImage = NSImage
#else
typealias PlatformImage = UIImage
#endif 

extension MagicPlayMan {
    func setupRemoteControl() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            log("Audio session setup successful")
        } catch {
            log("Failed to setup audio session: \(error.localizedDescription)", level: .error)
        }
        #endif
        
        log("Setting up remote control commands")
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // 播放/暂停
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self else {
                self?.log("Play command failed: Player instance is nil", level: .error)
                return .commandFailed
            }
            
            if self.state != .playing {
                self.log("Remote command: Play")
                self.play()
                return .success
            }
            
            self.log("Play command ignored: Already playing")
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else {
                self?.log("Pause command failed: Player instance is nil", level: .error)
                return .commandFailed
            }
            
            if self.state == .playing {
                self.log("Remote command: Pause")
                self.pause()
                return .success
            }
            
            self.log("Pause command ignored: Not playing")
            return .commandFailed
        }
        
        // 上一首/下一首
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            guard let self = self else {
                self?.log("Previous track command failed: Player instance is nil", level: .error)
                return .commandFailed
            }
            
            self.log("Remote command: Previous track")
            if self.isPlaylistEnabled {
                self.previous()
            } else {
                if let asset = self.currentAsset {
                    self.events.onPreviousRequested.send(asset)
                }
            }
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            guard let self = self else {
                self?.log("Next track command failed: Player instance is nil", level: .error)
                return .commandFailed
            }
            
            self.log("Remote command: Next track")
            if self.isPlaylistEnabled {
                self.next()
            } else {
                if let asset = self.currentAsset {
                    self.events.onNextRequested.send(asset)
                }
            }
            return .success
        }
        
        // 快进/快退
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            guard let self = self else {
                self?.log("Skip forward command failed: Player instance is nil", level: .error)
                return .commandFailed
            }
            
            self.log("Remote command: Skip forward")
            self.skipForward()
            return .success
        }
        
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            guard let self = self else {
                self?.log("Skip backward command failed: Player instance is nil", level: .error)
                return .commandFailed
            }
            
            self.log("Remote command: Skip backward")
            self.skipBackward()
            return .success
        }
        
        // 进度控制
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let event = event as? MPChangePlaybackPositionCommandEvent else {
                self?.log("Seek command failed: Invalid event", level: .error)
                return .commandFailed
            }
            
            let time = TimeInterval(event.positionTime)
            self.log("Remote command: Seek to \(time.displayFormat)")
            self.seek(time: time)
            return .success
        }
        
        // 喜欢/取消喜欢
        if #available(iOS 13.0, macOS 10.15, *) {
            commandCenter.likeCommand.isActive = true  // 启用喜欢按钮
            commandCenter.likeCommand.localizedTitle = "Like"  // 设置按钮标题
            commandCenter.likeCommand.localizedShortTitle = "Like"  // 设置短标题
            
            commandCenter.likeCommand.addTarget { [weak self] event in
                guard let self = self else {
                    self?.log("Like command failed: Player instance is nil", level: .error)
                    return .commandFailed
                }
                
                self.log("Remote command: Toggle like")
                self.toggleLike()
                return .success
            }
        }
        
        log("Remote control setup completed")
    }
    
    func updateNowPlayingInfo() {
        guard let asset = currentAsset else {
            log("Clearing now playing info: No asset")
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        
        log("Updating now playing info for: \(asset.title)")
        
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: asset.title,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: state == .playing ? 1.0 : 0.0
        ]
        
        if let artist = asset.metadata.artist {
            info[MPMediaItemPropertyArtist] = artist
            log("Added artist info: \(artist)")
        }
        
        // 设置媒体类型
        info[MPMediaItemPropertyMediaType] = asset.url.isAudio ? 
            MPMediaType.music.rawValue : MPMediaType.movie.rawValue
        
        // 添加缩略图
        log("Generating thumbnail")
        Task {
            do {
                if let platformImage = try await asset.url.platformThumbnail(
                    size: CGSize(width: 600, height: 600), verbose: true
                ) {
                    info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
                        boundsSize: platformImage.size,
                        requestHandler: { _ in platformImage }
                    )
                    
                    DispatchQueue.main.async {
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                        self.nowPlayingInfo = info
                        self.log("Now playing info updated with thumbnail")
                    }
                } else {
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                    self.nowPlayingInfo = info
                    self.log("No thumbnail available")
                }
            } catch {
                log("Failed to generate thumbnail: \(error.localizedDescription)", level: .warning)
                MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                self.nowPlayingInfo = info
            }
        }
    }
}

// MARK: - Preview
#Preview("MagicPlayMan") {
    MagicThemePreview {
        MagicPlayMan.PreviewView()
    }
}
