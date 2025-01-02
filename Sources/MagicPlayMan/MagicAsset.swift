import AVFoundation
import Foundation
import SwiftUI

public struct MagicAsset: Identifiable, Equatable {
    public let id: String
    public let url: URL
    public let type: AssetType
    public let metadata: AssetMetadata

    /// 快速访问资源标题
    public var title: String { metadata.title }

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

    public init(url: URL) async {
        self.id = UUID().uuidString
        self.url = url

        // 检测资源类型
        let pathExtension = url.pathExtension.lowercased()
        let audioExtensions = ["mp3", "wav", "m4a", "aac"]
        self.type = audioExtensions.contains(pathExtension) ? .audio : .video

        // 获取资源元数据
        let asset = AVAsset(url: url)
        let duration = TimeInterval(CMTimeGetSeconds(asset.duration))

        // 提取标题（默认使用文件名，去除扩展名）
        var title = url.deletingPathExtension().lastPathComponent

        // 尝试从元数据中获取更多信息
        var artist: String?
        var artworkURL: URL?

        for item in AVMetadataItem.metadataItems(from: asset.metadata, filteredByIdentifier: .commonIdentifierTitle) {
            if let titleString = try? await item.stringValue {
                title = titleString
                break
            }
        }

        for item in AVMetadataItem.metadataItems(from: asset.metadata, filteredByIdentifier: .commonIdentifierArtist) {
            if let artistString = try? await item.stringValue {
                artist = artistString
                break
            }
        }

        self.metadata = AssetMetadata(
            title: title,
            artist: artist,
            artwork: artworkURL,
            duration: duration
        )
    }

    public static func fromURL(_ url: URL) async throws -> Self {
        await .init(url: url)
    }
}

public struct AssetMetadata: Equatable {
    public let title: String
    public let artist: String?
    public let album: String?
    public let artwork: URL?
    public let duration: TimeInterval

    public init(
        title: String,
        artist: String? = nil,
        album: String? = nil,
        artwork: URL? = nil,
        duration: TimeInterval = 0
    ) {
        self.title = title
        self.artist = artist
        self.album = album
        self.artwork = artwork
        self.duration = duration
    }
}

#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
        .frame(width: 650, height: 500)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
}
