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
    let showLogButton: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    // 添加日志相关状态
    @Binding var showLogSheet: Bool

    public init(url: URL, showDownloadButton: Bool = true, showLogButton: Bool = true, showLogSheet: Binding<Bool>) {
        self.url = url
        self.showDownloadButton = showDownloadButton
        self.showLogButton = showLogButton
        self._showLogSheet = showLogSheet
    }

    public var body: some View {
        HStack(spacing: 12) {
            if showDownloadButton && url.isNotDownloaded {
                url.makeDownloadButton()
            }
            
            if showLogButton {
                MagicButton(icon: .iconLog, action: {_ in
                    showLogSheet = true
                }).magicShape(.circle).magicSize(.small)
            }
            
            url.makeOpenButton()
        }
        .padding(.trailing, 8)
    }
}

/// Action Buttons Section View
public struct ActionButtonsSection: View {
    public let url: URL
    public let showDownloadButton: Bool
    public let showLogSheet: Binding<Bool>
    public let horizontalPadding: CGFloat
    public let showBorder: Bool
    public let isHovering: Bool
    
    public init(url: URL, showDownloadButton: Bool, showLogSheet: Binding<Bool>, horizontalPadding: CGFloat, showBorder: Bool, isHovering: Bool) {
        self.url = url
        self.showDownloadButton = showDownloadButton
        self.showLogSheet = showLogSheet
        self.horizontalPadding = horizontalPadding
        self.showBorder = showBorder
        self.isHovering = isHovering
    }
    
    public var body: some View {
        ActionButtonsView(
            url: url,
            showDownloadButton: showDownloadButton,
            showLogSheet: showLogSheet
        )
        .opacity(isHovering ? 1 : 0)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                .foregroundColor(showBorder ? .orange : .clear)
        )
        .padding(.trailing, horizontalPadding)
    }
}

#Preview("Media View") {
    MediaViewPreviewContainer().inMagicContainer()
}
