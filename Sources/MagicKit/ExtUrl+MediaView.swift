import AVKit
import SwiftUI
import MagicUI
import Combine

// MARK: - Media View Style
/// 媒体视图的背景样式
public enum MediaViewStyle {
    /// 无背景
    case none
    /// 自定义背景视图
    case background(AnyView)
}

// MARK: - Media View Shape
/// 媒体视图左侧缩略图的形状
public enum MediaViewShape {
    /// 圆形
    case circle
    /// 圆角矩形，可指定圆角半径
    case roundedRectangle(cornerRadius: CGFloat = 8)
    /// 矩形
    case rectangle
    
    @ViewBuilder
    func apply<V: View>(to view: V) -> some View {
        switch self {
        case .circle:
            view.clipShape(Circle())
        case .roundedRectangle(let radius):
            view.clipShape(RoundedRectangle(cornerRadius: radius))
        case .rectangle:
            view
        }
    }
    
    @ViewBuilder
    func strokeShape() -> some View {
        switch self {
        case .circle:
            Circle().stroke(Color.red, lineWidth: 2)
        case .roundedRectangle(let radius):
            RoundedRectangle(cornerRadius: radius).stroke(Color.red, lineWidth: 2)
        case .rectangle:
            Rectangle().stroke(Color.red, lineWidth: 2)
        }
    }
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

// MARK: - Folder Content View
struct FolderContentView: View {
    let url: URL
    
    var body: some View {
        if let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
            List(contents, id: \.path) { itemURL in
                itemURL.makeMediaView()
            }
        } else {
            Text("无法读取文件夹内容")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Media File View
/// 用于显示文件信息的视图组件
/// 
/// 这个视图组件可以显示文件的缩略图、名称、大小等信息，并提供文件操作功能。
/// 支持以下特性：
/// - 自动生成文件缩略图
/// - 显示文件大小
/// - 错误状态展示
/// - 悬停时显示操作按钮
/// - 可自定义背景样式
/// - 可自定义缩略图形状
/// - 可调整垂直内边距
///
/// 基本用法：
/// ```swift
/// let url = URL(fileURLWithPath: "path/to/file")
/// url.makeMediaView()
/// ```
///
/// 自定义样式：
/// ```swift
/// url.makeMediaView()
///     .withBackground(MagicBackground.mint)
///     .thumbnailShape(.roundedRectangle(cornerRadius: 8))
///     .verticalPadding(16)
/// ```
public struct MediaFileView: View {
    let url: URL
    let size: String
    var style: MediaViewStyle = .none
    var showActions: Bool = true
    var shape: MediaViewShape = .circle
    var verticalPadding: CGFloat = 12
    var monitorDownload: Bool = true
    @State private var thumbnail: Image?
    @State private var error: Error?
    @State private var isLoading = false
    @State private var isHovering = false
    @State private var downloadProgress: Double = 0
    @State private var itemQuery: ItemQuery?
    @State private var cancellable: AnyCancellable?
    
    /// 创建媒体文件视图
    /// - Parameters:
    ///   - url: 文件的 URL
    ///   - size: 文件大小的字符串表示
    public init(url: URL, size: String) {
        self.url = url
        self.size = size
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                // 左侧图片区域
                Group {
                    if url.isDownloading || (downloadProgress > 0 && downloadProgress < 1) {
                        // 显示下载进度
                        ZStack {
                            Circle()
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 4)
                            
                            Circle()
                                .trim(from: 0, to: downloadProgress)
                                .stroke(Color.accentColor, style: StrokeStyle(
                                    lineWidth: 4,
                                    lineCap: .round
                                ))
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(Int(downloadProgress * 100))%")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    } else if let thumbnail = thumbnail {
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
                        Image(systemName: url.icon)
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial)
                .apply(shape: shape)
                .overlay {
                    if error != nil {
                        shape.strokeShape()
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
            .padding(.vertical, verticalPadding)
        }
        .modifier(MediaViewBackground(style: style))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .task {
            // 只加载缩略图，不主动下载
            if thumbnail == nil && !isLoading && !url.isDownloading {
                isLoading = true
                do {
                    thumbnail = try await url.thumbnail(size: CGSize(width: 80, height: 80))
                    error = nil
                } catch {
                    self.error = error
                }
                isLoading = false
            }
            
            // 如果启用了监听且是 iCloud 文件，监听下载进度和完成事件
            if monitorDownload && url.isiCloud {
                let downloadingCancellable = url.onDownloading { progress in
                    downloadProgress = progress
                }
                
                let finishedCancellable = url.onDownloadFinished {
                    // 下载完成后重新获取缩略图
                    Task {
                        do {
                            thumbnail = try await url.thumbnail(size: CGSize(width: 80, height: 80))
                            error = nil
                        } catch {
                            self.error = error
                        }
                    }
                }
                
                // 组合两个订阅
                cancellable = AnyCancellable {
                    downloadingCancellable.cancel()
                    finishedCancellable.cancel()
                }
            }
        }
        .onDisappear {
            cancellable?.cancel()
        }
    }
}

// MARK: - View Extension
private extension View {
    func apply(shape: MediaViewShape) -> some View {
        shape.apply(to: self)
    }
}

// MARK: - URL Extension
public extension URL {
    /// 为 URL 创建媒体文件视图
    /// - Returns: 展示该 URL 对应文件信息的视图
    ///
    /// 这个方法会自动：
    /// - 获取文件大小
    /// - 生成缩略图（如果是媒体文件）
    /// - 处理错误状态
    ///
    /// 示例：
    /// ```swift
    /// // 基本使用
    /// url.makeMediaView()
    ///
    /// // 带背景
    /// url.makeMediaView()
    ///     .withBackground(MagicBackground.mint)
    ///
    /// // 自定义形状和内边距
    /// url.makeMediaView()
    ///     .thumbnailShape(.roundedRectangle(cornerRadius: 8))
    ///     .verticalPadding(16)
    /// ```
    func makeMediaView() -> MediaFileView {
        MediaFileView(url: self, size: self.getSizeReadable())
    }
}

#Preview("Media View") {
    MediaViewPreviewContainer()
}
