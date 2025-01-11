import Combine
import os
import SwiftUI
import UniformTypeIdentifiers

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
public struct AvatarView: View, SuperLog {
    // MARK: - Properties

    public static let emoji = "🚉"

    /// 状态管理器
    @StateObject private var state = ViewState()

    /// 下载监控器
    private let downloadMonitor = DownloadMonitor()

    /// 文件的URL
    let url: URL

    let verbose: Bool

    /// 视图的形状
    var shape: AvatarViewShape = .circle

    /// 是否监控下载进度
    var monitorDownload: Bool = true

    /// 下载进度绑定
    var progressBinding: Binding<Double>?

    /// 视图尺寸
    var size: CGSize = CGSize(width: 40, height: 40)

    /// 视图背景色
    var backgroundColor: Color = .blue.opacity(0.1)

    /// 控制文件选择器的显示
    @State private var isImagePickerPresented = false

    /// 控制日志显示
    @State private var showLogSheet = false

    /// 日志记录
    @State private var logs: [MagicLogEntry] = []

    // MARK: - Computed Properties

    /// 当前的下载进度
    private var downloadProgress: Double {
        progressBinding?.wrappedValue ?? state.autoDownloadProgress
    }

    /// 是否正在下载
    private var isDownloading: Bool {
        // 检查手动控制的进度
        if let binding = progressBinding {
            if binding.wrappedValue <= 1 {
                return true
            }
        }

        // 检查自动监控的进度
        if downloadProgress > 0 && downloadProgress <= 1 {
            return true
        }

        return false
    }

    // MARK: - Initialization

    /// 创建一个新的头像视图
    /// - Parameters:
    ///   - url: 要显示的文件URL
    ///   - size: 视图的尺寸，默认为 40x40
    public init(url: URL, size: CGSize = CGSize(width: 40, height: 40), verbose: Bool = false) {
        self.url = url
        self.size = size
        self.verbose = verbose

        // 在初始化时进行基本的 URL 检查
        if url.isFileURL {
            // 检查本地文件是否存在
            if url.isNotFileExist {
                os_log("\(Self.t)文件不存在: \(url.path)")
                _state = StateObject(wrappedValue: ViewState())
                state.setError(ViewError.fileNotFound)
            }
        } else {
            // 检查 URL 格式
            guard url.isNetworkURL else {
                os_log("\(Self.t)无效的 URL: \(url)")
                _state = StateObject(wrappedValue: ViewState())
                state.setError(ViewError.invalidURL)
                return
            }
        }
    }

    // MARK: - Private Methods

    private func addLog(_ message: String, level: MagicLogEntry.Level = .info) {
        logs.append(MagicLogEntry(message: message, level: level))
    }

    // MARK: - Body

    public var body: some View {
        Group {
            if isDownloading && downloadProgress < 1{
                DownloadProgressView(progress: downloadProgress)
            } else if let thumbnail = state.thumbnail {
                ThumbnailImageView(image: thumbnail)
            } else if let error = state.error {
                ErrorIndicatorView(error: error)
            } else if state.isLoading {
                ProgressView()
                    .controlSize(.small)
            } else {
                url.defaultImage
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size.width, height: size.height)
        .background(backgroundColor)
        .clipShape(shape)
        .overlay {
            if state.error != nil {
                shape.strokeBorder(color: Color.red.opacity(0.5))
            }
        }
        .contextMenu {
            if url.isFileURL {
                Button("设置封面") {
                    isImagePickerPresented = true
                }

                Divider()

                Button("查看日志") {
                    showLogSheet = true
                }
            }
        }
        .fileImporter(
            isPresented: $isImagePickerPresented,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case let .success(files):
                if let selectedURL = files.first {
                    Task {
                        do {
                            addLog("开始设置封面：\(selectedURL.lastPathComponent)")

                            // 获取文件的安全访问权限
                            guard selectedURL.startAccessingSecurityScopedResource() else {
                                addLog("无法获取文件访问权限")
                                state.setError(ViewError.thumbnailGenerationFailed)
                                return
                            }

                            defer {
                                // 完成后释放访问权限
                                selectedURL.stopAccessingSecurityScopedResource()
                            }

                            let imageData = try Data(contentsOf: selectedURL)
                            try await url.writeCoverToMediaFile(
                                imageData: imageData,
                                imageType: "image/jpeg",
                                verbose: verbose
                            )
                            // 重新加载缩略图
                            state.reset()
                            await loadThumbnail()
                            addLog("封面设置成功")
                        } catch {
                            let errorMessage = "设置封面失败: \(error.localizedDescription)"
                            addLog(errorMessage)
                            state.setError(ViewError.thumbnailGenerationFailed)
                        }
                    }
                }
            case let .failure(error):
                let errorMessage = "选择图片失败: \(error.localizedDescription)"
                addLog(errorMessage, level: .error)
                state.setError(ViewError.thumbnailGenerationFailed)
            }
        }
        .sheet(isPresented: $showLogSheet) {
            NavigationView {
                MagicLogView(title: "AvatarView Logs", logs: logs) {
                    logs.removeAll()
                } onClose: {
                    showLogSheet = false
                }
            }
            #if os(macOS)
            .frame(minWidth: 500, minHeight: 300)
            #endif
        }
        .onChange(of: progressBinding?.wrappedValue) {
            addLog("⏬ 外部将下载进度设置为: \(progressBinding?.wrappedValue)")

            if let progress = progressBinding?.wrappedValue, progress >= 1.0 {
                Task {
                    state.reset()
                    await loadThumbnail()
                }
            }
        }
        .task {
            if state.error == nil {
                await loadThumbnail()
            }
            if monitorDownload {
                await setupDownloadMonitor()
            }
        }
        .onDisappear {
            downloadMonitor.stopMonitoring()
        }
    }

    // MARK: - Private Methods

    @Sendable private func loadThumbnail() async {
        if state.thumbnail != nil {
            addLog("跳过缩略图加载：已存在缩略图")
            return
        }

        if state.isLoading {
            addLog("跳过缩略图加载：正在加载中")
            return
        }

        if url.isDownloading {
            addLog("跳过缩略图加载：文件正在下载中")
            return
        }

        // 使用后台任务队列
        await Task.detached(priority: .utility) {
            addLog("🛫 开始加载缩略图: \(url.title)")
            if verbose { os_log("\(self.t)🪞🪞🪞 开始加载缩略图: \(url.title)") }
            await state.setLoading(true)

            do {
                addLog("🛫 正在生成缩略图，目标尺寸: \(size.width)x\(size.height)")
                // 在后台线程中处理图片生成
                let image = try await url.thumbnail(size: size, verbose: verbose)

                if let image = image {
                    addLog("🎉 缩略图生成成功")
                    await state.setThumbnail(image)
                    await state.setError(nil)
                } else {
                    addLog("缩略图生成失败，使用默认图片", level: .warning)
                    await state.setThumbnail(url.defaultImage)
                    await state.setError(ViewError.thumbnailGenerationFailed)
                }
            } catch URLError.cancelled {
                addLog("缩略图加载已取消", level: .warning)
                if verbose { os_log("\(self.t)缩略图加载已取消") }
            } catch {
                let viewError: ViewError
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet, .networkConnectionLost, .timedOut:
                        viewError = .downloadFailed
                        addLog("网络错误: \(urlError.localizedDescription)", level: .error)
                    case .fileDoesNotExist:
                        viewError = .fileNotFound
                        addLog("文件不存在: \(url.path)", level: .error)
                    default:
                        viewError = .thumbnailGenerationFailed
                        addLog("生成缩略图失败: \(urlError.localizedDescription)", level: .error)
                    }
                } else {
                    viewError = .thumbnailGenerationFailed
                    addLog("未知错误: \(error.localizedDescription)", level: .error)
                }

                await state.setError(viewError)
                if verbose { os_log(.error, "\(self.t)加载缩略图失败: \(viewError.localizedDescription)") }
            }

            await state.setLoading(false)
            addLog("🔚 缩略图加载流程结束")
        }.value
    }

    @Sendable private func setupDownloadMonitor() async {
        guard monitorDownload && url.isiCloud && progressBinding == nil else {
            addLog("🚫 跳过下载监控设置：不需要监控或非 iCloud 文件")
            return
        }

        addLog("🛫 开始设置下载监控: \(url.path)")
        if verbose { os_log("\(self.t)设置下载监控: \(url.path)") }

        downloadMonitor.startMonitoring(
            url: url,
            onProgress: { progress in
                state.setProgress(progress)
                // 记录下载进度
                if progress >= 0 {
                    addLog("🍋 下载进度: \(Int(progress * 100))%")
                }
                // 如果下载失败（进度为负数），设置相应的错误
                if progress < 0 {
                    addLog("🚫 下载失败", level: .error)
                    state.setError(ViewError.downloadFailed)
                }
            },
            onFinished: {
                Task {
                    addLog("🎉 下载完成，开始重新加载缩略图")
                    state.reset()
                    await loadThumbnail()
                }
            }
        )
    }
}

// MARK: - Preview

#Preview("头像视图") {
    AvatarDemoView()
}
