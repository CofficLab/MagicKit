import Foundation
import AVFoundation

public struct MagicAsset: Identifiable, Equatable {
    public let id: String
    public let url: URL
    public let type: AssetType
    public let metadata: AssetMetadata
    
    public enum AssetType: Equatable {
        case audio
        case video
    }
    
    public init(
        id: String = UUID().uuidString,
        url: URL,
        type: AssetType,
        metadata: AssetMetadata
    ) {
        self.id = id
        self.url = url
        self.type = type
        self.metadata = metadata
    }
}

public struct AssetMetadata: Equatable {
    public let title: String
    public let artist: String?
    public let artwork: URL?
    public let duration: TimeInterval
    
    public init(
        title: String,
        artist: String? = nil,
        artwork: URL? = nil,
        duration: TimeInterval = 0
    ) {
        self.title = title
        self.artist = artist
        self.artwork = artwork
        self.duration = duration
    }
}
