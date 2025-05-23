import SwiftUI

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

// MARK: - Media View Style
public enum MediaViewStyle {
    case none
    case background(AnyView)
}

// MARK: - Log View Style
public enum LogViewStyle {
    case sheet
    case popover
}

// MARK: - Log View Presentation Modifier
struct LogViewPresentation<LogContent: View>: ViewModifier {
    let isPresented: Binding<Bool>
    let style: LogViewStyle
    let logContent: () -> LogContent
    
    init(isPresented: Binding<Bool>, style: LogViewStyle, content: @escaping () -> LogContent) {
        self.isPresented = isPresented
        self.style = style
        self.logContent = content
    }
    
    func body(content: Content) -> some View {
        Group {
            switch style {
            case .sheet:
                content.sheet(isPresented: isPresented) {
                    logContent()
                }
            case .popover:
                content.popover(isPresented: isPresented) {
                    logContent()
                        .frame(width: 600, height: 400)
                }
            }
        }
    }
}

// MARK: - Media File View Modifiers

public extension MediaFileView {
    /// 移除背景样式
    /// - Returns: 无背景样式的视图
    func magicNoBackground() -> MediaFileView {
        var view = self
        view.style = .none
        return view
    }

    /// 添加自定义背景
    /// - Parameter background: 背景视图
    /// - Returns: 带有指定背景的视图
    func magicBackground<Background: View>(_ background: Background) -> MediaFileView {
        var view = self
        view.style = .background(AnyView(background))
        return view
    }

    /// 隐藏操作按钮
    /// - Returns: 不显示操作按钮的视图
    func magicHideActions() -> MediaFileView {
        var view = self
        view.showActions = false
        return view
    }

    /// 设置缩略图形状
    /// - Parameter shape: 要应用的形状
    /// - Returns: 使用指定形状的视图
    func magicShape(_ shape: AvatarViewShape) -> MediaFileView {
        var view = self
        view.avatarShape = shape
        return view
    }

    /// 设置垂直内边距
    /// - Parameter padding: 内边距大小（点）
    /// - Returns: 使用指定内边距的视图
    func magicVerticalPadding(_ padding: CGFloat) -> MediaFileView {
        var view = self
        view.verticalPadding = padding
        return view
    }

    /// 设置水平内边距
    /// - Parameter padding: 内边距大小
    /// - Returns: 修改后的视图
    func magicHorizontalPadding(_ padding: CGFloat) -> MediaFileView {
        var view = self
        view.horizontalPadding = padding
        return view
    }

    /// 设置内边距
    /// - Parameters:
    ///   - horizontal: 水平内边距
    ///   - vertical: 垂直内边距
    /// - Returns: 修改后的视图
    func magicPadding(horizontal: CGFloat = 16, vertical: CGFloat = 12) -> MediaFileView {
        var view = self
        view.horizontalPadding = horizontal
        view.verticalPadding = vertical
        return view
    }

    /// 禁用或启用下载进度监听
    ///
    /// 当启用时，视图会自动监听 iCloud 文件的下载进度。
    /// 当禁用时，你可以通过 `magicDownloadProgress` 修改器手动控制进度显示。
    ///
    /// 示例：
    /// ```swift
    /// // 禁用自动进度监听
    /// url.makeMediaView()
    ///     .magicDisableDownloadMonitor()
    ///
    /// // 启用自动进度监听（默认）
    /// url.makeMediaView()
    ///     .magicDisableDownloadMonitor(false)
    /// ```
    ///
    /// - Returns: 配置了下载监听的视图
    func magicDisableDownloadMonitor() -> MediaFileView {
        var view = self
        view.monitorDownload = false
        return view
    }

    /// 展示文件夹内容
    ///
    /// 当应用于文件夹的 `MediaView` 时，这个修改器会在文件夹信息下方显示其内容列表。
    /// 列表中的每个项目都会使用 `MediaView` 来显示。
    ///
    /// 示例：
    /// ```swift
    /// // 显示文件夹内容
    /// folderURL.makeMediaView()
    ///     .magicShowFolderContent()
    ///     .magicBackground(MagicBackground.mint)
    /// ```
    ///
    /// - Returns: 显示文件夹内容的视图
    func magicShowFolderContent() -> MediaFileView {
        var view = self
        view.folderContentVisible = true
        return view
    }

    /// 设置内部头像视图的形状
    ///
    /// 这个修改器允许你设置 MediaView 中头像部分的形状，而不影响整个视图的形状。
    ///
    /// 示例：
    /// ```swift
    /// // 设置头像为圆形
    /// url.makeMediaView()
    ///     .magicAvatarShape(.circle)
    ///
    /// // 设置头像为圆角矩形
    /// url.makeMediaView()
    ///     .magicAvatarShape(.roundedRectangle(cornerRadius: 8))
    /// ```
    ///
    /// - Parameter shape: 要应用的头像形状
    /// - Returns: 配置了头像形状的视图
    func magicAvatarShape(_ shape: AvatarViewShape) -> MediaFileView {
        var view = self
        view.avatarShape = shape
        return view
    }

    /// 设置内部头像为圆形
    /// - Returns: 头像为圆形的视图
    func magicCircleAvatar() -> MediaFileView {
        magicAvatarShape(.circle)
    }

    /// 设置内部头像为圆角矩形
    /// - Parameter cornerRadius: 圆角半径
    /// - Returns: 头像为圆角矩形的视图
    func magicRoundedAvatar(_ cornerRadius: CGFloat = 8) -> MediaFileView {
        magicAvatarShape(.roundedRectangle(cornerRadius: cornerRadius))
    }

    /// 设置内部头像为矩形
    /// - Returns: 头像为矩形的视图
    func magicRectangleAvatar() -> MediaFileView {
        magicAvatarShape(.rectangle)
    }

    /// 设置内部头像的背景色
    ///
    /// 这个修改器允许你设置 MediaView 中头像部分的背景色，而不影响整个视图的背景。
    ///
    /// 示例：
    /// ```swift
    /// // 设置头像背景为红色
    /// url.makeMediaView()
    ///     .magicAvatarBackground(.red.opacity(0.1))
    ///
    /// // 组合使用形状和背景色
    /// url.makeMediaView()
    ///     .magicCircleAvatar()
    ///     .magicAvatarBackground(.blue.opacity(0.1))
    /// ```
    ///
    /// - Parameter color: 要应用的背景色
    /// - Returns: 配置了头像背景色的视图
    func magicAvatarBackground(_ color: Color) -> MediaFileView {
        var view = self
        view.avatarBackgroundColor = color
        return view
    }

    /// 显示或隐藏布局边框
    /// - Parameter show: 是否显示边框
    /// - Returns: 修改后的视图
    func magicShowBorder(_ show: Bool = true) -> MediaFileView {
        var view = self
        view.showBorder = show
        return view
    }

    /// 设置内部头像的尺寸
    ///
    /// 这个修改器允许你设置 MediaView 中头像部分的尺寸。
    ///
    /// 示例：
    /// ```swift
    /// // 设置头像尺寸为 60x60
    /// url.makeMediaView()
    ///     .magicAvatarSize(width: 60, height: 60)
    ///
    /// // 设置头像为正方形
    /// url.makeMediaView()
    ///     .magicAvatarSize(40)
    ///
    /// // 组合使用尺寸和其他修改器
    /// url.makeMediaView()
    ///     .magicAvatarSize(50)
    ///     .magicCircleAvatar()
    ///     .magicAvatarBackground(.blue.opacity(0.1))
    /// ```
    ///
    /// - Parameters:
    ///   - width: 头像宽度
    ///   - height: 头像高度
    /// - Returns: 配置了头像尺寸的视图
    func magicAvatarSize(width: CGFloat, height: CGFloat) -> MediaFileView {
        var view = self
        view.avatarSize = CGSize(width: width, height: height)
        return view
    }

    /// 设置内部头像为正方形
    ///
    /// 这个修改器是 `magicAvatarSize(width:height:)` 的简化版本，用于设置正方形头像。
    ///
    /// 示例：
    /// ```swift
    /// // 设置头像为 50x50 的正方形
    /// url.makeMediaView()
    ///     .magicAvatarSize(50)
    /// ```
    ///
    /// - Parameter dimension: 正方形边长
    /// - Returns: 配置了头像尺寸的视图
    func magicAvatarSize(_ dimension: CGFloat) -> MediaFileView {
        magicAvatarSize(width: dimension, height: dimension)
    }

    /// 设置内部头像的预设尺寸
    ///
    /// 这个修改器允许你使用预定义的尺寸来设置头像大小。
    ///
    /// 示例：
    /// ```swift
    /// // 使用小尺寸
    /// url.makeMediaView()
    ///     .magicAvatarSize(.small)
    ///
    /// // 使用大尺寸
    /// url.makeMediaView()
    ///     .magicAvatarSize(.large)
    /// ```
    ///
    /// - Parameter preset: 预设尺寸
    /// - Returns: 配置了头像尺寸的视图
    func magicAvatarSize(_ preset: AvatarSize) -> MediaFileView {
        var view = self
        view.avatarSize = preset.size
        return view
    }

    /// 设置是否监控下载进度
    ///
    /// 这个修改器允许你控制是否监控内部头像视图的下载进度。
    ///
    /// 示例：
    /// ```swift
    /// // 启用下载进度监控
    /// url.makeMediaView()
    ///     .magicAvatarDownloadMonitor(true)
    ///
    /// // 禁用下载进度监控
    /// url.makeMediaView()
    ///     .magicAvatarDownloadMonitor(false)
    ///
    /// // 组合使用
    /// url.makeMediaView()
    ///     .magicAvatarDownloadMonitor(true)
    ///     .magicAvatarSize(.large)
    ///     .magicCircleAvatar()
    /// ```
    ///
    /// - Parameter monitor: 是否监控下载进度
    /// - Returns: 配置了下载进度监控的视图
    func magicAvatarDownloadMonitor(_ monitor: Bool) -> MediaFileView {
        var view = self
        view.monitorDownload = monitor
        return view
    }

    /// 设置内部头像的下载进度绑定
    ///
    /// 这个修改器允许你通过一个 `Binding<Double>` 来控制内部头像视图的下载进度显示。
    /// 进度值应该在 0.0（未开始）到 1.0（完成）之间。
    ///
    /// 基本用法：
    /// ```swift
    /// struct ContentView: View {
    ///     @State private var progress: Double = 0.0
    ///
    ///     var body: some View {
    ///         url.makeMediaView()
    ///             .magicAvatarDownloadProgress($progress)
    ///     }
    /// }
    /// ```
    ///
    /// 与其他控件集成：
    /// ```swift
    /// struct DownloadView: View {
    ///     @State private var progress: Double = 0.0
    ///
    ///     var body: some View {
    ///         VStack {
    ///             url.makeMediaView()
    ///                 .magicAvatarDownloadProgress($progress)
    ///
    ///             // 使用滑块控制进度
    ///             Slider(value: $progress, in: 0...1)
    ///
    ///             // 添加动画效果
    ///             Button("开始下载") {
    ///                 withAnimation(.linear(duration: 3)) {
    ///                     progress = 1.0
    ///                 }
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// 注意：
    /// - 当使用此修改器时，自动进度监听将被禁用
    /// - 进度值会自动限制在 0.0 到 1.0 之间
    /// - 支持动画效果
    /// - 可以随时通过更新绑定的值来更新进度
    ///
    /// - Parameter progress: 下载进度的绑定（0.0 到 1.0）
    /// - Returns: 配置了头像下载进度的视图
    func magicAvatarDownloadProgress(_ progress: Binding<Double>?) -> MediaFileView {
        var view = self
        view.avatarProgressBinding = progress
        return view
    }

    /// 控制是否显示下载按钮
    ///
    /// 这个修改器允许你控制是否在操作按钮区域显示下载按钮。
    ///
    /// 示例：
    /// ```swift
    /// // 隐藏下载按钮
    /// url.makeMediaView()
    ///     .magicHideDownloadButton()
    ///
    /// // 显示下载按钮（默认）
    /// url.makeMediaView()
    ///     .magicShowDownloadButton(true)
    /// ```
    ///
    /// - Parameter show: 是否显示下载按钮
    /// - Returns: 修改后的视图
    func magicShowDownloadButton(_ show: Bool = true) -> MediaFileView {
        var view = self
        view.showDownloadButton = show
        return view
    }

    /// 控制是否显示文件状态信息
    ///
    /// 这个修改器允许你控制是否显示文件的状态信息（如"远程文件"、"本地文件"等）。
    ///
    /// 示例：
    /// ```swift
    /// // 隐藏文件状态
    /// url.makeMediaView()
    ///     .magicHideFileStatus()
    ///
    /// // 显示文件状态（默认）
    /// url.makeMediaView()
    ///     .magicShowFileStatus(true)
    /// ```
    ///
    /// - Parameter show: 是否显示文件状态
    /// - Returns: 修改后的视图
    func magicShowFileStatus(_ show: Bool = true) -> MediaFileView {
        var view = self
        view.showFileStatus = show
        return view
    }

    /// 隐藏文件状态信息
    ///
    /// 这是 `magicShowFileStatus(false)` 的便捷方法。
    ///
    /// - Returns: 隐藏文件状态的视图
    func magicHideFileStatus() -> MediaFileView {
        magicShowFileStatus(false)
    }

    /// 控制是否显示文件大小
    ///
    /// 这个修改器允许你控制是否显示文件的大小信息。
    ///
    /// 示例：
    /// ```swift
    /// // 隐藏文件大小
    /// url.makeMediaView()
    ///     .magicHideFileSize()
    ///
    /// // 显示文件大小（默认）
    /// url.makeMediaView()
    ///     .magicShowFileSize(true)
    /// ```
    ///
    /// - Parameter show: 是否显示文件大小
    /// - Returns: 修改后的视图
    func magicShowFileSize(_ show: Bool = true) -> MediaFileView {
        var view = self
        view.showFileSize = show
        return view
    }

    /// 隐藏文件大小
    ///
    /// 这是 `magicShowFileSize(false)` 的便捷方法。
    ///
    /// - Returns: 隐藏文件大小的视图
    func magicHideFileSize() -> MediaFileView {
        magicShowFileSize(false)
    }

    /// 设置是否启用详细模式
    ///
    /// 这个修改器允许你控制视图是否显示详细信息。
    ///
    /// 示例：
    /// ```swift
    /// // 启用详细模式（默认）
    /// url.makeMediaView()
    ///     .magicVerbose(true)
    ///
    /// // 禁用详细模式
    /// url.makeMediaView()
    ///     .magicVerbose(false)
    /// ```
    ///
    /// - Parameter enabled: 是否启用详细模式
    /// - Returns: 修改后的视图
    func magicVerbose(_ enabled: Bool = true) -> MediaFileView {
        var view = self
        view.verbose = enabled
        return view
    }

    /// 设置是否显示头像视图
    /// - Parameter show: 是否显示
    /// - Returns: 修改后的视图
    func showAvatar(_ show: Bool) -> MediaFileView {
        var view = self
        view.showAvatar = show
        return view
    }

    /// 控制是否显示日志按钮
    ///
    /// 这个修改器允许你控制是否在操作按钮区域显示日志按钮。
    ///
    /// 示例：
    /// ```swift
    /// // 隐藏日志按钮
    /// url.makeMediaView()
    ///     .magicHideLogButton()
    ///
    /// // 显示日志按钮（默认）
    /// url.makeMediaView()
    ///     .magicShowLogButton(true)
    /// ```
    ///
    /// - Parameter show: 是否显示日志按钮
    /// - Returns: 修改后的视图
    func magicShowLogButton(_ show: Bool = true) -> MediaFileView {
        var view = self
        view.showLogButton = show
        return view
    }

    /// 隐藏日志按钮
    ///
    /// 这是 `magicShowLogButton(false)` 的便捷方法。
    ///
    /// - Returns: 隐藏日志按钮的视图
    func magicHideLogButton() -> MediaFileView {
        magicShowLogButton(false)
    }

    /// 仅在 DEBUG 模式下显示日志按钮
    ///
    /// 这个修改器会根据编译模式来控制日志按钮的显示：
    /// - 在 DEBUG 模式下显示日志按钮
    /// - 在 RELEASE 模式下隐藏日志按钮
    ///
    /// 示例：
    /// ```swift
    /// url.makeMediaView()
    ///     .magicShowLogButtonInDebug()
    /// ```
    ///
    /// - Returns: 修改后的视图
    func magicShowLogButtonInDebug() -> MediaFileView {
        var view = self
        #if DEBUG
        view.showLogButton = true
        #else
        view.showLogButton = false
        #endif
        return view
    }

    /// 设置日志视图的显示样式
    ///
    /// 这个修改器允许你控制日志视图的显示方式，可以选择以 sheet 或 popover 的形式显示。
    ///
    /// 示例：
    /// ```swift
    /// // 以 sheet 形式显示（默认）
    /// url.makeMediaView()
    ///     .magicLogStyle(.sheet)
    ///
    /// // 以 popover 形式显示
    /// url.makeMediaView()
    ///     .magicLogStyle(.popover)
    /// ```
    ///
    /// - Parameter style: 日志视图的显示样式
    /// - Returns: 配置了日志视图样式的视图
    func magicLogStyle(_ style: LogViewStyle) -> MediaFileView {
        var view = self
        view.logStyle = style
        return view
    }

    /// 以 sheet 形式显示日志视图
    ///
    /// 这是 `magicLogStyle(.sheet)` 的便捷方法。
    ///
    /// 示例：
    /// ```swift
    /// url.makeMediaView()
    ///     .magicLogAsSheet()
    /// ```
    ///
    /// - Returns: 配置为以 sheet 形式显示日志的视图
    func magicLogAsSheet() -> MediaFileView {
        magicLogStyle(.sheet)
    }

    /// 以 popover 形式显示日志视图
    ///
    /// 这是 `magicLogStyle(.popover)` 的便捷方法。
    ///
    /// 示例：
    /// ```swift
    /// url.makeMediaView()
    ///     .magicLogAsPopover()
    /// ```
    ///
    /// - Returns: 配置为以 popover 形式显示日志的视图
    func magicLogAsPopover() -> MediaFileView {
        magicLogStyle(.popover)
    }
}

#Preview("Media View") {
    MediaViewPreviewContainer().inMagicContainer()
}
