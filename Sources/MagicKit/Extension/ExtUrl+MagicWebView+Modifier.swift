import SwiftUI

public extension MagicWebView {
    /// 设置是否显示日志视图
    /// - Parameter show: 是否显示
    /// - Returns: 修改后的视图
    func showLogView(_ show: Bool = true) -> MagicWebView {
        MagicWebView(
            url: url,
            showLogView: show,
            onLoadComplete: onLoadComplete
        )
    }
    
    /// 跳转到新的URL
    /// - Parameter url: 目标URL
    /// - Returns: 修改后的视图
    func goto(_ url: URL) -> MagicWebView {
        MagicWebView(
            url: url,
            showLogView: true,
            onLoadComplete: onLoadComplete
        )
    }
}

#Preview("WebView Demo") {
    MagicWebViewDemo()
        .frame(height: 800)
}
