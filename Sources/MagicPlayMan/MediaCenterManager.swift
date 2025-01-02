import Foundation
import MediaPlayer
import AVFoundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

class MediaCenterManager {
    private var nowPlayingInfo: [String: Any] = [:]
    private weak var playMan: MagicPlayMan?
    
    init(playMan: MagicPlayMan) {
        self.playMan = playMan
        setupRemoteControl()
    }
    
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
            guard let playMan = self?.playMan else { return .commandFailed }
            if playMan.state != .playing {
                playMan.play()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let playMan = self?.playMan else { return .commandFailed }
            if playMan.state == .playing {
                playMan.pause()
                return .success
            }
            return .commandFailed
        }
        
        // 快进/快退
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            guard let playMan = self?.playMan else { return .commandFailed }
            playMan.skipForward()
            return .success
        }
        
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            guard let playMan = self?.playMan else { return .commandFailed }
            playMan.skipBackward()
            return .success
        }
        
        // 进度控制
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let playMan = self?.playMan,
                  let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            playMan.seek(time: event.positionTime)
            return .success
        }
    }
    
    func updateNowPlayingInfo(
        asset: MagicAsset?,
        state: PlaybackState,
        currentTime: TimeInterval,
        duration: TimeInterval
    ) {
        guard let asset = asset else {
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
                if let image = try? await generateThumbnail(for: asset) {
                    info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
                        boundsSize: image.size,
                        requestHandler: { _ in image }
                    )
                    DispatchQueue.main.async {
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                    }
                }
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        self.nowPlayingInfo = info
    }
    
    func updatePlaybackTime(_ time: TimeInterval) {
        var info = nowPlayingInfo
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        self.nowPlayingInfo = info
    }
    
    private func generateThumbnail(for asset: MagicAsset) async throws -> PlatformImage? {
        guard asset.type == .video else { return nil }
        
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
    
    func cleanup() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
}

// 平台相关的类型别名
#if os(macOS)
typealias PlatformImage = NSImage
#else
typealias PlatformImage = UIImage
#endif 
