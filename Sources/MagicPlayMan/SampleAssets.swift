import Foundation

/// 预置的示例资源
public struct SampleAssets {
    /// 示例音频资源
    public static let audioSamples: [(name: String, asset: MagicAsset)] = [
        (
            "MP3 Sample",
            MagicAsset(
                url: URL(string: "https://download.samplelib.com/mp3/sample-15s.mp3")!,
                type: .audio,
                metadata: AssetMetadata(
                    title: "MP3 Sample",
                    artist: "Sample Artist",
                    duration: 15
                )
            )
        ),
        (
            "WAV Sample",
            MagicAsset(
                url: URL(string: "https://download.samplelib.com/wav/sample-3s.wav")!,
                type: .audio,
                metadata: AssetMetadata(
                    title: "WAV Sample",
                    artist: "Sample Artist",
                    duration: 3
                )
            )
        ),
        (
            "AAC Sample",
            MagicAsset(
                url: URL(string: "https://download.samplelib.com/aac/sample-9s.aac")!,
                type: .audio,
                metadata: AssetMetadata(
                    title: "AAC Sample",
                    artist: "Sample Artist",
                    duration: 9
                )
            )
        ),
    ]

    /// 示例视频资源
    public static let videoSamples: [(name: String, asset: MagicAsset)] = [
        (
            "MP4 Sample",
            MagicAsset(
                url: URL(string: "https://download.samplelib.com/mp4/sample-5s.mp4")!,
                type: .video,
                metadata: AssetMetadata(
                    title: "MP4 Sample",
                    artist: "Sample Director",
                    duration: 5
                )
            )
        ),
        (
            "MOV Sample",
            MagicAsset(
                url: URL(string: "https://download.samplelib.com/mov/sample-10s.mov")!,
                type: .video,
                metadata: AssetMetadata(
                    title: "MOV Sample",
                    artist: "Sample Director",
                    duration: 10
                )
            )
        ),
    ]
    
    /// 所有示例资源
    public static var allSamples: [(name: String, asset: MagicAsset)] {
        audioSamples + videoSamples
    }
} 