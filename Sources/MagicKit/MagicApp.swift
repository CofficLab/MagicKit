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
}

#Preview {
    Text("Hello, World!")
}
