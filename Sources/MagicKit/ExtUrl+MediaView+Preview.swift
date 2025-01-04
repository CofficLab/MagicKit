import SwiftUI
import MagicUI

// MARK: - Preview Container
struct MediaViewPreviewContainer: View {
    var body: some View {
        TabView {
            // 文件夹预览
            FoldersPreview()
                .tabItem {
                    Label("文件夹", systemImage: "folder.fill")
                }
            
            // 形状预览
            ShapesPreview()
                .tabItem {
                    Label("形状", systemImage: "square.on.circle")
                }
            
            // 头像形状预览
            AvatarShapesPreview()
                .tabItem {
                    Label("头像", systemImage: "person.crop.circle")
                }
            
            // 远程文件预览
            RemoteFilesPreview()
                .tabItem {
                    Label("远程文件", systemImage: "globe")
                }
            
            // 本地文件预览
            LocalFilesPreview()
                .tabItem {
                    Label("本地文件", systemImage: "folder")
                }
            
            // 内边距预览
            PaddingPreview()
                .tabItem {
                    Label("内边距", systemImage: "ruler")
                }
        }
        .frame(width: 500, height: 600)
        .background(MagicBackground.deepOceanCurrent.opacity(0.1))
    }
}

// MARK: - Avatar Shapes Preview
private struct AvatarShapesPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    // 圆形头像（默认）
                    Text("圆形头像 + 红色背景")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.mint.opacity(0.2))
                        .magicCircleAvatar()
                        .magicAvatarBackground(.red.opacity(0.1))
                }
                
                Group {
                    // 圆角矩形头像
                    Text("圆角矩形头像(圆角8) + 绿色背景")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.aurora.opacity(0.2))
                        .magicRoundedAvatar(8)
                        .magicAvatarBackground(.green.opacity(0.1))
                }
                
                Group {
                    // 矩形头像
                    Text("矩形头像 + 紫色背景")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.sunset.opacity(0.2))
                        .magicRectangleAvatar()
                        .magicAvatarBackground(.purple.opacity(0.1))
                }
                
                Group {
                    // 混合形状示例
                    Text("混合形状示例: 整体圆角矩形(16) + 圆形头像 + 黄色背景")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.ocean.opacity(0.2))
                        .magicShape(.roundedRectangle(cornerRadius: 16))  // 整体形状
                        .magicAvatarShape(.circle)  // 头像形状
                        .magicAvatarBackground(.yellow.opacity(0.1))  // 头像背景色
                }
            }
            .padding()
        }
    }
}

// MARK: - Padding Preview
private struct PaddingPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    // 默认内边距
                    Text("默认内边距 (12)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.mint)
                }
                
                Group {
                    // 无内边距
                    Text("无内边距 (0)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicVerticalPadding(0)
                        .magicBackground(MagicBackground.aurora)
                }
                
                Group {
                    // 小内边距
                    Text("小内边距 (8)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicVerticalPadding(8)
                        .magicBackground(MagicBackground.sunset)
                }
                
                Group {
                    // 大内边距
                    Text("大内边距 (24)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicVerticalPadding(24)
                        .magicBackground(MagicBackground.ocean)
                }
            }
            .padding()
        }
    }
}

// MARK: - Shapes Preview
private struct ShapesPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    // 圆形（默认）
                    Text("圆形（默认）")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.mint)
                }
                
                Group {
                    // 圆角矩形
                    Text("圆角矩形")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicShape(.roundedRectangle(cornerRadius: 8))
                        .magicBackground(MagicBackground.aurora.opacity(0.1))
                }
                
                Group {
                    // 矩形
                    Text("矩形")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicShape(.rectangle)
                        .magicBackground(MagicBackground.sunset)
                }
                
                Group {
                    // 大圆角矩形
                    Text("大圆角矩形")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicShape(.roundedRectangle(cornerRadius: 16))
                        .magicBackground(MagicBackground.ocean)
                }
            }
            .padding()
        }
    }
}

// MARK: - Remote Files Preview
private struct RemoteFilesPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    // 音频文件预览
                    Text("音频文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_mp3_kennedy.makeMediaView()
                        .magicBackground(MagicBackground.mint)
                }
                
                Group {
                    // 视频文件预览
                    Text("视频文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_mp4_bunny.makeMediaView()
                        .magicNoBackground()
                }
                
                Group {
                    // 图片文件预览
                    Text("图片文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.aurora)
                }
                
                Group {
                    // PDF文件预览
                    Text("PDF文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_pdf_swift_guide.makeMediaView()
                        .magicBackground(MagicBackground.cosmicDust)
                }
                
                Group {
                    // 文本文件预览
                    Text("文本文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_txt_mit.makeMediaView()
                        .magicNoBackground()
                }
            }
            .padding()
        }
    }
}

// MARK: - Local Files Preview
private struct LocalFilesPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    // 临时文本文件
                    Text("临时文本文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_txt.makeMediaView()
                        .magicBackground(MagicBackground.serenity)
                }
                
                Group {
                    // 临时音频文件
                    Text("临时音频文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_mp3.makeMediaView()
                        .magicBackground(MagicBackground.lavender)
                }
                
                Group {
                    // 临时视频文件
                    Text("临时视频文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_mp4.makeMediaView()
                        .magicBackground(MagicBackground.sunset)
                }
                
                Group {
                    // 临时图片文件
                    Text("临时图片文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_jpg.makeMediaView()
                        .magicBackground(MagicBackground.ocean)
                }
                
                Group {
                    // 临时PDF文件
                    Text("临时PDF文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_pdf.makeMediaView()
                        .magicBackground(MagicBackground.galaxySpiral)
                }
            }
            .padding()
        }
    }
}

// MARK: - Folders Preview
private struct FoldersPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    // 默认文件夹预览
                    Text("默认文件夹预览")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_folder.makeMediaView()
                        .magicBackground(MagicBackground.mint)
                        .magicShape(.rectangle)
                }
                
                Group {
                    // 展开的文件夹预览
                    Text("展开的文件夹预览")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_folder.makeMediaView()
                        .magicBackground(MagicBackground.aurora.opacity(0.2))
                        .magicShowFolderContent()
                }
                
                Group {
                    // 嵌套文件夹预览
                    Text("嵌套文件夹预览")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_folder.appendingPathComponent("subfolder").makeMediaView()
                        .magicBackground(MagicBackground.sunset)
                        .magicShowFolderContent()
                }
            }
            .padding()
        }
    }
}

#Preview("Media View") {
    MediaViewPreviewContainer()
}
