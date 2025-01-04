import SwiftUI

// MARK: - URL Avatar View Extension
public extension URL {
    /// 为 URL 创建一个头像视图
    /// 
    /// 头像视图是一个突出显示文件缩略图的视图组件，它可以：
    /// - 自动生成并显示文件缩略图
    /// - 展示文件下载进度
    /// - 处理错误状态
    /// - 支持自定义形状和背景色
    /// - 支持多种尺寸设置方式
    /// 
    /// # 基础用法
    /// ```swift
    /// // 创建基础视图
    /// let avatarView = url.makeAvatarView()
    /// 
    /// // 自定义形状
    /// let customView = url.makeAvatarView()
    ///     .magicShape(.roundedRectangle(cornerRadius: 8))
    /// ```
    /// 
    /// # 自定义外观
    /// ```swift
    /// // 设置背景色
    /// let coloredView = url.makeAvatarView()
    ///     .magicBackground(.blue.opacity(0.1))
    /// 
    /// // 设置尺寸
    /// let sizedView = url.makeAvatarView()
    ///     .magicSize(64)  // 正方形边长
    /// 
    /// // 自定义宽高
    /// let rectangleView = url.makeAvatarView()
    ///     .magicSize(width: 80, height: 60)
    /// ```
    /// 
    /// # 下载进度
    /// ```swift
    /// // 自动监听 iCloud 文件
    /// let cloudView = url.makeAvatarView()
    /// 
    /// // 手动控制进度
    /// @State var progress: Double = 0
    /// let progressView = url.makeAvatarView()
    ///     .magicDownloadProgress($progress)
    /// ```
    /// 
    /// # 错误处理
    /// 视图会自动处理并显示以下错误：
    /// - 缩略图生成失败
    /// - 文件访问错误
    /// - 下载失败
    /// 
    /// - Returns: 配置好的头像视图
    func makeAvatarView() -> AvatarView {
        AvatarView(url: self)
    }
}

// MARK: - Preview
#Preview("头像视图") {
    AvatarDemoView()
}
