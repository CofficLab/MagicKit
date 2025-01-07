import SwiftUI
import MagicUI

// MARK: - Preview Container
private struct PreviewContainer<Content: View>: View {
    let title: String
    let content: (Bool) -> Content
    @State private var showBorder = false
    
    var body: some View {
        NavigationStack {
            content(showBorder)
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button(action: {
                            showBorder.toggle()
                        }) {
                            Label(showBorder ? "隐藏边框" : "显示边框", systemImage: showBorder ? .iconSquareDashed : .iconSquare)
                        }
                    }
                }
        }
    }
}

struct MediaViewPreviewContainer: View {
    var body: some View {
        TabView {
            // 文件夹预览
            PreviewContainer(title: "文件夹") { showBorder in
                FoldersContent(showBorder: showBorder)
            }
            .tabItem {
                Label("文件夹", systemImage: .iconFolderFill)
            }
            
            // 形状预览
            PreviewContainer(title: "形状") { showBorder in
                ShapesContent(showBorder: showBorder)
            }
            .tabItem {
                Label("形状", systemImage: .iconSquareOnCircle)
            }
            
            // 头像形状预览
            PreviewContainer(title: "头像形状") { showBorder in
                AvatarShapesContent(showBorder: showBorder)
            }
            .tabItem {
                Label("头像", systemImage: .iconPersonCropCircle)
            }
            
            // 远程文件预览
            PreviewContainer(title: "远程") { showBorder in
                RemoteFilesContent(showBorder: showBorder)
            }
            .tabItem {
                Label("远程", systemImage: .iconGlobe)
            }
            
            // 本地文件预览
            PreviewContainer(title: "本地") { showBorder in
                LocalFilesContent(showBorder: showBorder)
            }
            .tabItem {
                Label("本地", systemImage: .iconFolder)
            }
            
            // 内边距预览
            PreviewContainer(title: "边距") { showBorder in
                PaddingContent(showBorder: showBorder)
            }
            .tabItem {
                Label("边距", systemImage: .iconRuler)
            }
            
            // 文件状态预览
            PreviewContainer(title: "状态") { showBorder in
                FileStatusContent(showBorder: showBorder)
            }
            .tabItem {
                Label("状态", systemImage: .iconInfo)
            }
        }
    }
}

// MARK: - Preview Contents
private struct FoldersContent: View {
    let showBorder: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    Text("文件夹")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_folder.makeMediaView()
                        .magicBackground(MagicBackground.mint)
                        .magicShowBorder(showBorder)
                }
                
                Group {
                    Text("文件夹（展开）")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_folder.makeMediaView()
                        .magicBackground(MagicBackground.aurora)
                        .magicShowFolderContent()
                        .magicShowBorder(showBorder)
                }
            }
            .padding()
        }
    }
}

private struct ShapesContent: View {
    let showBorder: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    Text("默认形状")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.mint)
                        .magicShowBorder(showBorder)
                }
                
                Group {
                    Text("圆角矩形（圆角8）")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.aurora)
                        .magicShape(.roundedRectangle(cornerRadius: 8))
                        .magicShowBorder(showBorder)
                }
                
                Group {
                    Text("圆角矩形（圆角16）")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.sunset)
                        .magicShape(.roundedRectangle(cornerRadius: 16))
                        .magicShowBorder(showBorder)
                }
            }
            .padding()
        }
    }
}

private struct AvatarShapesContent: View {
    let showBorder: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    Text("默认尺寸(40x40) + 圆形 + 红色背景")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.mint)
                        .magicCircleAvatar()
                        .magicAvatarBackground(.red.opacity(0.1))
                        .magicShowBorder(showBorder)
                }
                
                Group {
                    Text("小尺寸(32x32) + 圆角矩形(8) + 绿色背景")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.aurora.opacity(0.1))
                        .magicAvatarSize(.small)
                        .magicRoundedAvatar(8)
                        .magicAvatarBackground(.green.opacity(0.1))
                        .magicShowBorder(showBorder)
                }
                
                Group {
                    Text("大尺寸(64x64) + 矩形 + 紫色背景")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.sunset)
                        .magicAvatarSize(.large)
                        .magicRectangleAvatar()
                        .magicAvatarBackground(.purple.opacity(0.1))
                        .magicShowBorder(showBorder)
                }
                
                Group {
                    Text("自定义尺寸(80x60) + 圆角矩形(16) + 黄色背景")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.ocean)
                        .magicAvatarSize(width: 80, height: 60)
                        .magicShape(.roundedRectangle(cornerRadius: 16))
                        .magicAvatarShape(.circle)
                        .magicAvatarBackground(.yellow.opacity(0.1))
                        .magicShowBorder(showBorder)
                }
            }
            .padding()
        }
    }
}

private struct RemoteFilesContent: View {
    let showBorder: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    Text("远程图片（默认显示下载按钮）")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.mint)
                        .magicShowBorder(showBorder)
                }
                
                Group {
                    Text("远程图片（隐藏下载按钮）")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.sunset)
                        .magicShowDownloadButton(false)
                        .magicShowBorder(showBorder)
                }
                
                Group {
                    Text("远程音频（默认显示下载按钮）")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_mp3_kennedy.makeMediaView()
                        .magicBackground(MagicBackground.aurora)
                        .magicShowBorder(showBorder)
                }
                
                Group {
                    Text("远程音频（隐藏下载按钮）")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_mp3_kennedy.makeMediaView()
                        .magicBackground(MagicBackground.ocean)
                        .magicShowDownloadButton(false)
                        .magicShowBorder(showBorder)
                }
            }
            .padding()
        }
    }
}

private struct LocalFilesContent: View {
    let showBorder: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    Text("本地图片")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_jpg.makeMediaView()
                        .magicBackground(MagicBackground.mint)
                        .magicShowBorder(showBorder)
                }
                
                Group {
                    Text("本地音频")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_mp3.makeMediaView()
                        .magicBackground(MagicBackground.aurora)
                        .magicShowBorder(showBorder)
                }
            }
            .padding()
        }
    }
}

private struct PaddingContent: View {
    let showBorder: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    Text("默认内边距 (水平16, 垂直12)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.mint)
                        .magicShowBorder(showBorder)
                }
                
                Group {
                    Text("无内边距 (水平0, 垂直0)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.mint)
                        .magicPadding(horizontal: 0, vertical: 0)
                        .magicShowBorder(showBorder)
                }
                
                Group {
                    Text("自定义垂直内边距 (水平16, 垂直24)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.aurora)
                        .magicVerticalPadding(24)
                        .magicShowBorder(showBorder)
                }
                
                Group {
                    Text("自定义水平内边距 (水平32, 垂直12)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.sunset)
                        .magicHorizontalPadding(32)
                        .magicShowBorder(showBorder)
                }
                
                Group {
                    Text("自定义水平和垂直内边距 (水平32, 垂直24)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.ocean)
                        .magicPadding(horizontal: 32, vertical: 24)
                        .magicShowBorder(showBorder)
                }
            }
            .padding()
        }
    }
}

// MARK: - File Status Preview
private struct FileStatusContent: View {
    let showBorder: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    Text("默认显示文件状态")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.mint.opacity(0.1))
                        .magicShowBorder(showBorder)
                }
                
                Group {
                    Text("隐藏文件状态")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_web_jpg_earth.makeMediaView()
                        .magicBackground(MagicBackground.aurora.opacity(0.1))
                        .magicHideFileStatus()
                        .magicShowBorder(showBorder)
                }
                
                Group {
                    Text("本地文件（默认显示状态）")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_jpg.makeMediaView()
                        .magicBackground(MagicBackground.sunset.opacity(0.1))
                        .magicShowBorder(showBorder)
                }
                
                Group {
                    Text("本地文件（隐藏状态）")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    URL.sample_temp_jpg.makeMediaView()
                        .magicBackground(MagicBackground.ocean.opacity(0.1))
                        .magicHideFileStatus()
                        .magicShowBorder(showBorder)
                }
            }
            .padding()
        }
    }
}

#Preview("Media View") {
    MagicThemePreview {
        MediaViewPreviewContainer()
    }
}
