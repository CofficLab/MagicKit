import Foundation
import SwiftUI
import MagicUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

public extension URL {
    /// 打开URL：如果是网络链接则在浏览器打开，如果是本地文件则在访达中显示
    func open() {
        if self.scheme == "http" || self.scheme == "https" {
            openInBrowser()
        } else {
            openInFinder()
        }
    }
    
    /// 在浏览器中打开URL
    func openInBrowser() {
        #if os(iOS)
            UIApplication.shared.open(self)
        #elseif os(macOS)
            NSWorkspace.shared.open(self)
        #endif
    }
    
    /// 在访达中显示文件或文件夹
    func openInFinder() {
        #if os(macOS)
            showInFinder()
        #else
            openFolder()
        #endif
    }
    
    #if os(macOS)
    /// 在访达中显示并选中文件
    func showInFinder() {
        NSWorkspace.shared.selectFile(self.path, inFileViewerRootedAtPath: "")
    }
    #endif
    
    /// 打开包含该文件的文件夹
    func openFolder() {
        let folderURL = self.hasDirectoryPath ? self : self.deletingLastPathComponent()
        #if os(iOS)
            UIApplication.shared.open(folderURL)
        #elseif os(macOS)
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: folderURL.path)
        #endif
    }
    
    /// 创建打开按钮
    /// - Parameters:
    ///   - size: 按钮大小，默认为 28x28
    ///   - showLabel: 是否显示文字标签，默认为 false
    /// - Returns: 打开按钮视图
    func makeOpenButton(size: CGFloat = 28, showLabel: Bool = false) -> some View {
        OpenButtonView(url: self, size: size, showLabel: showLabel)
    }
}

// MARK: - Open Button View
private struct OpenButtonView: View {
    let url: URL
    let size: CGFloat
    let showLabel: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    public var isWebLink: Bool {
        url.scheme == "http" || url.scheme == "https"
    }
    
    private var iconName: String {
        isWebLink ? .iconSafari : .iconShowInFinder
    }
    
    private var buttonLabel: String {
        isWebLink ? "在浏览器中打开" : "在访达中显示"
    }
    
    var body: some View {
        MagicButton(
            icon: iconName,
            title: showLabel ? buttonLabel : nil,
            style: .secondary,
            size: size <= 32 ? .small : (size <= 40 ? .regular : .large),
            shape: .circle,
            action: {
                url.open()
            }
        )
        .help(buttonLabel)
    }
}

#Preview("Open Buttons") {
    MagicThemePreview {
        VStack(spacing: 20) {
            // 网络链接
            Group {
                Text("网络链接").font(.headline)
                
                URL.sample_web_mp3_kennedy.makeOpenButton()
                URL.sample_web_mp3_kennedy.makeOpenButton(showLabel: true)
                URL.sample_web_mp3_kennedy.makeOpenButton(size: 40)
            }
            
            Divider()
            
            // 本地文件
            Group {
                Text("本地文件").font(.headline)
                
                URL.sample_temp_txt.makeOpenButton()
                URL.sample_temp_txt.makeOpenButton(showLabel: true)
                URL.sample_temp_txt.makeOpenButton(size: 40)
            }
        }
        .padding()
    }
}
