import Combine
import SwiftUI
import OSLog

// MARK: - Media View Style

/// 媒体视图的背景样式
public enum MediaViewStyle {
    /// 无背景
    case none
    /// 自定义背景视图
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
            case let .background(background):
                content
                    .background(background)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
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
public struct MediaFileView: View, SuperLog {
    public static var emoji = "🖥️"
    var verbose: Bool
    let url: URL
    let size: String
    var style: MediaViewStyle = .none
    var showActions: Bool = true
    var shape: AvatarViewShape = .circle
    var avatarShape: AvatarViewShape = .circle
    var avatarBackgroundColor: Color = .blue.opacity(0.1)
    var avatarSize: CGSize = CGSize(width: 40, height: 40)
    var verticalPadding: CGFloat = 12
    var horizontalPadding: CGFloat = 16
    var monitorDownload: Bool = true
    var folderContentVisible: Bool = false
    var avatarProgressBinding: Binding<Double>? = nil
    var showBorder: Bool = false
    var showDownloadButton: Bool = true
    var showFileInfo: Bool = true
    var showFileStatus: Bool = true
    var showFileSize: Bool = true
    @State private var isHovering = false

    /// 创建媒体文件视图
    /// - Parameters:
    ///   - url: 文件的 URL
    public init(url: URL, verbose: Bool) {
        self.url = url
        self.verbose = verbose
        self.size = url.getSizeReadable()
    }

    public var body: some View {
        mainContent
            .modifier(FolderContentModifier(url: url, isVisible: folderContentVisible))
            .modifier(MediaViewBackground(style: style))
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                    .foregroundColor(showBorder ? .red : .clear)
            )
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovering = hovering
                }
            }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                // 左侧缩略图
                let avatarView = url.makeAvatarView(verbose: self.verbose)
                    .magicSize(avatarSize)
                    .magicAvatarShape(avatarShape)
                    .magicBackground(avatarBackgroundColor)
                    .magicDownloadMonitor(monitorDownload)
                
                // 根据是否有进度绑定来决定是否应用进度修改器
                let finalAvatarView = if let progress = avatarProgressBinding {
                    avatarView.magicDownloadProgress(progress)
                } else {
                    avatarView
                }
                
                finalAvatarView
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                            .foregroundColor(showBorder ? .blue : .clear)
                    )
                
                // 右侧文件信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(url.lastPathComponent)
                        .font(.headline)
                        .lineLimit(1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                                .foregroundColor(showBorder ? .green : .clear)
                        )
                    
                    HStack {
                        if showFileSize {
                            Text(size)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                                        .foregroundColor(showBorder ? .green : .clear)
                                )
                        }
                        
                        if showFileStatus, let status = url.magicFileStatus {
                            Text(status)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                                        .foregroundColor(showBorder ? .green : .clear)
                                )
                        }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                        .foregroundColor(showBorder ? .purple : .clear)
                )
                
                Spacer()
                
                // 操作按钮
                if showActions {
                    ActionButtonsView(url: url, showDownloadButton: showDownloadButton)
                        .opacity(isHovering ? 1 : 0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                                .foregroundColor(showBorder ? .orange : .clear)
                        )
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                    .foregroundColor(showBorder ? .yellow : .clear)
            )
            .padding(.horizontal, horizontalPadding)
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
    let showDownloadButton: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            if showDownloadButton && url.isNotDownloaded {
                url.makeDownloadButton()
            }
            url.makeOpenButton()
        }
        .padding(.trailing, 8)
    }
}

#Preview("Media View") {
    MediaViewPreviewContainer()
}
