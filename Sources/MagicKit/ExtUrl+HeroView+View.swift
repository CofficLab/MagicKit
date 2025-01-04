import Foundation
import Combine
import SwiftUI

// MARK: - Hero View
/// 用于显示文件缩略图的视图组件
///
/// 这个视图组件可以显示文件的缩略图，支持以下特性：
/// - 自动生成文件缩略图
/// - 错误状态展示
/// - 可自定义缩略图形状
/// - 支持 iCloud 文件下载进度监听
/// - 支持手动控制下载进度
///
/// 基本用法：
/// ```swift
/// // 基本使用
/// let url = URL(fileURLWithPath: "path/to/file")
/// HeroView(url: url)
///
/// // 自定义样式
/// HeroView(url: url)
///     .shape(.roundedRectangle(cornerRadius: 8))
/// ```
///
/// 下载进度显示：
/// ```swift
/// // 自动监听 iCloud 文件下载进度
/// HeroView(url: url)
///
/// // 手动控制下载进度
/// struct DownloadView: View {
///     @State private var progress: Double = 0.0
///
///     var body: some View {
///         VStack {
///             HeroView(url: url)
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
public struct HeroView: View {
    let url: URL
    var shape: MediaViewShape = .circle
    var monitorDownload: Bool = true
    var progressBinding: Binding<Double>? = nil
    @State private var thumbnail: Image?
    @State private var error: Error?
    @State private var isLoading = false
    @State private var autoDownloadProgress: Double = 0
    @State private var cancellable: AnyCancellable?
    
    /// 当前的下载进度
    private var downloadProgress: Double {
        progressBinding?.wrappedValue ?? autoDownloadProgress
    }
    
    /// 是否正在下载
    private var isDownloading: Bool {
        (progressBinding != nil && progressBinding!.wrappedValue < 1) || (downloadProgress > 0 && downloadProgress < 1)
    }
    
    /// 创建缩略图视图
    /// - Parameter url: 文件的 URL
    public init(url: URL) {
        self.url = url
    }
    
    public var body: some View {
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
        .onChange(of: downloadProgress) {
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
}

// MARK: - Hero View Modifiers
public extension HeroView {
    /// 设置缩略图形状
    /// - Parameter shape: 要应用的形状
    /// - Returns: 使用指定形状的视图
    func shape(_ shape: MediaViewShape) -> HeroView {
        var view = self
        view.shape = shape
        return view
    }
    
    /// 设置下载进度监听状态
    /// - Parameter monitorDownload: 是否监听下载进度
    /// - Returns: 配置了下载监听的视图
    func apply(monitorDownload: Bool) -> HeroView {
        var view = self
        view.monitorDownload = monitorDownload
        return view
    }
    
    /// 设置下载进度绑定
    /// - Parameter progressBinding: 下载进度的绑定（可选）
    /// - Returns: 配置了下载进度的视图
    func apply(progressBinding: Binding<Double>?) -> HeroView {
        var view = self
        view.progressBinding = progressBinding
        return view
    }
    
    /// 禁用或启用下载进度监听
    /// 
    /// 当启用时，视图会自动监听 iCloud 文件的下载进度。
    /// 当禁用时，你可以通过 `downloadProgress` 修改器手动控制进度显示。
    ///
    /// - Returns: 配置了下载监听的视图
    func disableDownloadMonitor() -> HeroView {
        var view = self
        view.monitorDownload = false
        return view
    }
    
    /// 设置下载进度
    /// 
    /// 这个修改器允许你通过一个 `Binding<Double>` 来控制下载进度的显示。
    /// 进度值应该在 0.0（未开始）到 1.0（完成）之间。
    ///
    /// - Parameter progress: 下载进度的绑定（0.0 到 1.0）
    /// - Returns: 使用指定下载进度的视图
    func downloadProgress(_ progress: Binding<Double>) -> HeroView {
        var view = self
        view.progressBinding = progress
        return view
    }
}

#Preview("Hero") {
    HeroViewPreviewContainer()
}
