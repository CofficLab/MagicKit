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
    func thumbnailShape(_ shape: MediaViewShape) -> MediaFileView {
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
    
    /// 禁用下载进度监听
    /// - Returns: 不监听下载进度的视图
    func disableDownloadMonitor() -> MediaFileView {
        var view = self
        view.monitorDownload = false
        return view
    }
    
    /// 展示文件夹内容
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
