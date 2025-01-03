import AVKit
import SwiftUI
import MagicUI

// MARK: - Media View Style
public enum MediaViewStyle {
    case none
    case background(AnyView)
}

// MARK: - Background Modifier
struct MediaViewBackground: ViewModifier {
    let style: MediaViewStyle
    
    func body(content: Content) -> some View {
        Group {
            switch style {
            case .none:
                content
            case .background(let background):
                content
                    .background(background)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - Error Message View
private struct ErrorMessageView: View {
    let error: Error
    @State private var isHovering = false
    
    var body: some View {
        Text(error.localizedDescription)
            .font(.caption)
            .foregroundStyle(.red)
            .lineLimit(1)
            .opacity(isHovering ? 0 : 1)
            .overlay {
                if isHovering {
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovering = hovering
                }
            }
    }
}

// MARK: - Action Buttons View
private struct ActionButtonsView: View {
    let url: URL
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            url.makeOpenButton()
        }
        .padding(.trailing, 8)
    }
}

public struct MediaFileView: View {
    let url: URL
    let size: String
    fileprivate var style: MediaViewStyle = .none
    fileprivate var showActions: Bool = true
    @State private var thumbnail: Image?
    @State private var error: Error?
    @State private var isLoading = false
    @State private var isHovering = false
    
    public init(url: URL, size: String) {
        self.url = url
        self.size = size
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // 左侧圆形图片
            Group {
                if let thumbnail = thumbnail {
                    thumbnail
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else if error != nil {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 24))
                        .foregroundStyle(.red)
                } else {
                    Image(systemName: "doc")
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 40, height: 40)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .overlay {
                if let error = error {
                    Circle()
                        .stroke(.red, lineWidth: 2)
                }
            }
            
            // 右侧文件信息
            VStack(alignment: .leading, spacing: 4) {
                Text(url.lastPathComponent)
                    .font(.headline)
                    .lineLimit(1)
                
                if let error = error {
                    ErrorMessageView(error: error)
                } else {
                    Text(size)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // 操作按钮
            if showActions {
                ActionButtonsView(url: url)
                    .opacity(isHovering ? 1 : 0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .modifier(MediaViewBackground(style: style))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .task {
            // 异步加载缩略图
            if thumbnail == nil && !isLoading {
                isLoading = true
                do {
                    thumbnail = try await url.thumbnail(size: CGSize(width: 80, height: 80))
                    error = nil
                } catch {
                    self.error = error
                }
                isLoading = false
            }
        }
    }
    
    public func noBackground() -> MediaFileView {
        var view = self
        view.style = .none
        return view
    }
    
    public func withBackground<Background: View>(_ background: Background) -> MediaFileView {
        var view = self
        view.style = .background(AnyView(background))
        return view
    }
    
    public func hideActions() -> MediaFileView {
        var view = self
        view.showActions = false
        return view
    }
}

public extension URL {
    func makeMediaView() -> MediaFileView {
        MediaFileView(url: self, size: self.getSizeReadable())
    }
}

#Preview("Media View") {
    VStack(spacing: 20) {
        // 音频文件预览
        URL.sample_mp3_kennedy.makeMediaView()
            .withBackground(MagicBackground.mint)
        
        // 视频文件预览
        URL.sample_mp4_bunny.makeMediaView()
            .noBackground()
        
        // 图片文件预览
        URL.sample_jpg_earth.makeMediaView()
            .withBackground(MagicBackground.aurora)
        
        // PDF文件预览
        URL.sample_pdf_swift_guide.makeMediaView()
            .withBackground(MagicBackground.cosmicDust)
        
        // 文本文件预览
        URL.sample_txt_mit.makeMediaView()
            .noBackground()
    }
    .padding()
    .background(MagicBackground.mysticalForest)
}

#Preview("Media View - Remote Files") {
    VStack(spacing: 20) {
        // 音频文件预览
        URL.sample_mp3_kennedy.makeMediaView()
            .withBackground(MagicBackground.mint)
        
        // 视频文件预览
        URL.sample_mp4_bunny.makeMediaView()
            .noBackground()
        
        // 图片文件预览
        URL.sample_jpg_earth.makeMediaView()
            .withBackground(MagicBackground.aurora)
        
        // PDF文件预览
        URL.sample_pdf_swift_guide.makeMediaView()
            .withBackground(MagicBackground.cosmicDust)
        
        // 文本文件预览
        URL.sample_txt_mit.makeMediaView()
            .noBackground()
    }
    .padding()
    .background(MagicBackground.mysticalForest)
}

#Preview("Media View - Local Files") {
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
    .frame(width: 400, height: 600)
    .background(MagicBackground.nebulaMist)
}
