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
        if isNetworkURL {
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
            NSWorkspace.shared.activateFileViewerSelecting([self])
        }

        /// 在指定的应用程序中打开
        /// - Parameter appType: 应用程序类型
        func openIn(_ appType: OpenAppType) {
            if appType == .browser {
                openInBrowser()
                return
            }

            if appType == .finder {
                openInFinder()
                return
            }

            guard let bundleId = appType.bundleId else { return }

            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = true

            let bundleURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)
            guard let bundleURL = bundleURL else {
                print("Failed to find application with bundle ID: \(bundleId)")
                return
            }

            NSWorkspace.shared.open(
                [self],
                withApplicationAt: bundleURL,
                configuration: configuration
            )
        }
    #endif

    /// 打开包含该文件的文件夹
    func openFolder() {
        let folderURL = self.hasDirectoryPath ? self : self.deletingLastPathComponent()
        #if os(iOS)
            UIApplication.shared.open(folderURL)
        #elseif os(macOS)
            NSWorkspace.shared.open(folderURL)
        #endif
    }
}

#Preview("Open Buttons") {
    OpenPreivewView()
        .inMagicContainer()
}
