import SwiftUI
import MagicUI

// MARK: - Preview Helpers
extension DownloadButtonView {
    enum PreviewState {
        case normal
        case downloading
        case downloaded
        case error(Error)
    }
    
    init(
        url: URL,
        size: CGFloat,
        showLabel: Bool,
        shape: MagicButton.Shape = .circle,
        destination: URL?,
        initialState: PreviewState
    ) {
        switch initialState {
        case .normal:
            self.init(
                url: url,
                size: size,
                showLabel: showLabel,
                shape: shape,
                destination: destination,
                isDownloading: false,
                progress: 0,
                error: nil
            )
        case .downloading:
            self.init(
                url: url,
                size: size,
                showLabel: showLabel,
                shape: shape,
                destination: destination,
                isDownloading: true,
                progress: 45,
                error: nil
            )
        case .downloaded:
            self.init(
                url: url,
                size: size,
                showLabel: showLabel,
                shape: shape,
                destination: destination,
                isDownloading: false,
                progress: 100,
                error: nil
            )
        case .error(let error):
            self.init(
                url: url,
                size: size,
                showLabel: showLabel,
                shape: shape,
                destination: destination,
                isDownloading: false,
                progress: 0,
                error: error
            )
        }
    }
}

// MARK: - Preview
#Preview("Download Buttons") {
    TabView {
        // 基本用法
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
        .tabItem {
            Image(systemName: "1.circle.fill")
            Text("基本")
        }
        
        // 不同形状
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
        .tabItem {
            Image(systemName: "2.circle.fill")
            Text("形状")
        }
        
        // 不同类型文件
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
        .tabItem {
            Image(systemName: "3.circle.fill")
            Text("类型")
        }
        
        // 下载状态
        MagicThemePreview {
            VStack(spacing: 20) {
                Group {
                    Text("未下载").font(.headline)
                    URL.sample_web_mp3_kennedy.makeDownloadButton(showLabel: true)
                }
                
                Group {
                    Text("下载中").font(.headline)
                    DownloadButtonView(
                        url: .sample_web_mp3_kennedy,
                        size: 28,
                        showLabel: true,
                        shape: .roundedSquare,
                        destination: nil,
                        initialState: .downloading
                    )
                }
                
                Group {
                    Text("已下载").font(.headline)
                    DownloadButtonView(
                        url: .sample_web_mp3_kennedy,
                        size: 28,
                        showLabel: true,
                        shape: .roundedSquare,
                        destination: nil,
                        initialState: .downloaded
                    )
                }
                
                Group {
                    Text("错误状态").font(.headline)
                    DownloadButtonView(
                        url: .sample_web_mp3_kennedy,
                        size: 28,
                        showLabel: true,
                        shape: .roundedSquare,
                        destination: nil,
                        initialState: .error(NSError(domain: "Preview", code: -1, userInfo: [NSLocalizedDescriptionKey: "下载失败"]))
                    )
                }
            }
            .padding()
        }
        .tabItem {
            Image(systemName: "4.circle.fill")
            Text("状态")
        }
    }
} 