import SwiftUI

// MARK: - Media File View Modifiers
public extension MediaFileView {
    /// 移除背景样式
    /// - Returns: 无背景样式的视图
    func noBackground() -> MediaFileView {
        var view = self
        view.style = .none
        return view
    }
    
    /// 添加自定义背景
    /// - Parameter background: 背景视图
    /// - Returns: 带有指定背景的视图
    func withBackground<Background: View>(_ background: Background) -> MediaFileView {
        var view = self
        view.style = .background(AnyView(background))
        return view
    }
    
    /// 隐藏操作按钮
    /// - Returns: 不显示操作按钮的视图
    func hideActions() -> MediaFileView {
        var view = self
        view.showActions = false
        return view
    }
    
    /// 设置缩略图形状
    /// - Parameter shape: 要应用的形状
    /// - Returns: 使用指定形状的视图
    func thumbnailShape(_ shape: AvatarViewShape) -> MediaFileView {
        var view = self
        view.shape = shape
        return view
    }
    
    /// 设置垂直内边距
    /// - Parameter padding: 内边距大小（点）
    /// - Returns: 使用指定内边距的视图
    func verticalPadding(_ padding: CGFloat) -> MediaFileView {
        var view = self
        view.verticalPadding = padding
        return view
    }
    
    /// 禁用或启用下载进度监听
    /// 
    /// 当启用时，视图会自动监听 iCloud 文件的下载进度。
    /// 当禁用时，你可以通过 `downloadProgress` 修改器手动控制进度显示。
    ///
    /// 示例：
    /// ```swift
    /// // 禁用自动进度监听
    /// url.makeMediaView()
    ///     .disableDownloadMonitor()
    ///
    /// // 启用自动进度监听（默认）
    /// url.makeMediaView()
    ///     .disableDownloadMonitor(false)
    /// ```
    ///
    /// - Returns: 配置了下载监听的视图
    func disableDownloadMonitor() -> MediaFileView {
        var view = self
        view.monitorDownload = false
        return view
    }
    
    /// 设置下载进度
    /// 
    /// 这个修改器允许你通过一个 `Binding<Double>` 来控制下载进度的显示。
    /// 进度值应该在 0.0（未开始）到 1.0（完成）之间。
    /// 
    /// 基本用法：
    /// ```swift
    /// struct ContentView: View {
    ///     @State private var progress: Double = 0.0
    ///     
    ///     var body: some View {
    ///         url.makeMediaView()
    ///             .downloadProgress($progress)
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
    ///                 .downloadProgress($progress)
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
    /// - Returns: 使用指定下载进度的视图
    func downloadProgress(_ progress: Binding<Double>) -> MediaFileView {
        var view = self
        view.progressBinding = progress
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
    ///     .showFolderContent()
    ///     .withBackground(MagicBackground.mint)
    /// ```
    ///
    /// - Returns: 显示文件夹内容的视图
    func showFolderContent() -> MediaFileView {
        var view = self
        view.folderContentVisible = true
        return view
    }
}

#Preview("Media View") {
    MediaViewPreviewContainer()
}
