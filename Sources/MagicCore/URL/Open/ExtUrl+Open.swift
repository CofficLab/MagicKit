import Foundation
import SwiftUI

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
    func makeOpenButton() -> MagicButton {
        MagicButton(
            icon: isNetworkURL ? .iconSafari : .iconShowInFinder,
            title: isNetworkURL ? "在浏览器中打开" : "在访达中显示",
            style: .secondary,
            shape: .circle,
            action: {
                open()
            }
        )
    }
}

#Preview("Open Buttons") {
    OpenPreivewView()
}
