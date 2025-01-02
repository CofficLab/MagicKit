import Foundation
import MediaPlayer
import AVFoundation
import SwiftUI

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
        info[MPMediaItemPropertyMediaType] = asset.type == .audio ? 
            MPMediaType.music.rawValue : MPMediaType.movie.rawValue
        
        // 如果是视频，添加缩略图
        if asset.type == .video {
            log("Generating thumbnail for video")
            Task {
                if let image = try? await generateThumbnail() {
                    log("Thumbnail generated successfully")
                    #if os(macOS)
                    let size = image.size
                    info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
                        boundsSize: size,
                        requestHandler: { _ in image }
                    )
                    #else
                    let size = image.size
                    info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
                        boundsSize: size,
                        requestHandler: { _ in image }
                    )
                    #endif
                    
                    DispatchQueue.main.async {
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                        self.log("Now playing info updated with thumbnail")
                    }
                } else {
                    log("Failed to generate thumbnail", level: .warning)
                }
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        self.nowPlayingInfo = info
        log("Now playing info updated")
    }
    
    private func generateThumbnail() async throws -> PlatformImage? {
        guard let asset = currentAsset,
              asset.type == .video else { return nil }
        
        log("Starting thumbnail generation")
        let generator = AVAssetImageGenerator(asset: AVAsset(url: asset.url))
        generator.appliesPreferredTrackTransform = true
        
        do {
            let time = CMTime(seconds: 0, preferredTimescale: 600)
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            log("Thumbnail generated successfully")
            
            #if os(macOS)
            return NSImage(cgImage: cgImage, size: .zero)
            #else
            return UIImage(cgImage: cgImage)
            #endif
        } catch {
            log("Failed to generate thumbnail: \(error.localizedDescription)", level: .error)
            return nil
        }
    }
}

// MARK: - Preview
#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
        .frame(width: 650, height: 800)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
}
