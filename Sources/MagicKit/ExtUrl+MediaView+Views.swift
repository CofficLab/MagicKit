import SwiftUI
import Combine

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
/// - 支持 iCloud 文件下载进度监听
/// - 支持手动控制下载进度
/// - 支持文件夹内容展示
///
/// 基本用法：
/// ```swift
/// // 基本使用
/// let url = URL(fileURLWithPath: "path/to/file")
/// url.makeMediaView()
///
/// // 自定义样式
/// url.makeMediaView()
///     .withBackground(MagicBackground.mint)
///     .thumbnailShape(.roundedRectangle(cornerRadius: 8))
///     .verticalPadding(16)
/// ```
///
/// 下载进度显示：
/// ```swift
/// // 自动监听 iCloud 文件下载进度
/// url.makeMediaView()
///
/// // 手动控制下载进度
/// struct DownloadView: View {
///     @State private var progress: Double = 0.0
///
///     var body: some View {
///         VStack {
///             url.makeMediaView()
///                 .downloadProgress($progress)
///
///             Button("开始下载") {
///                 withAnimation {
///                     progress = 1.0
///                 }
///             }
///         }
///     }
/// }
/// ```
///
/// 文件夹内容展示：
/// ```swift
/// // 显示文件夹内容
/// folderURL.makeMediaView()
///     .showFolderContent()
///     .withBackground(MagicBackground.mint)
/// ```
public struct MediaFileView: View {
    let url: URL
    let size: String
    var style: MediaViewStyle = .none
    var showActions: Bool = true
    var shape: MediaViewShape = .circle
    var verticalPadding: CGFloat = 12
    var monitorDownload: Bool = true
    var folderContentVisible: Bool = false
    var progressBinding: Binding<Double>? = nil
    @State private var thumbnail: Image?
    @State private var error: Error?
    @State private var isLoading = false
    @State private var isHovering = false
    @State private var autoDownloadProgress: Double = 0
    @State private var itemQuery: ItemQuery?
    @State private var cancellable: AnyCancellable?
    
    /// 当前的下载进度
    private var downloadProgress: Double {
        progressBinding?.wrappedValue ?? autoDownloadProgress
    }
    
    /// 是否正在下载
    private var isDownloading: Bool {
        progressBinding != nil || (downloadProgress > 0 && downloadProgress < 1)
    }
    
    /// 创建媒体文件视图
    /// - Parameters:
    ///   - url: 文件的 URL
    ///   - size: 文件大小的字符串表示
    public init(url: URL, size: String) {
        self.url = url
        self.size = size
    }
    
    public var body: some View {
        mainContent
            .modifier(FolderContentModifier(url: url, isVisible: folderContentVisible))
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
                if monitorDownload && url.isiCloud && progressBinding == nil {
                    let downloadingCancellable = url.onDownloading { progress in
                        autoDownloadProgress = progress
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
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                // 左侧图片区域
                Group {
                    if isDownloading {
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
    }
}


// MARK: - Error Message View
struct ErrorMessageView: View {
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
struct ActionButtonsView: View {
    let url: URL
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            url.makeOpenButton()
        }
        .padding(.trailing, 8)
    }
} 
