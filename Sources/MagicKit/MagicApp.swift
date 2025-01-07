import Foundation
import SwiftUI

#if os(iOS) || os(tvOS)
import UIKit       // 用于 iOS/tvOS
#endif

#if os(watchOS)
import WatchKit    // 用于 watchOS
#endif

#if os(macOS)
import AppKit
#endif

public class MagicApp {
    public static func getVersion() -> String {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return ""
        }
        return version
    }

    public static func getAppName() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }

    public static func quit() {
        #if os(macOS)
            let url = Bundle.main.bundleURL
            let configuration = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.openApplication(at: url, configuration: configuration) { _, error in
                if error == nil {
                    DispatchQueue.main.async {
                        NSApplication.shared.terminate(nil)
                    }
                }
            }
        #elseif os(iOS) || os(tvOS)
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        #elseif os(watchOS)
            WKApplication.shared().exit()
        #endif
    }

    /// 检查当前设备是否已启用 iCloud Drive 功能
    ///
    /// 此方法通过检查 FileManager 的 ubiquityIdentityToken 来判断 iCloud Drive 是否可用。
    /// 在 watchOS 平台上将始终返回 false。
    ///
    /// ```swift
    /// if MagicApp.isICloudAvailable() {
    ///     // 执行需要 iCloud Drive 的操作
    ///     saveToCloud()
    /// } else {
    ///     // 提示用户启用 iCloud Drive
    ///     showEnableCloudAlert()
    /// }
    /// ```
    ///
    /// - Important: 首次检查可能会触发系统的 iCloud 登录提示。建议在后台线程中调用此方法。
    ///
    /// - Note: 使用此功能需要在项目的 Capabilities 中启用 iCloud，
    ///         并在 entitlements 文件中添加相应的权限。
    ///
    /// - Returns: 如果 iCloud Drive 可用返回 true，否则返回 false。
    ///            在以下情况下返回 false：
    ///            - 用户未登录 iCloud 账号
    ///            - 用户已登录但未启用 iCloud Drive
    ///            - 当前设备不支持 iCloud Drive（如 watchOS）
    ///            - 应用没有 iCloud 访问权限
    public static func isICloudAvailable() -> Bool {
        #if os(macOS) || os(iOS) || os(tvOS)
        if FileManager.default.ubiquityIdentityToken != nil {
            return true
        }
        #endif
        return false
    }
}

#Preview {
    Text("Hello, World!")
}
