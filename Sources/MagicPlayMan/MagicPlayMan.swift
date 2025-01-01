import Foundation
import AVFoundation
import Combine

public class MagicPlayMan: ObservableObject {
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    
    @Published public private(set) var currentAsset: MagicAsset?
    @Published public private(set) var state: PlaybackState = .idle
    @Published public private(set) var currentTime: TimeInterval = 0
    @Published public private(set) var duration: TimeInterval = 0
    @Published public private(set) var isBuffering = false
    
    public init() {
        setupPlayer()
    }
    
    private func setupPlayer() {
        player = AVPlayer()
        
        // Add periodic time observer
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            self?.currentTime = time.seconds
        }
    }
    
    public func load(asset: MagicAsset) {
        currentAsset = asset
        state = .loading
        
        let playerItem = AVPlayerItem(url: asset.url)
        player?.replaceCurrentItem(with: playerItem)
        
        // Observe player item status
        playerItem.publisher(for: \.status)
            .sink { [weak self] status in
                switch status {
                case .readyToPlay:
                    self?.duration = playerItem.duration.seconds
                    self?.state = .paused
                case .failed:
                    self?.state = .failed(playerItem.error ?? NSError())
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    public func play() {
        guard state != .playing else { return }
        player?.play()
        state = .playing
    }
    
    public func pause() {
        guard state == .playing else { return }
        player?.pause()
        state = .paused
    }
    
    public func stop() {
        player?.pause()
        seek(to: 0)
        state = .stopped
    }
    
    public func seek(to progress: Double) {
        let time = duration * progress
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
    }
    
    deinit {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        cancellables.removeAll()
    }
}