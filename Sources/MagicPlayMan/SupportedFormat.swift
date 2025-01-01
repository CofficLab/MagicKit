import Foundation

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
                    name: "MP3 Sample (15s)",
                    asset: MagicAsset(
                        url: URL(string: "https://download.samplelib.com/mp3/sample-15s.mp3")!,
                        type: .audio,
                        metadata: AssetMetadata(
                            title: "MP3 Sample",
                            artist: "Sample Artist",
                            duration: 15
                        )
                    )
                ),
                Sample(
                    name: "Piano Music (30s)",
                    asset: MagicAsset(
                        url: URL(string: "https://download.samplelib.com/mp3/piano-30s.mp3")!,
                        type: .audio,
                        metadata: AssetMetadata(
                            title: "Piano Music",
                            artist: "Classical Artist",
                            duration: 30
                        )
                    )
                ),
                Sample(
                    name: "Guitar Solo (20s)",
                    asset: MagicAsset(
                        url: URL(string: "https://download.samplelib.com/mp3/guitar-20s.mp3")!,
                        type: .audio,
                        metadata: AssetMetadata(
                            title: "Guitar Solo",
                            artist: "Rock Artist",
                            duration: 20
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
                    name: "WAV Sample (3s)",
                    asset: MagicAsset(
                        url: URL(string: "https://download.samplelib.com/wav/sample-3s.wav")!,
                        type: .audio,
                        metadata: AssetMetadata(
                            title: "WAV Sample",
                            artist: "Sample Artist",
                            duration: 3
                        )
                    )
                ),
                Sample(
                    name: "Drum Beat (10s)",
                    asset: MagicAsset(
                        url: URL(string: "https://download.samplelib.com/wav/drums-10s.wav")!,
                        type: .audio,
                        metadata: AssetMetadata(
                            title: "Drum Beat",
                            artist: "Percussion Artist",
                            duration: 10
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
                    name: "AAC Sample (9s)",
                    asset: MagicAsset(
                        url: URL(string: "https://download.samplelib.com/aac/sample-9s.aac")!,
                        type: .audio,
                        metadata: AssetMetadata(
                            title: "AAC Sample",
                            artist: "Sample Artist",
                            duration: 9
                        )
                    )
                ),
                Sample(
                    name: "Vocal Track (25s)",
                    asset: MagicAsset(
                        url: URL(string: "https://download.samplelib.com/aac/vocal-25s.aac")!,
                        type: .audio,
                        metadata: AssetMetadata(
                            title: "Vocal Track",
                            artist: "Pop Artist",
                            duration: 25
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
                    name: "MP4 Sample (5s)",
                    asset: MagicAsset(
                        url: URL(string: "https://download.samplelib.com/mp4/sample-5s.mp4")!,
                        type: .video,
                        metadata: AssetMetadata(
                            title: "MP4 Sample",
                            artist: "Sample Director",
                            duration: 5
                        )
                    )
                ),
                Sample(
                    name: "Nature Scene (15s)",
                    asset: MagicAsset(
                        url: URL(string: "https://download.samplelib.com/mp4/nature-15s.mp4")!,
                        type: .video,
                        metadata: AssetMetadata(
                            title: "Nature Scene",
                            artist: "Nature Director",
                            duration: 15
                        )
                    )
                ),
                Sample(
                    name: "City Timelapse (20s)",
                    asset: MagicAsset(
                        url: URL(string: "https://download.samplelib.com/mp4/city-20s.mp4")!,
                        type: .video,
                        metadata: AssetMetadata(
                            title: "City Timelapse",
                            artist: "Urban Director",
                            duration: 20
                        )
                    )
                )
            ]
        ),
        
        // MOV
        SupportedFormat(
            name: "MOV",
            type: .video,
            extensions: ["mov"],
            mimeTypes: ["video/quicktime"],
            samples: [
                Sample(
                    name: "MOV Sample (10s)",
                    asset: MagicAsset(
                        url: URL(string: "https://download.samplelib.com/mov/sample-10s.mov")!,
                        type: .video,
                        metadata: AssetMetadata(
                            title: "MOV Sample",
                            artist: "Sample Director",
                            duration: 10
                        )
                    )
                ),
                Sample(
                    name: "Ocean Waves (30s)",
                    asset: MagicAsset(
                        url: URL(string: "https://download.samplelib.com/mov/ocean-30s.mov")!,
                        type: .video,
                        metadata: AssetMetadata(
                            title: "Ocean Waves",
                            artist: "Nature Director",
                            duration: 30
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
                    name: "Live Stream Sample",
                    asset: MagicAsset(
                        url: URL(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8")!,
                        type: .video,
                        metadata: AssetMetadata(
                            title: "Live Stream",
                            artist: "Streaming Provider",
                            duration: 0  // 直播流没有固定时长
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