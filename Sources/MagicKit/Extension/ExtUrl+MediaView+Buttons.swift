import SwiftUI

/// 文件操作按钮视图组件
///
/// 提供文件的基本操作功能，包括：
/// - 下载按钮（针对未下载的文件）
/// - 打开按钮
///
/// 使用示例：
/// ```swift
/// ActionButtonsView(url: fileURL, showDownloadButton: true)
/// ```
public struct ActionButtonsView: View {
    let url: URL
    let showDownloadButton: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    // 添加日志相关状态
    @Binding var showLogSheet: Bool

    public init(url: URL, showDownloadButton: Bool = true, showLogSheet: Binding<Bool>) {
        self.url = url
        self.showDownloadButton = showDownloadButton
        self._showLogSheet = showLogSheet
    }

    public var body: some View {
        HStack(spacing: 12) {
            if showDownloadButton && url.isNotDownloaded {
                url.makeDownloadButton()
            }
            
            MagicButton(icon: "doc.text.magnifyingglass", action: {
                showLogSheet = true
            }).magicShape(.circle).magicSize(.small)
            
            url.makeOpenButton()
        }
        .padding(.trailing, 8)
    }
}
