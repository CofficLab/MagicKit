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
                // 中国音乐
                Sample(
                    name: "古筝",
                    asset: MagicAsset(
                        url: .sample_web_mp3_guzheng,
                        type: .audio,
                        metadata: MagicAsset.Metadata(
                            title: "古筝",
                            artist: "Monplaisir",
                            album: "中国传统音乐"
                        )
                    )
                ),
                Sample(
                    name: "竹笛",
                    asset: MagicAsset(
                        url: .sample_web_mp3_bamboo,
                        type: .audio,
                        metadata: MagicAsset.Metadata(
                            title: "竹笛",
                            artist: "Chad Crouch",
                            album: "中国传统音乐"
                        )
                    )
                ),
                Sample(
                    name: "二胡",
                    asset: MagicAsset(
                        url: .sample_web_mp3_erhu,
                        type: .audio,
                        metadata: MagicAsset.Metadata(
                            title: "二胡",
                            artist: "Kai Engel",
                            album: "中国传统音乐"
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
                // 自然音效
                Sample(
                    name: "鸟叫",
                    asset: MagicAsset(
                        url: .sample_web_wav_bird,
                        type: .audio,
                        metadata: MagicAsset.Metadata(
                            title: "鸟叫",
                            artist: "大自然",
                            album: "自然音效"
                        )
                    )
                ),
                Sample(
                    name: "雨声",
                    asset: MagicAsset(
                        url: .sample_web_wav_rain,
                        type: .audio,
                        metadata: MagicAsset.Metadata(
                            title: "雨声",
                            artist: "大自然",
                            album: "自然音效"
                        )
                    )
                ),
                Sample(
                    name: "溪流",
                    asset: MagicAsset(
                        url: .sample_web_wav_stream,
                        type: .audio,
                        metadata: MagicAsset.Metadata(
                            title: "溪流",
                            artist: "大自然",
                            album: "自然音效"
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
                // 开源视频
                Sample(
                    name: "Big Buck Bunny",
                    asset: MagicAsset(
                        url: .sample_web_mp4_bunny,
                        type: .video,
                        metadata: MagicAsset.Metadata(
                            title: "Big Buck Bunny",
                            artist: "Blender Foundation",
                            album: "开源动画"
                        )
                    )
                ),
                Sample(
                    name: "Sintel",
                    asset: MagicAsset(
                        url: .sample_web_mp4_sintel,
                        type: .video,
                        metadata: MagicAsset.Metadata(
                            title: "Sintel",
                            artist: "Blender Foundation",
                            album: "开源动画"
                        )
                    )
                ),
                Sample(
                    name: "Elephants Dream",
                    asset: MagicAsset(
                        url: .sample_web_mp4_elephants,
                        type: .video,
                        metadata: MagicAsset.Metadata(
                            title: "Elephants Dream",
                            artist: "Blender Foundation",
                            album: "开源动画"
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
                    name: "测试流 1",
                    asset: MagicAsset(
                        url: .sample_web_stream_test1,
                        type: .video,
                        metadata: MagicAsset.Metadata(
                            title: "测试流 1",
                            artist: "Mux",
                            album: "测试直播"
                        )
                    )
                ),
                Sample(
                    name: "测试流 2",
                    asset: MagicAsset(
                        url: .sample_web_stream_test2,
                        type: .video,
                        metadata: MagicAsset.Metadata(
                            title: "测试流 2",
                            artist: "Akamai",
                            album: "测试直播"
                        )
                    )
                ),
                Sample(
                    name: "测试流 3",
                    asset: MagicAsset(
                        url: .sample_web_stream_test3,
                        type: .video,
                        metadata: MagicAsset.Metadata(
                            title: "测试流 3",
                            artist: "Unified Streaming",
                            album: "测试直播"
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
