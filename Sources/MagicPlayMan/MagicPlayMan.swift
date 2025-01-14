import AVFoundation
import Combine
import Foundation
import SwiftUI
import MediaPlayer
import MagicKit

public class MagicPlayMan: ObservableObject, SuperLog {
    public static var emoji = "🎧"
    
    internal let _player = AVPlayer()
    internal var timeObserver: Any?
    internal var nowPlayingInfo: [String: Any] = [:]
    internal let _playlist = Playlist()
    internal var cache: AssetCache?
    internal var verbose: Bool = true
    internal let logger = MagicLogger()
    public var cancellables = Set<AnyCancellable>()
    public var downloadTask: URLSessionDataTask?
    
    /// 播放相关的事件发布者
    public private(set) lazy var events = PlaybackEvents()
    
    @Published public var items: [URL] = []
    @Published public var currentIndex: Int = -1
    @Published public var playMode: MagicPlayMode = .sequence
    @Published public internal(set) var currentURL: URL?
    @Published public internal(set) var state: PlaybackState = .idle
    @Published public internal(set) var currentTime: TimeInterval = 0
    @Published public internal(set) var duration: TimeInterval = 0
    @Published public internal(set) var isBuffering = false
    @Published public internal(set) var progress: Double = 0
    @Published public internal(set) var currentThumbnail: Image?
    @Published public internal(set) var isPlaylistEnabled: Bool = true
    @Published public internal(set) var likedAssets: Set<URL> = []

}

#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
}
