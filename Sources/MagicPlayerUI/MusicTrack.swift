import Foundation

public struct MusicTrack: Identifiable {
    public let id: String
    public let title: String
    public let artist: String
    public let duration: TimeInterval
    public let artwork: String?  // 可选的封面图片URL或系统图标名称
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        artist: String,
        duration: TimeInterval,
        artwork: String? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.duration = duration
        self.artwork = artwork
    }
} 