import SwiftUI

// MARK: - URL Hero View Extension
public extension URL {
    /// 为 URL 创建一个主角视图
    /// 
    /// 主角视图是一个突出显示文件缩略图的视图组件，它可以：
    /// - 自动生成并显示文件缩略图
    /// - 展示文件下载进度
    /// - 处理错误状态
    /// - 支持自定义形状
    /// 
    /// # 基础用法
    /// ```swift
    /// // 创建基础视图
    /// let heroView = url.makeHeroView()
    /// 
    /// // 自定义形状
    /// let customView = url.makeHeroView()
    ///     .magicShape(.roundedRectangle(cornerRadius: 8))
    /// ```
    /// 
    /// # 下载进度
    /// ```swift
    /// // 自动监听 iCloud 文件
    /// let cloudView = url.makeHeroView()
    /// 
    /// // 手动控制进度
    /// @State var progress: Double = 0
    /// let progressView = url.makeHeroView()
    ///     .magicDownloadProgress($progress)
    /// ```
    /// 
    /// # 错误处理
    /// 视图会自动处理并显示以下错误：
    /// - 缩略图生成失败
    /// - 文件访问错误
    /// - 下载失败
    /// 
    /// - Returns: 配置好的主角视图
    func makeHeroView() -> HeroView {
        HeroView(url: self)
    }
}

// MARK: - Preview
#Preview("主角视图") {
    HeroViewPreviewContainer()
}
