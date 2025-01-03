import SwiftUI
import MagicUI

// MARK: - Preview Container
struct ThumbnailPreviewContainer: View {
    var body: some View {
        TabView {
            // 文件类型预览
            FileTypesPreview()
                .tabItem {
                    Label("文件类型", systemImage: "doc")
                }
            
            // 网络文件预览
            NetworkFilesPreview()
                .tabItem {
                    Label("网络文件", systemImage: "globe")
                }
            
            // iCloud文件预览
            CloudFilesPreview()
                .tabItem {
                    Label("iCloud", systemImage: "icloud")
                }
            
            // 缩略图尺寸预览
            ThumbnailSizesPreview()
                .tabItem {
                    Label("尺寸", systemImage: "ruler")
                }
        }
        .frame(width: 500, height: 600)
        .background(MagicBackground.mysticalForest)
    }
}

// MARK: - File Types Preview
private struct FileTypesPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    // 图片文件
                    Text("图片文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    AsyncThumbnailView(
                        url: .sample_jpg_earth,
                        title: "NASA 地球照片"
                    )
                    AsyncThumbnailView(
                        url: .sample_png_transparency,
                        title: "PNG 透明度演示"
                    )
                }
                
                Group {
                    // 音频文件
                    Text("音频文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    AsyncThumbnailView(
                        url: .sample_mp3_kennedy,
                        title: "肯尼迪演讲"
                    )
                    AsyncThumbnailView(
                        url: .sample_wav_mars,
                        title: "火星音效"
                    )
                }
                
                Group {
                    // 视频文件
                    Text("视频文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    AsyncThumbnailView(
                        url: .sample_mp4_bunny,
                        title: "Big Buck Bunny"
                    )
                    AsyncThumbnailView(
                        url: .sample_mp4_sintel,
                        title: "Sintel 预告片"
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Network Files Preview
private struct NetworkFilesPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    Text("网络图片")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach([
                        ("https://example.com/image.jpg", "远程JPG图片"),
                        ("https://example.com/photo.png", "远程PNG图片")
                    ], id: \.0) { urlString, title in
                        if let url = URL(string: urlString) {
                            AsyncThumbnailView(url: url, title: title)
                        }
                    }
                }
                
                Group {
                    Text("网络音频")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach([
                        ("https://example.com/audio.mp3", "远程MP3文件"),
                        ("https://example.com/music.wav", "远程WAV文件")
                    ], id: \.0) { urlString, title in
                        if let url = URL(string: urlString) {
                            AsyncThumbnailView(url: url, title: title)
                        }
                    }
                }
                
                Group {
                    Text("未知类型")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let url = URL(string: "https://example.com/unknown") {
                        AsyncThumbnailView(url: url, title: "未知文件类型")
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Cloud Files Preview
private struct CloudFilesPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                    Text("iCloud文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
//                    AsyncThumbnailView(
//                        url: .sample_icloud_image,
//                        title: "未下载的图片"
//                    )
//                    AsyncThumbnailView(
//                        url: .sample_icloud_video,
//                        title: "未下载的视频"
//                    )
                
            }
            .padding()
        }
    }
}

// MARK: - Thumbnail Sizes Preview
private struct ThumbnailSizesPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    Text("小尺寸 (60x60)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    AsyncThumbnailView(
                        url: .sample_jpg_earth,
                        title: "小缩略图",
                        size: CGSize(width: 60, height: 60)
                    )
                }
                
                Group {
                    Text("中尺寸 (120x120)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    AsyncThumbnailView(
                        url: .sample_jpg_earth,
                        title: "中缩略图",
                        size: CGSize(width: 120, height: 120)
                    )
                }
                
                Group {
                    Text("大尺寸 (200x200)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    AsyncThumbnailView(
                        url: .sample_jpg_earth,
                        title: "大缩略图",
                        size: CGSize(width: 200, height: 200)
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Async Thumbnail View
private struct AsyncThumbnailView: View {
    let url: URL
    let title: String
    let size: CGSize
    @State private var thumbnail: Image?
    @State private var error: Error?
    
    init(url: URL, title: String, size: CGSize = CGSize(width: 120, height: 120)) {
        self.url = url
        self.title = title
        self.size = size
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                // 缩略图
                Group {
                    if let thumbnail = thumbnail {
                        thumbnail
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else if error != nil {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: size.width / 2, height: size.height / 2)
                
                // 文本信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                    if let error {
                        Text(error.localizedDescription)
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
        }
        .task {
            do {
                thumbnail = try await url.thumbnail(size: size)
            } catch {
                self.error = error
            }
        }
    }
}

#Preview("Thumbnails") {
    ThumbnailPreviewContainer()
} 
