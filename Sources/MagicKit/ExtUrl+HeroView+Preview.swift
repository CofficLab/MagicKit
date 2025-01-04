import SwiftUI
import MagicUI

// MARK: - Hero View Preview Container
/// 主角视图的预览容器
///
/// 这个容器包含了多个预览场景，用于展示 `HeroView` 在不同情况下的表现：
/// - 文件类型：展示不同类型文件的显示效果
/// - 网络文件：展示远程文件的处理方式
/// - iCloud文件：展示云端文件的下载状态
/// - 下载进度：展示进度控制效果
/// - 尺寸变化：展示不同尺寸下的显示效果
/// - 形状变化：展示不同形状下的显示效果
struct HeroViewPreviewContainer: View {
    var body: some View {
        TabView {
            FileTypesPreview()
                .tabItem { Label("文件类型", systemImage: "doc") }
            
            NetworkFilesPreview()
                .tabItem { Label("网络文件", systemImage: "globe") }
            
            CloudFilesPreview()
                .tabItem { Label("iCloud", systemImage: "icloud") }
            
            DownloadProgressPreview()
                .tabItem { Label("下载进度", systemImage: "arrow.down.circle") }
            
            SizesPreview()
                .tabItem { Label("尺寸", systemImage: "ruler") }
            
            ShapesPreview()
                .tabItem { Label("形状", systemImage: "square.on.circle") }
        }
        .frame(width: 500, height: 600)
        .background(MagicBackground.deepOceanCurrent.opacity(0.1))
    }
}

// MARK: - File Types Preview
/// 展示不同类型文件的预览
private struct FileTypesPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 图片文件
                PreviewSection(title: "图片文件") {
                    PreviewItem(url: .sample_jpg_earth, title: "NASA 地球照片")
                    PreviewItem(url: .sample_png_transparency, title: "PNG 透明度演示")
                }
                
                // 音频文件
                PreviewSection(title: "音频文件") {
                    PreviewItem(url: .sample_mp3_kennedy, title: "肯尼迪演讲")
                    PreviewItem(url: .sample_wav_mars, title: "火星音效")
                }
                
                // 视频文件
                PreviewSection(title: "视频文件") {
                    PreviewItem(url: .sample_mp4_bunny, title: "Big Buck Bunny")
                    PreviewItem(url: .sample_mp4_sintel, title: "Sintel 预告片")
                }
            }
            .padding()
        }
    }
}

// MARK: - Network Files Preview
/// 展示网络文件的预览
private struct NetworkFilesPreview: View {
    /// 网络图片示例
    private let networkImages = [
        ("https://example.com/image.jpg", "远程JPG图片"),
        ("https://example.com/photo.png", "远程PNG图片")
    ]
    
    /// 网络音频示例
    private let networkAudios = [
        ("https://example.com/audio.mp3", "远程MP3文件"),
        ("https://example.com/music.wav", "远程WAV文件")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 网络图片
                PreviewSection(title: "网络图片") {
                    ForEach(networkImages, id: \.0) { urlString, title in
                        if let url = URL(string: urlString) {
                            PreviewItem(url: url, title: title)
                        }
                    }
                }
                
                // 网络音频
                PreviewSection(title: "网络音频") {
                    ForEach(networkAudios, id: \.0) { urlString, title in
                        if let url = URL(string: urlString) {
                            PreviewItem(url: url, title: title)
                        }
                    }
                }
                
                // 未知类型
                PreviewSection(title: "未知类型") {
                    if let url = URL(string: "https://example.com/unknown") {
                        PreviewItem(url: url, title: "未知文件类型")
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Cloud Files Preview
/// 展示iCloud文件的预览
private struct CloudFilesPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                PreviewSection(title: "iCloud文件") {
                    Text("iCloud文件预览暂未实现")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
    }
}

// MARK: - Download Progress Preview
/// 展示下载进度控制的预览
private struct DownloadProgressPreview: View {
    @State private var manualProgress: Double = 0.0
    @State private var animatedProgress: Double = 0.0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 手动控制
                PreviewSection(title: "手动控制") {
                    VStack(spacing: 12) {
                        PreviewItem(url: .sample_mp4_bunny, title: "手动进度控制")
                            .downloadProgress($manualProgress)
                        
                        Slider(value: $manualProgress, in: 0...1) {
                            Text("下载进度")
                        } minimumValueLabel: {
                            Text("0%")
                        } maximumValueLabel: {
                            Text("100%")
                        }
                    }
                }
                
                // 动画控制
                PreviewSection(title: "动画控制") {
                    VStack(spacing: 12) {
                        PreviewItem(url: .sample_mp3_kennedy, title: "动画进度控制")
                            .downloadProgress($animatedProgress)
                        
                        HStack {
                            Button("开始下载") {
                                withAnimation(.linear(duration: 3)) {
                                    animatedProgress = 1.0
                                }
                            }
                            .disabled(animatedProgress > 0)
                            
                            Button("重置") {
                                animatedProgress = 0.0
                            }
                            .disabled(animatedProgress == 0)
                        }
                    }
                }
                
                // 自动监听
                PreviewSection(title: "自动监听") {
                    VStack(spacing: 12) {
                        PreviewItem(url: .sample_jpg_earth, title: "自动进度监听")
                        Text("此视图会自动监听 iCloud 文件的下载进度")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // 禁用监听
                PreviewSection(title: "禁用监听") {
                    VStack(spacing: 12) {
                        PreviewItem(url: .sample_jpg_earth, title: "禁用进度监听")
                            .disableDownloadMonitor()
                        Text("此视图已禁用自动进度监听")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Sizes Preview
/// 展示不同尺寸的预览
private struct SizesPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 小尺寸
                PreviewSection(title: "小尺寸 (32x32)") {
                    PreviewItem(
                        url: .sample_jpg_earth,
                        title: "小缩略图",
                        size: CGSize(width: 32, height: 32)
                    )
                }
                
                // 中尺寸（默认）
                PreviewSection(title: "中尺寸 (40x40，默认)") {
                    PreviewItem(
                        url: .sample_jpg_earth,
                        title: "默认缩略图"
                    )
                }
                
                // 大尺寸
                PreviewSection(title: "大尺寸 (64x64)") {
                    PreviewItem(
                        url: .sample_jpg_earth,
                        title: "大缩略图",
                        size: CGSize(width: 64, height: 64)
                    )
                }
                
                // 超大尺寸
                PreviewSection(title: "超大尺寸 (80x80)") {
                    PreviewItem(
                        url: .sample_jpg_earth,
                        title: "超大缩略图",
                        size: CGSize(width: 80, height: 80)
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Shapes Preview
/// 展示不同形状的预览
private struct ShapesPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 圆形（默认）
                PreviewSection(title: "圆形（默认）") {
                    PreviewItem(url: .sample_jpg_earth, title: "默认圆形")
                }
                
                // 圆角矩形
                PreviewSection(title: "圆角矩形") {
                    PreviewItem(url: .sample_jpg_earth, title: "圆角矩形")
                        .shape(.roundedRectangle(cornerRadius: 8))
                }
                
                // 矩形
                PreviewSection(title: "矩形") {
                    PreviewItem(url: .sample_jpg_earth, title: "矩形")
                        .shape(.rectangle)
                }
                
                // 胶囊形状
                PreviewSection(title: "胶囊形状") {
                    PreviewItem(url: .sample_jpg_earth, title: "胶囊形状",
                                size: CGSize(width: 120, height: 64))
                        .shape(.capsule)
                }
            }
            .padding()
        }
    }
}

// MARK: - Preview Components
/// 预览项目组件
private struct PreviewItem: View {
    let url: URL
    let title: String
    let size: CGSize
    var progressBinding: Binding<Double>? = nil
    var monitorDownload: Bool = true
    var shape: HeroViewShape = .circle
    
    init(
        url: URL,
        title: String,
        size: CGSize = CGSize(width: 40, height: 40),
        progressBinding: Binding<Double>? = nil,
        monitorDownload: Bool = true,
        shape: HeroViewShape = .circle
    ) {
        self.url = url
        self.title = title
        self.size = size
        self.progressBinding = progressBinding
        self.monitorDownload = monitorDownload
        self.shape = shape
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                // 主角视图
                let heroView = HeroView(url: url)
                    .magicShape(shape)
                    .magicDownloadMonitor(monitorDownload)
                    .magicSize(size)
                
                if let binding = progressBinding {
                    heroView.magicDownloadProgress(binding)
                } else {
                    heroView
                }
                
                // 文件信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                    Text(url.lastPathComponent)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
        }
    }
    
    /// 设置下载进度
    func downloadProgress(_ progress: Binding<Double>) -> PreviewItem {
        var view = self
        view.progressBinding = progress
        return view
    }
    
    /// 禁用下载监听
    func disableDownloadMonitor() -> PreviewItem {
        var view = self
        view.monitorDownload = false
        return view
    }
    
    /// 设置形状
    func shape(_ shape: HeroViewShape) -> PreviewItem {
        var view = self
        view.shape = shape
        return view
    }
}

/// 预览分区组件
private struct PreviewSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            content
        }
    }
}

// MARK: - Preview
#Preview("主角视图") {
    HeroViewPreviewContainer()
} 
