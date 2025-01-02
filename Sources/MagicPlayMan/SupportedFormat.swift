import Foundation
import SwiftUI

/// 支持的媒体格式
public struct SupportedFormat {
    /// 媒体类型
    public enum MediaType {
        case audio
        case video
    }
    
    /// 格式名称
    public let name: String
    /// 媒体类型
    public let type: MediaType
    /// 文件扩展名
    public let extensions: [String]
    /// MIME 类型
    public let mimeTypes: [String]
    /// 示例资源
    public let samples: [Sample]
    
    /// 示例资源
    public struct Sample {
        public let name: String
        public let asset: MagicAsset
        
        public init(name: String, asset: MagicAsset) {
            self.name = name
            self.asset = asset
        }
    }
    
    /// 所有支持的格式
    public static let allFormats: [SupportedFormat] = [
        // MP3
        SupportedFormat(
            name: "MP3",
            type: .audio,
            extensions: ["mp3"],
            mimeTypes: ["audio/mpeg"],
            samples: [
                Sample(
                    name: "Snow Fight",
                    asset: MagicAsset(
                        url: URL(string: "https://storage.googleapis.com/media-session/sintel/snow-fight.mp3")!,
                        type: .audio,
                        metadata: MagicAsset.Metadata(
                            title: "Snow Fight",
                            artist: "Jan Morgenstern",
                            album: "Album Name"
                        )
                    )
                ),
                Sample(
                    name: "Sintel Trailer Score",
                    asset: MagicAsset(
                        url: URL(string: "https://storage.googleapis.com/media-session/sintel/sintel-trailer-music.mp3")!,
                        type: .audio,
                        metadata: MagicAsset.Metadata(
                            title: "Sintel Trailer Score",
                            artist: "Jan Morgenstern",
                            album: "Album Name"
                        )
                    )
                )
            ]
        ),
        
        // AAC
        SupportedFormat(
            name: "AAC",
            type: .audio,
            extensions: ["aac", "m4a"],
            mimeTypes: ["audio/aac", "audio/mp4"],
            samples: [
                Sample(
                    name: "Apple Music Preview",
                    asset: MagicAsset(
                        url: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/8e/d3/a6/8ed3a6a6-0b06-b4b0-8937-fc0ce6d6f6e2/mzaf_5766840152287573829.plus.aac.p.m4a")!,
                        type: .audio,
                        metadata: MagicAsset.Metadata(
                            title: "Apple Music Sample",
                            artist: "Apple",
                            album: "Album Name"
                        )
                    )
                ),
                Sample(
                    name: "AAC Test Stream",
                    asset: MagicAsset(
                        url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear1/prog_index.m4a")!,
                        type: .audio,
                        metadata: MagicAsset.Metadata(
                            title: "AAC Stream",
                            artist: "Apple",
                            album: "Album Name"
                        )
                    )
                )
            ]
        ),
        
        // WAV
        SupportedFormat(
            name: "WAV",
            type: .audio,
            extensions: ["wav"],
            mimeTypes: ["audio/wav", "audio/x-wav"],
            samples: [
                Sample(
                    name: "W3C Audio Test",
                    asset: MagicAsset(
                        url: URL(string: "https://www.w3schools.com/html/horse.wav")!,
                        type: .audio,
                        metadata: MagicAsset.Metadata(
                            title: "Horse",
                            artist: "W3Schools",
                            album: "Album Name"
                        )
                    )
                ),
                Sample(
                    name: "Sound Bible Sample",
                    asset: MagicAsset(
                        url: URL(string: "https://soundbible.com/grab.php?id=1542&type=wav")!,
                        type: .audio,
                        metadata: MagicAsset.Metadata(
                            title: "Beep Sound",
                            artist: "Sound Bible",
                            album: "Album Name"
                        )
                    )
                )
            ]
        ),
        
        // MP4
        SupportedFormat(
            name: "MP4",
            type: .video,
            extensions: ["mp4", "m4v"],
            mimeTypes: ["video/mp4"],
            samples: [
                Sample(
                    name: "Sintel Trailer",
                    asset: MagicAsset(
                        url: URL(string: "https://media.w3.org/2010/05/sintel/trailer.mp4")!,
                        type: .video,
                        metadata: MagicAsset.Metadata(
                            title: "Sintel",
                            artist: "Blender Foundation",
                            album: "Album Name"
                        )
                    )
                ),
                Sample(
                    name: "Big Buck Bunny",
                    asset: MagicAsset(
                        url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
                        type: .video,
                        metadata: MagicAsset.Metadata(
                            title: "Big Buck Bunny",
                            artist: "Blender Foundation",
                            album: "Album Name"
                        )
                    )
                )
            ]
        ),
        
        // HLS
        SupportedFormat(
            name: "HLS",
            type: .video,
            extensions: ["m3u8"],
            mimeTypes: ["application/x-mpegURL"],
            samples: [
                Sample(
                    name: "Apple Basic Stream",
                    asset: MagicAsset(
                        url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")!,
                        type: .video,
                        metadata: MagicAsset.Metadata(
                            title: "Apple Test Stream",
                            artist: "Apple",
                            album: "Album Name"
                        )
                    )
                ),
                Sample(
                    name: "Apple Advanced Stream",
                    asset: MagicAsset(
                        url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!,
                        type: .video,
                        metadata: MagicAsset.Metadata(
                            title: "Advanced Streaming",
                            artist: "Apple",
                            album: "Album Name"
                        )
                    )
                )
            ]
        )
    ]
    
    /// 获取所有音频示例
    public static var audioSamples: [Sample] {
        allFormats
            .filter { $0.type == .audio }
            .flatMap(\.samples)
    }
    
    /// 获取所有视频示例
    public static var videoSamples: [Sample] {
        allFormats
            .filter { $0.type == .video }
            .flatMap(\.samples)
    }
    
    /// 获取所有示例
    public static var allSamples: [Sample] {
        allFormats.flatMap(\.samples)
    }
} 

#Preview("With Logs") {
    MagicPlayMan.PreviewView(showLogs: true)
        .frame(width: 650, height: 650)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
}
