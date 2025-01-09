import AVFoundation
import MagicUI
import SwiftUI

struct ThumbnailPreview: View {
    @State private var audioThumbnail: Image?
    @State private var videoThumbnail: Image?
    @State private var isLoading = false
    @State private var errorMessage: String?

    // 测试用的音频和视频文件 URL
    private let audioURL = URL.sample_temp_mp3
    private let videoURL = URL.sample_temp_mp4

    var body: some View {
        MagicThemePreview {
            VStack(spacing: 20) {
                Text("缩略图预览")
                    .font(.title)
                    .padding()

                // 音频缩略图展示
                Group {
                    Text("音频文件缩略图")
                        .font(.headline)

                    if let audioThumbnail {
                        audioThumbnail
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    } else {
                        Text("无封面")
                            .frame(width: 200, height: 200)
                            .background(Color.gray.opacity(0.2))
                    }

                    Button("加载音频封面") {
                        loadAudioThumbnail()
                    }
                }

                // 视频缩略图展示
                Group {
                    Text("视频文件缩略图")
                        .font(.headline)

                    if let videoThumbnail {
                        videoThumbnail
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    } else {
                        Text("无封面")
                            .frame(width: 200, height: 200)
                            .background(Color.gray.opacity(0.2))
                    }

                    Button("加载视频封面") {
                        loadVideoThumbnail()
                    }
                }

                if isLoading {
                    ProgressView()
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
    }

    private func loadAudioThumbnail() {
        let url = audioURL

        isLoading = true
        errorMessage = nil

        Task {
            do {
                if let thumbnail = try await url.coverFromMetadata(size: CGSize(width: 200, height: 200)) {
                    await MainActor.run {
                        audioThumbnail = thumbnail
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "加载音频封面失败: \(error.localizedDescription)"
                }
            }

            await MainActor.run {
                isLoading = false
            }
        }
    }

    private func loadVideoThumbnail() {
        let url = videoURL

        isLoading = true
        errorMessage = nil

        Task {
            do {
                if let thumbnail = try await url.thumbnail(size: CGSize(width: 200, height: 200), verbose: true) {
                    await MainActor.run {
                        videoThumbnail = thumbnail
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "加载视频封面失败: \(error.localizedDescription)"
                }
            }

            await MainActor.run {
                isLoading = false
            }
        }
    }
}

#Preview {
    ThumbnailPreview()
}
