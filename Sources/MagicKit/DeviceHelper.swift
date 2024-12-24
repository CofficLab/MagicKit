#if os(macOS)
import AppKit
#elseif os(iOS) || os(visionOS)
import UIKit
#endif
import Foundation

public class DeviceHelper {
    public static func getDeviceName() -> String {
        #if os(macOS)
        return Host.current().localizedName ?? "Unknown"
        #elseif os(iOS) || os(visionOS)
        return UIDevice.current.name
        #endif
    }

    public static func getDeviceModel() -> String {
        var size: Int = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }

    public static func getSystemName() -> String {
        #if os(macOS)
            return "macOS"
        #elseif os(iOS)
            return "iOS"
        #elseif os(visionOS)
            return "visionOS"
        #else
            return "unknown"
        #endif
    }

    public static func getSystemVersion() -> String {
        if let version = ProcessInfo.processInfo.operatingSystemVersionString.split(separator: " ").last {
            return String(version)
        }
        return "Unknown"
    }
}
