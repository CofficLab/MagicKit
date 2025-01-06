import SwiftUI
import MagicUI

struct DownloadButtonView: View {
    let url: URL
    let size: CGFloat
    let showLabel: Bool
    let shape: MagicButton.Shape
    let destination: URL?
    
    @State private var isDownloading = false
    @State private var progress: Double = 0
    @State private var error: Error?
    
    private var buttonIcon: String {
        if isDownloading {
            return .iconStop
        } else if url.isDownloaded {
            return .iconCheckmark
        } else if url.isiCloud {
            return .iconICloudDownloadAlt
        } else {
            return .iconDownload
        }
    }
    
    private var buttonStyle: MagicButton.Style {
        if isDownloading || url.isDownloaded {
            return .primary
        } else {
            return .secondary
        }
    }
    
    private var buttonLabel: String {
        if isDownloading {
            return "下载中..."
        } else if url.isDownloaded {
            return "已下载"
        } else if url.isiCloud {
            return "从 iCloud 下载"
        } else {
            return "下载"
        }
    }
    
    private var buttonDisabled: Bool {
        url.isDownloaded || (error != nil)
    }
    
    var body: some View {
        VStack {
            MagicButton(
                icon: buttonIcon,
                title: showLabel ? buttonLabel : nil,
                style: buttonStyle,
                size: size <= 32 ? .small : (size <= 40 ? .regular : .large),
                shape: shape,
                disabledReason: buttonDisabled ? buttonLabel : nil,
                action: handleButtonTap
            )
            .symbolEffect(.bounce, value: url.isDownloaded)
            
            if isDownloading {
                ProgressView(value: progress, total: 100)
                    .progressViewStyle(.circular)
                    .frame(width: size, height: size)
            }
            
            if let error = error {
                Text(error.localizedDescription)
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .frame(maxWidth: 200)
                    .multilineTextAlignment(.center)
            }
        }
        .animation(.smooth, value: isDownloading)
        .animation(.smooth, value: error != nil)
    }
    
    private func handleButtonTap() {
        if isDownloading {
            // TODO: 实现取消下载
            return
        }
        
        Task {
            isDownloading = true
            error = nil
            progress = 0
            
            do {
                if let destination = destination {
                    try await url.copyTo(destination) { newProgress in
                        progress = newProgress
                    }
                } else {
                    try await url.download { newProgress in
                        progress = newProgress
                    }
                }
            } catch {
                self.error = error
            }
            
            isDownloading = false
        }
    }
}

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
        self.url = url
        self.size = size
        self.showLabel = showLabel
        self.shape = shape
        self.destination = destination
        
        // 设置初始状态
        switch initialState {
        case .normal:
            _isDownloading = State(initialValue: false)
            _progress = State(initialValue: 0)
            _error = State(initialValue: nil)
        case .downloading:
            _isDownloading = State(initialValue: true)
            _progress = State(initialValue: 45)
            _error = State(initialValue: nil)
        case .downloaded:
            _isDownloading = State(initialValue: false)
            _progress = State(initialValue: 100)
            _error = State(initialValue: nil)
        case .error(let error):
            _isDownloading = State(initialValue: false)
            _progress = State(initialValue: 0)
            _error = State(initialValue: error)
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
