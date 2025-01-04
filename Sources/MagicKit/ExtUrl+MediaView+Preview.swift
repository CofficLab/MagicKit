import SwiftUI
import MagicUI

// MARK: - Preview Container
struct MediaViewPreviewContainer: View {
    var body: some View {
        TabView {
            // 形状预览
            ShapesPreview()
                .tabItem {
                    Label("形状", systemImage: "square.on.circle")
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
            
            // 文件夹预览
            FoldersPreview()
                .tabItem {
                    Label("文件夹", systemImage: "folder.fill")
                }
            
            // 内边距预览
            PaddingPreview()
                .tabItem {
                    Label("内边距", systemImage: "ruler")
                }
        }
        .frame(width: 500, height: 600)
        .background(MagicBackground.mysticalForest)
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
                    URL.sample_jpg_earth.makeMediaView()
                        .withBackground(MagicBackground.mint)
                }
                
                Group {
                    // 无内边距
                    Text("无内边距 (0)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_jpg_earth.makeMediaView()
                        .verticalPadding(0)
                        .withBackground(MagicBackground.aurora)
                }
                
                Group {
                    // 小内边距
                    Text("小内边距 (8)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_jpg_earth.makeMediaView()
                        .verticalPadding(8)
                        .withBackground(MagicBackground.sunset)
                }
                
                Group {
                    // 大内边距
                    Text("大内边距 (24)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_jpg_earth.makeMediaView()
                        .verticalPadding(24)
                        .withBackground(MagicBackground.ocean)
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
                    URL.sample_jpg_earth.makeMediaView()
                        .withBackground(MagicBackground.mint)
                }
                
                Group {
                    // 圆角矩形
                    Text("圆角矩形")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_jpg_earth.makeMediaView()
                        .thumbnailShape(.roundedRectangle(cornerRadius: 8))
                        .withBackground(MagicBackground.aurora)
                }
                
                Group {
                    // 矩形
                    Text("矩形")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_jpg_earth.makeMediaView()
                        .thumbnailShape(.rectangle)
                        .withBackground(MagicBackground.sunset)
                }
                
                Group {
                    // 大圆角矩形
                    Text("大圆角矩形")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_jpg_earth.makeMediaView()
                        .thumbnailShape(.roundedRectangle(cornerRadius: 16))
                        .withBackground(MagicBackground.ocean)
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
                    URL.sample_mp3_kennedy.makeMediaView()
                        .withBackground(MagicBackground.mint)
                }
                
                Group {
                    // 视频文件预览
                    Text("视频文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_mp4_bunny.makeMediaView()
                        .noBackground()
                }
                
                Group {
                    // 图片文件预览
                    Text("图片文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_jpg_earth.makeMediaView()
                        .withBackground(MagicBackground.aurora)
                }
                
                Group {
                    // PDF文件预览
                    Text("PDF文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_pdf_swift_guide.makeMediaView()
                        .withBackground(MagicBackground.cosmicDust)
                }
                
                Group {
                    // 文本文件预览
                    Text("文本文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_txt_mit.makeMediaView()
                        .noBackground()
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
                        .withBackground(MagicBackground.serenity)
                }
                
                Group {
                    // 临时音频文件
                    Text("临时音频文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_mp3.makeMediaView()
                        .withBackground(MagicBackground.lavender)
                }
                
                Group {
                    // 临时视频文件
                    Text("临时视频文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_mp4.makeMediaView()
                        .withBackground(MagicBackground.sunset)
                }
                
                Group {
                    // 临时图片文件
                    Text("临时图片文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_jpg.makeMediaView()
                        .withBackground(MagicBackground.ocean)
                }
                
                Group {
                    // 临时PDF文件
                    Text("临时PDF文件")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_pdf.makeMediaView()
                        .withBackground(MagicBackground.galaxySpiral)
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
                        .withBackground(MagicBackground.mint)
                        .withShape(.rectangle)
                }
                
                Group {
                    // 展开的文件夹预览
                    Text("展开的文件夹预览")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_folder.makeMediaView()
                        .withBackground(MagicBackground.aurora)
                        .showFolderContent()
                }
                
                Group {
                    // 嵌套文件夹预览
                    Text("嵌套文件夹预览")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_folder.appendingPathComponent("subfolder").makeMediaView()
                        .withBackground(MagicBackground.sunset)
                        .showFolderContent()
                }
            }
            .padding()
        }
    }
}

#Preview("Media View") {
    MediaViewPreviewContainer()
}
