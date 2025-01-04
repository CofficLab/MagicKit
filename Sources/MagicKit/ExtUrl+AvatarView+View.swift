import SwiftUI
import Combine

// MARK: - Avatar View
/// 一个用于展示文件缩略图的头像视图组件
///
/// `AvatarView` 是一个多功能的视图组件，专门用于展示文件的缩略图和状态。
/// 它支持多种文件类型，包括图片、视频、音频等，并能自动处理不同的显示状态。
///
/// # 功能特性
/// - 自动生成文件缩略图
/// - 支持多种文件类型
/// - 实时显示下载进度
/// - 错误状态可视化
/// - 可自定义外观
///
/// # 示例代码
/// ```swift
/// // 基础用法
/// AvatarView(url: fileURL)
///
/// // 自定义形状
/// AvatarView(url: fileURL)
///     .magicShape(.roundedRectangle(cornerRadius: 8))
///
/// // 下载进度控制
/// @State var progress: Double = 0
/// AvatarView(url: fileURL)
///     .magicDownloadProgress($progress)
/// ```
public struct AvatarView: View {
    // MARK: - Properties
    
    /// 文件的URL
    let url: URL
    
    /// 视图的形状
    var shape: AvatarViewShape = .circle
    
    /// 是否监控下载进度
    var monitorDownload: Bool = true
    
    /// 下载进度绑定
    var progressBinding: Binding<Double>? = nil
    
    /// 视图尺寸
    var size: CGSize = CGSize(width: 40, height: 40)
    
    // MARK: - State Properties
    
    /// 缩略图
    @State private var thumbnail: Image?
    
    /// 错误状态
    @State private var error: Error?
    
    /// 加载状态
    @State private var isLoading = false
    
    /// 自动下载进度
    @State private var autoDownloadProgress: Double = 0
    
    /// 取消订阅存储
    @State private var cancellable: AnyCancellable?
    
    // MARK: - Computed Properties
    
    /// 当前的下载进度
    private var downloadProgress: Double {
        progressBinding?.wrappedValue ?? autoDownloadProgress
    }
    
    /// 是否正在下载
    private var isDownloading: Bool {
        // 检查手动控制的进度
        if let binding = progressBinding {
            if binding.wrappedValue < 1 {
                return true
            }
        }
        
        // 检查自动监控的进度
        if downloadProgress > 0 && downloadProgress < 1 {
            return true
        }
        
        return false
    }
    
    // MARK: - Initialization
    
    /// 创建一个新的头像视图
    /// - Parameters:
    ///   - url: 要显示的文件URL
    ///   - size: 视图的尺寸，默认为 40x40
    public init(url: URL, size: CGSize = CGSize(width: 40, height: 40)) {
        self.url = url
        self.size = size
    }
    
    // MARK: - Body
    
    public var body: some View {
        Group {
            if isDownloading {
                DownloadProgressView(progress: downloadProgress, size: size)
            } else if let thumbnail = thumbnail {
                ThumbnailImageView(image: thumbnail, size: size)
            } else if error != nil {
                ErrorIndicatorView(size: size)
            } else if isLoading {
                LoadingView(size: size)
            } else {
                DefaultIconView(icon: url.systemIcon, size: size)
            }
        }
        .frame(width: size.width, height: size.height)
        .background(.blue.opacity(0.1))
        .clipShape(shape)
        .overlay {
            if error != nil {
                shape.strokeBorder()
            }
        }
    }
    
    // MARK: - Private Views
    
    /// 下载进度视图
    private struct DownloadProgressView: View {
        let progress: Double
        let size: CGSize

        var body: some View {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 4)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.accentColor, style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round
                    ))
                    .rotationEffect(.degrees(-90))

                Text("\(Int(progress * 100))%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: size.width, height: size.height)
        }
    }

    /// 缩略图显示视图
    private struct ThumbnailImageView: View {
        let image: Image
        let size: CGSize

        var body: some View {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
        }
    }

    /// 加载中视图
    private struct LoadingView: View {
        let size: CGSize
        
        var body: some View {
            ProgressView()
                .controlSize(.small)
                .frame(width: size.width, height: size.height)
        }
    }

    /// 错误指示视图
    private struct ErrorIndicatorView: View {
        let size: CGSize
        
        var body: some View {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: min(size.width, size.height) * 0.5))
                .foregroundStyle(.red)
                .frame(width: size.width, height: size.height)
        }
    }

    /// 默认图标视图
    private struct DefaultIconView: View {
        let icon: String
        let size: CGSize

        var body: some View {
            Image(systemName: icon)
                .font(.system(size: min(size.width, size.height) * 0.5))
                .foregroundStyle(.secondary)
                .frame(width: size.width, height: size.height)
        }
    }
    
    // MARK: - Private Methods
    
    /// 处理下载进度变化
    private func handleDownloadProgress() {
        Task {
            do {
                thumbnail = try await url.thumbnail(size: size)
                error = nil
            } catch {
                self.error = error
            }
        }
    }
    
    /// 加载缩略图
    @Sendable private func loadThumbnail() async {
        guard thumbnail == nil && !isLoading && !url.isDownloading else { return }

        isLoading = true
        do {
            thumbnail = try await url.thumbnail(size: size)
            error = nil
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    /// 设置下载监控
    @Sendable private func setupDownloadMonitor() async {
        guard monitorDownload && url.isiCloud && progressBinding == nil else { return }

        let downloadingCancellable = url.onDownloading { progress in
            autoDownloadProgress = progress
        }

        let finishedCancellable = url.onDownloadFinished {
            Task {
                await loadThumbnail()
            }
        }

        cancellable = AnyCancellable {
            downloadingCancellable.cancel()
            finishedCancellable.cancel()
        }
    }
}

// MARK: - Preview
#Preview("头像视图") {
    AvatarViewPreviewContainer()
}
