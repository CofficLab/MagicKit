import Foundation
import SwiftUI

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


enum MagicDevice: String, Equatable {
    case iMac
    case MacBook
    case iPhone_15
    case iPhone_SE
    case iPhoneBig
    case iPhoneSmall
    case iPad_mini

    var size: String {
        "\(Int(width)) x \(Int(height))"
    }

    var isMac: Bool {
        self.category == .MacBook || self.category == .iMac
    }

    var isiPhone: Bool {
        self.category == .iPhone
    }

    var isiPad: Bool {
        self.category == .iPad
    }

    var category: DeviceCategory {
        switch self {
        case .iMac:
            .iMac
        case .MacBook:
            .MacBook
        case .iPad_mini:
            .iPad
        case .iPhoneBig, .iPhone_15, .iPhoneSmall, .iPhone_SE:
            .iPhone
        }
    }

    var description: String {
        self.rawValue
    }

    var width: CGFloat {
        switch self {
        case .iMac:
            4480
        case .MacBook:
            2880
        case .iPhoneBig:
            1290
        case .iPhoneSmall:
            1242
        case .iPad_mini:
            1488
        case .iPhone_15:
            1179
        case .iPhone_SE:
            750
        }
    }

    var height: CGFloat {
        switch self {
        case .iMac:
            2520
        case .MacBook:
            1800
        case .iPhoneBig:
            2796
        case .iPhoneSmall:
            2208
        case .iPad_mini:
            2266
        case .iPhone_15:
            2556
        case .iPhone_SE:
            1334
        }
    }
}

enum DeviceCategory: String, Equatable {
    case iMac
    case MacBook
    case iPhone
    case iPad

    var description: String {
        switch self {
        case .iMac:
            return "iMac"
        case .MacBook:
            return "MacBook"
        case .iPad:
            return "iPad"
        case .iPhone:
            return "iPhone"
        }
    }
}
