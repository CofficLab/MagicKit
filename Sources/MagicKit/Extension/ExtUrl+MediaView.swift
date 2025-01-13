import SwiftUI

public extension URL {
    /// 为 URL 创建媒体文件视图
    /// - Returns: 展示该 URL 对应文件信息的视图
    ///
    /// 这个方法会自动：
    /// - 获取文件大小
    /// - 生成缩略图（如果是媒体文件）
    /// - 处理错误状态
    /// - 监听 iCloud 文件下载进度
    /// - 提供文件操作按钮
    ///
    /// # 基本用法
    /// ```swift
    /// // 基本使用
    /// url.makeMediaView()
    /// ```
    ///
    /// # 自定义样式
    /// ```swift
    /// // 添加背景
    /// url.makeMediaView()
    ///     .withBackground(MagicBackground.mint)
    ///
    /// // 移除背景
    /// url.makeMediaView()
    ///     .noBackground()
    ///
    /// // 自定义缩略图形状
    /// url.makeMediaView()
    ///     .thumbnailShape(.circle)                              // 圆形
    ///     .thumbnailShape(.roundedRectangle(cornerRadius: 8))   // 圆角矩形
    ///     .thumbnailShape(.rectangle)                           // 矩形
    ///
    /// // 调整内边距
    /// url.makeMediaView()
    ///     .verticalPadding(16)
    ///
    /// // 隐藏操作按钮
    /// url.makeMediaView()
    ///     .hideActions()
    /// ```
    ///
    /// # 下载按钮控制
    /// ```swift
    /// // 显示下载按钮（默认行为）
    /// url.makeMediaView()
    ///     .magicShowDownloadButton(true)
    ///
    /// // 隐藏下载按钮
    /// url.makeMediaView()
    ///     .magicShowDownloadButton(false)
    /// ```
    ///
    /// # 下载进度显示
    /// ```swift
    /// // 自动监听 iCloud 文件下载进度（默认行为）
    /// url.makeMediaView()
    ///
    /// // 禁用自动进度监听
    /// url.makeMediaView()
    ///     .disableDownloadMonitor()
    ///
    /// // 手动控制下载进度
    /// struct DownloadView: View {
    ///     @State private var progress: Double = 0.0
    ///     
    ///     var body: some View {
    ///         VStack {
    ///             // 绑定进度状态
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
    /// # 文件夹内容展示
    /// ```swift
    /// // 显示文件夹内容（仅当 URL 指向文件夹时有效）
    /// folderURL.makeMediaView()
    ///     .showFolderContent()
    ///
    /// // 组合多个修改器
    /// folderURL.makeMediaView()
    ///     .showFolderContent()
    ///     .withBackground(MagicBackground.mint)
    ///     .thumbnailShape(.roundedRectangle(cornerRadius: 12))
    /// ```
    ///
    /// # 组合使用
    /// ```swift
    /// // 组合多个样式修改器
    /// url.makeMediaView()
    ///     .withBackground(MagicBackground.mint)
    ///     .thumbnailShape(.roundedRectangle(cornerRadius: 8))
    ///     .verticalPadding(16)
    ///     .hideActions()
    ///
    /// // 完整的下载示例
    /// struct DownloadableMediaView: View {
    ///     @State private var progress: Double = 0.0
    ///     let url: URL
    ///     
    ///     var body: some View {
    ///         url.makeMediaView()
    ///             .downloadProgress($progress)
    ///             .withBackground(MagicBackground.aurora)
    ///             .thumbnailShape(.roundedRectangle(cornerRadius: 8))
    ///             .magicShowDownloadButton(true)  // 显式控制下载按钮
    ///     }
    /// }
    /// ```
    func makeMediaView(verbose: Bool = false) -> MediaFileView {
        MediaFileView(url: self, verbose: verbose)
    }
}

#Preview("Media View") {
    MediaViewPreviewContainer()
}
