import SwiftUI

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
        view.shape = shape
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
    ///             .magicDownloadProgress($progress)
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
    ///                 .magicDownloadProgress($progress)
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
    func magicDownloadProgress(_ progress: Binding<Double>) -> MediaFileView {
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
}

#Preview("Media View") {
    MediaViewPreviewContainer()
}
