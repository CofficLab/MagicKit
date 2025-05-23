import SwiftUI


struct DownloadButtonPreview: View {
    var body: some View {
        TabView {
            // 基本用法
            basicPreview
                .tabItem {
                    Image(systemName: "1.circle.fill")
                    Text("基本")
                }
            
            // 不同形状
            shapesPreview
                .tabItem {
                    Image(systemName: "2.circle.fill")
                    Text("形状")
                }
            
            // 不同类型文件
            fileTypesPreview
                .tabItem {
                    Image(systemName: "3.circle.fill")
                    Text("类型")
                }
            
            // 下载状态
            statesPreview
                .tabItem {
                    Image(systemName: "4.circle.fill")
                    Text("状态")
                }
        }
    }
    
    private var basicPreview: some View {
        MagicThemePreview {
            VStack(spacing: 20) {
                Group {
                    Text("基本按钮").font(.headline)
                    URL.sample_web_mp3_kennedy.makeDownloadButton()
                }
                
                Group {
                    Text("带标签").font(.headline)
                    URL.sample_web_mp3_kennedy.makeDownloadButton(showLabel: true)
                }
                
                Group {
                    Text("大尺寸").font(.headline)
                    URL.sample_web_mp3_kennedy.makeDownloadButton(size: 40)
                }
            }
            .padding()
        }
    }
    
    private var shapesPreview: some View {
        MagicThemePreview {
            VStack(spacing: 20) {
                Group {
                    Text("圆形").font(.headline)
                    URL.sample_web_mp3_kennedy.makeDownloadButton(shape: .circle)
                    URL.sample_web_mp3_kennedy.makeDownloadButton(showLabel: true, shape: .circle)
                }
                
                Divider()
                
                Group {
                    Text("圆角正方形").font(.headline)
                    URL.sample_web_mp3_kennedy.makeDownloadButton(shape: .roundedSquare)
                    URL.sample_web_mp3_kennedy.makeDownloadButton(showLabel: true, shape: .roundedSquare)
                }
                
                Divider()
                
                Group {
                    Text("胶囊形").font(.headline)
                    URL.sample_web_mp3_kennedy.makeDownloadButton(shape: .capsule)
                    URL.sample_web_mp3_kennedy.makeDownloadButton(showLabel: true, shape: .capsule)
                }
                
                Divider()
                
                Group {
                    Text("圆角矩形").font(.headline)
                    URL.sample_web_mp3_kennedy.makeDownloadButton(shape: .roundedRectangle)
                    URL.sample_web_mp3_kennedy.makeDownloadButton(showLabel: true, shape: .roundedRectangle)
                }
            }
            .padding()
        }
    }
    
    private var fileTypesPreview: some View {
        MagicThemePreview {
            VStack(spacing: 20) {
                Group {
                    Text("iCloud 文件").font(.headline)
                    URL(string: "file:///iCloud/test.pdf")!.makeDownloadButton()
                    URL(string: "file:///iCloud/test.pdf")!.makeDownloadButton(showLabel: true)
                }
                
                Divider()
                
                Group {
                    Text("网络文件").font(.headline)
                    URL.sample_web_mp3_kennedy.makeDownloadButton()
                    URL.sample_web_mp3_kennedy.makeDownloadButton(showLabel: true)
                }
                
                Divider()
                
                Group {
                    Text("本地文件").font(.headline)
                    URL.documentsDirectory.appendingPathComponent("test.txt")
                        .makeDownloadButton()
                    URL.documentsDirectory.appendingPathComponent("test.txt")
                        .makeDownloadButton(showLabel: true)
                }
            }
            .padding()
        }
    }
    
    private var statesPreview: some View {
        MagicThemePreview {
            VStack(spacing: 20) {
                Group {
                    Text("未下载").font(.headline)
                    URL.sample_web_mp3_kennedy.makeDownloadButton(showLabel: true)
                }
            }
            .padding()
        }
    }
}

#Preview {
    DownloadButtonPreview()
} 
