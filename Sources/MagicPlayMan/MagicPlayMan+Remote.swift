import Foundation
import MediaPlayer
import AVFoundation
import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension MagicPlayMan {
    func setupRemoteControl() {
        #if os(iOS)
        // 请求音频会话
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
        
        // 设置远程控制事件接收
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // 播放/暂停
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if self.state != .playing {
                self.play()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if self.state == .playing {
                self.pause()
                return .success
            }
            return .commandFailed
        }
        
        // 快进/快退
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.skipForward()
            return .success
        }
        
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.skipBackward()
            return .success
        }
        
        // 进度控制
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            let time = TimeInterval(event.positionTime)
            self.seek(time: time)
            return .success
        }
    }
    
    func updateNowPlayingInfo() {
        guard let asset = currentAsset else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: asset.metadata.title,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: state == .playing ? 1.0 : 0.0
        ]
        
        if let artist = asset.metadata.artist {
            info[MPMediaItemPropertyArtist] = artist
        }
        
        // 设置媒体类型
        info[MPMediaItemPropertyMediaType] = asset.type == .audio ? 
            MPMediaType.music.rawValue : MPMediaType.movie.rawValue
        
        // 如果是视频，可以添加缩略图
        if asset.type == .video {
            Task {
                if let image = try? await generateThumbnail() {
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
                    }
                }
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        self.nowPlayingInfo = info
    }
    
    private func generateThumbnail() async throws -> PlatformImage? {
        guard let asset = currentAsset,
              asset.type == .video else { return nil }
        
        let generator = AVAssetImageGenerator(asset: AVAsset(url: asset.url))
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 0, preferredTimescale: 600)
        let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
        
        #if os(macOS)
        return NSImage(cgImage: cgImage, size: .zero)
        #else
        return UIImage(cgImage: cgImage)
        #endif
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
