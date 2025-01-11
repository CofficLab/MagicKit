import SwiftUI

/// 头像视图的功能展示组件
public struct AvatarDemoView: View {
    @State private var downloadProgress: Double = 0.0
    @State private var icloudFiles: [URL] = []
    @State private var isCreatingFiles = false
    @State private var errorMessage: String?
    @State private var cacheFiles: [URL] = []
    
    public init() {
        _cacheFiles = State(initialValue: Self.loadCacheFiles())
    }
    
    private static func loadCacheFiles() -> [URL] {
        let cacheDir = URL.thumbnailCacheDirectory()
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: cacheDir,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }
        return files
    }
    
    private func createICloudFiles() {
        isCreatingFiles = true
        errorMessage = nil
        
        URL.createICloudSamples { files, error in
            isCreatingFiles = false
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                icloudFiles = files
            }
        }
    }
    
    public var body: some View {
        TabView {
            // 基础样式
            ScrollView {
                HStack {
                    VStack(spacing: 32) {
                        // 默认样式
                        demoSection("默认样式") {
                            HStack(spacing: 20) {
                                URL.sample_web_jpg_earth.makeAvatarView()
                                
                                URL.sample_web_mp3_kennedy.makeAvatarView()
                                
                                URL.sample_web_mp4_bunny.makeAvatarView()
                            }
                        }
                        
                        // 自定义背景色
                        demoSection("自定义背景色") {
                            HStack(spacing: 20) {
                                URL.sample_web_jpg_earth.makeAvatarView()
                                    .magicBackground(.red.opacity(0.1))
                                
                                URL.sample_web_jpg_earth.makeAvatarView()
                                    .magicBackground(.green.opacity(0.1))
                                    .magicAvatarShape(.hexagon)
                                
                                URL.sample_web_jpg_earth.makeAvatarView()
                                    .magicBackground(.purple.opacity(0.1))
                            }
                        }
                        
                        // 不同尺寸
                        demoSection("不同尺寸") {
                            HStack(spacing: 20) {
                                URL.sample_web_jpg_earth.makeAvatarView()
                                    .magicSize(32)
                                
                                URL.sample_web_jpg_earth.makeAvatarView()
                                    .magicSize(48)
                                
                                URL.sample_web_jpg_earth.makeAvatarView()
                                    .magicSize(64)
                            }
                        }
                        
                        // 不同形状
                        demoSection("不同形状") {
                            HStack(spacing: 20) {
                                URL.sample_web_jpg_earth.makeAvatarView()
                                    .magicAvatarShape(.circle)
                                
                                URL.sample_web_jpg_earth.makeAvatarView()
                                    .magicAvatarShape(.roundedRectangle(cornerRadius: 8))
                                
                                URL.sample_web_jpg_earth.makeAvatarView()
                                    .magicAvatarShape(.rectangle)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: 500)
                }
                .frame(maxWidth: .infinity)
            }
            .tabItem {
                Label("基础样式", systemImage: .iconPaintpalette)
            }
            
            // 文件类型
            ScrollView {
                HStack {
                    VStack(spacing: 32) {
                        demoSection("不同文件类型") {
                            HStack(spacing: 20) {
                                // 图片文件
                                VStack {
                                    URL.sample_web_jpg_earth.makeAvatarView()
                                    Text("图片")
                                        .font(.caption)
                                }
                                
                                // 音频文件
                                VStack {
                                    URL.sample_web_mp3_kennedy.makeAvatarView()
                                    Text("音频")
                                        .font(.caption)
                                }
                                
                                // 视频文件
                                VStack {
                                    URL.sample_web_mp4_bunny.makeAvatarView()
                                    Text("视频")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: 500)
                }
                .frame(maxWidth: .infinity)
            }
            .tabItem {
                Label("文件类型", systemImage: .iconDocument)
            }
            
            // 下载状态
            ScrollView {
                HStack {
                    VStack(spacing: 32) {
                        // 下载进度
                        demoSection("手动进度控制") {
                            VStack {
                                URL.sample_web_jpg_earth.makeAvatarView()
                                    .magicDownloadProgress($downloadProgress)
                                    .magicSize(64)
                                
                                Slider(value: $downloadProgress, in: 0...1) {
                                    Text("下载进度")
                                } minimumValueLabel: {
                                    Text("0%")
                                } maximumValueLabel: {
                                    Text("100%")
                                }
                            }
                            .frame(maxWidth: 300)
                        }
                        
                        // iCloud 文件
                        demoSection("iCloud 文件") {
                            VStack(spacing: 16) {
                                if isCreatingFiles {
                                    ProgressView("正在准备 iCloud 示例文件...")
                                } else if let error = errorMessage {
                                    VStack(spacing: 8) {
                                        Text("创建失败")
                                            .foregroundStyle(.red)
                                        Text(error)
                                            .font(.caption)
                                            .multilineTextAlignment(.center)
                                        
                                        Button("重试") {
                                            createICloudFiles()
                                        }
                                        .buttonStyle(.borderedProminent)
                                    }
                                } else if icloudFiles.isEmpty {
                                    Button("创建 iCloud 示例文件") {
                                        createICloudFiles()
                                    }
                                    .buttonStyle(.borderedProminent)
                                } else {
                                    HStack(spacing: 20) {
                                        ForEach(icloudFiles, id: \.absoluteString) { url in
                                            VStack {
                                                url.makeAvatarView()
                                                    .magicSize(48)
                                                    .magicDownloadMonitor(true)
                                                Text(url.lastPathComponent)
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                    
                                    Button("重置") {
                                        icloudFiles = []
                                        errorMessage = nil
                                    }
                                    .buttonStyle(.borderless)
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        // 下载监控
                        demoSection("下载监控设置") {
                            HStack(spacing: 20) {
                                // 启用监控
                                VStack {
                                    URL.sample_web_jpg_earth.makeAvatarView()
                                        .magicDownloadMonitor(true)
                                    Text("启用监控")
                                        .font(.caption)
                                }
                                
                                // 禁用监控
                                VStack {
                                    URL.sample_web_jpg_earth.makeAvatarView()
                                        .magicDownloadMonitor(false)
                                    Text("禁用监控")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: 500)
                }
                .frame(maxWidth: .infinity)
            }
            .tabItem {
                Label("下载状态", systemImage: .iconDownload)
            }
            
            // 错误状态
            ScrollView {
                HStack {
                    VStack(spacing: 32) {
                        demoSection("错误状态") {
                            HStack(spacing: 20) {
                                // 无效 URL
                                VStack {
                                    URL.sample_invalid_url.makeAvatarView()
                                    Text("无效URL")
                                        .font(.caption)
                                }
                                
                                // 不存在的文件
                                VStack {
                                    URL.sample_nonexistent_file.makeAvatarView()
                                    Text("不存在")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: 500)
                }
                .frame(maxWidth: .infinity)
            }
            .tabItem {
                Label("错误状态", systemImage: .iconWarning)
            }
            
            // 缓存管理
            ScrollView {
                HStack {
                    VStack(spacing: 32) {
                        demoSection("缓存文件夹") {
                            VStack(spacing: 16) {
                                // 显示缓存目录路径和打开按钮
                                HStack {
                                    Text(URL.thumbnailCacheDirectory().path)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    URL.thumbnailCacheDirectory()
                                        .makeOpenButton(size: 24)
                                }
                                
                                if cacheFiles.isEmpty {
                                    Text("缓存文件夹为空")
                                        .foregroundStyle(.secondary)
                                } else {
                                    // 显示缓存文件列表
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 20) {
                                            ForEach(cacheFiles, id: \.lastPathComponent) { url in
                                                VStack {
                                                    Text(url.lastPathComponent)
                                                        .font(.caption)
                                                        .lineLimit(1)
                                                        .frame(width: 100)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    
                                    // 清理缓存按钮
                                    Button("清理缓存") {
                                        ThumbnailCache.shared.clearCache()
                                        cacheFiles = Self.loadCacheFiles()
                                    }
                                    .buttonStyle(.borderless)
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: 500)
                }
                .frame(maxWidth: .infinity)
            }
            .tabItem {
                Label("缓存管理", systemImage: .iconFolder)
            }
        }
        .frame(width: 600, height: 800)
    }
    
    private func demoSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
            content()
        }
    }
}

// MARK: - Preview
#Preview("头像视图") {
    MagicThemePreview {
        AvatarDemoView()
    }
}
