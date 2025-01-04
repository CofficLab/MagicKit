import SwiftUI

/// 头像视图的功能展示组件
public struct AvatarDemoView: View {
    @State private var downloadProgress: Double = 0.0
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // 默认样式
                demoSection("默认样式") {
                    AvatarView(url: .sample_jpg_earth)
                }
                
                // 自定义背景色
                demoSection("自定义背景色") {
                    HStack(spacing: 20) {
                        AvatarView(url: .sample_jpg_earth)
                            .magicBackground(.red.opacity(0.1))
                        
                        AvatarView(url: .sample_jpg_earth)
                            .magicBackground(.green.opacity(0.1))
                        
                        AvatarView(url: .sample_jpg_earth)
                            .magicBackground(.purple.opacity(0.1))
                    }
                }
                
                // 不同尺寸
                demoSection("不同尺寸") {
                    HStack(spacing: 20) {
                        AvatarView(url: .sample_jpg_earth)
                            .magicSize(32)
                        
                        AvatarView(url: .sample_jpg_earth)
                            .magicSize(48)
                        
                        AvatarView(url: .sample_jpg_earth)
                            .magicSize(64)
                    }
                }
                
                // 不同形状
                demoSection("不同形状") {
                    HStack(spacing: 20) {
                        AvatarView(url: .sample_jpg_earth)
                            .magicShape(.circle)
                        
                        AvatarView(url: .sample_jpg_earth)
                            .magicShape(.roundedRectangle(cornerRadius: 8))
                        
                        AvatarView(url: .sample_jpg_earth)
                            .magicShape(.rectangle)
                    }
                }
                
                // 下载进度
                demoSection("下载进度") {
                    VStack(spacing: 16) {
                        AvatarView(url: .sample_jpg_earth)
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
                
                // 不同文件类型
                demoSection("不同文件类型") {
                    HStack(spacing: 20) {
                        // 图片文件
                        VStack {
                            AvatarView(url: .sample_jpg_earth)
                            Text("图片")
                                .font(.caption)
                        }
                        
                        // 音频文件
                        VStack {
                            AvatarView(url: .sample_mp3_kennedy)
                            Text("音频")
                                .font(.caption)
                        }
                        
                        // 视频文件
                        VStack {
                            AvatarView(url: .sample_mp4_bunny)
                            Text("视频")
                                .font(.caption)
                        }
                    }
                }
                
                // 错误状态
                demoSection("错误状态") {
                    HStack(spacing: 20) {
                        // 无效 URL
                        VStack {
                            AvatarView(url: URL(string: "invalid://url")!)
                            Text("无效URL")
                                .font(.caption)
                        }
                        
                        // 不存在的文件
                        VStack {
                            AvatarView(url: URL(string: "file:///nonexistent.jpg")!)
                            Text("不存在")
                                .font(.caption)
                        }
                    }
                }
                
                // 下载监控
                demoSection("下载监控") {
                    HStack(spacing: 20) {
                        // 启用监控
                        VStack {
                            AvatarView(url: .sample_jpg_earth)
                                .magicDownloadMonitor(true)
                            Text("启用监控")
                                .font(.caption)
                        }
                        
                        // 禁用监控
                        VStack {
                            AvatarView(url: .sample_jpg_earth)
                                .magicDownloadMonitor(false)
                            Text("禁用监控")
                                .font(.caption)
                        }
                    }
                }
            }
            .padding()
            .frame(width: 500)
        }
        .frame(height: 800)
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
    AvatarDemoView()
} 
