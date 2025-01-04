import SwiftUI

public extension URL {
    /// 为 URL 创建媒体文件视图
    /// - Returns: 展示该 URL 对应文件信息的视图
    ///
    /// 这个方法会自动：
    /// - 获取文件大小
    /// - 生成缩略图（如果是媒体文件）
    /// - 处理错误状态
    ///
    /// 示例：
    /// ```swift
    /// // 基本使用
    /// url.makeMediaView()
    ///
    /// // 带背景
    /// url.makeMediaView()
    ///     .withBackground(MagicBackground.mint)
    ///
    /// // 自定义形状和内边距
    /// url.makeMediaView()
    ///     .thumbnailShape(.roundedRectangle(cornerRadius: 8))
    ///     .verticalPadding(16)
    /// ```
    func makeMediaView() -> MediaFileView {
        MediaFileView(url: self, size: self.getSizeReadable())
    }
}

#Preview("Media View") {
    MediaViewPreviewContainer()
}
