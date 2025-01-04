import SwiftUI
import Combine

// MARK: - URL Extension
public extension URL {
    /// 为 URL 创建缩略图视图
    /// - Returns: 展示该 URL 对应文件缩略图的视图
    ///
    /// 这个方法会自动：
    /// - 生成缩略图（如果是媒体文件）
    /// - 处理错误状态
    /// - 监听 iCloud 文件下载进度
    ///
    /// # 基本用法
    /// ```swift
    /// // 基本使用
    /// url.makeHeroView()
    /// ```
    ///
    /// # 自定义样式
    /// ```swift
    /// // 自定义形状
    /// url.makeHeroView()
    ///     .shape(.roundedRectangle(cornerRadius: 8))
    /// ```
    ///
    /// # 下载进度显示
    /// ```swift
    /// // 自动监听 iCloud 文件下载进度（默认行为）
    /// url.makeHeroView()
    ///
    /// // 禁用自动进度监听
    /// url.makeHeroView()
    ///     .disableDownloadMonitor()
    ///
    /// // 手动控制下载进度
    /// struct DownloadView: View {
    ///     @State private var progress: Double = 0.0
    ///     
    ///     var body: some View {
    ///         VStack {
    ///             url.makeHeroView()
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
    func makeHeroView() -> HeroView {
        HeroView(url: self)
    }
}

#Preview("Hero") {
    HeroViewPreviewContainer()
} 
