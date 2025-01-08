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

public enum iCloudStorageError: Error {
    case notLoggedIn
    case unavailable
    case capacityNotFound
    case platformNotSupported
    case unknownError(Error)
    
    public var localizedDescription: String {
        switch self {
        case .notLoggedIn:
            return "iCloud 未登录"
        case .unavailable:
            return "iCloud 不可用"
        case .capacityNotFound:
            return "无法获取 iCloud 存储容量"
        case .platformNotSupported:
            return "当前平台不支持 iCloud"
        case .unknownError(let underlyingError):
            return "获取 iCloud 存储容量失败: \(underlyingError.localizedDescription)"
        }
    }
}

public class MagicApp {
    // 缓存设备信息
    private static var cachedDeviceModel: String?
    
    // 将平台判断逻辑改为静态计算属性
    public static var currentPlatform: String {
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

    public static func getVersion() -> String {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            // 增加错误日志
            print("Warning: Failed to get app version from Info.plist")
            return "Unknown"
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
    
    public static func getDeviceName() -> String {
            #if os(macOS)
            return Host.current().localizedName ?? "Unknown"
            #elseif os(iOS) || os(visionOS)
            return UIDevice.current.name
            #endif
        }

        public static func getDeviceModel() -> String {
            if let cached = cachedDeviceModel {
                return cached
            }
            
            var size: Int = 0
            sysctlbyname("hw.model", nil, &size, nil, 0)
            var model = [CChar](repeating: 0, count: size)
            sysctlbyname("hw.model", &model, &size, nil, 0)
            
            let result = String(cString: model)
            cachedDeviceModel = result
            return result
        }

        public static func getSystemName() -> String {
            return currentPlatform
        }

        public static func getSystemVersion() -> String {
            if let version = ProcessInfo.processInfo.operatingSystemVersionString.split(separator: " ").last {
                return String(version)
            }
            return "Unknown"
        }

        public static func getBuildNumber() -> String {
            guard let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String else {
                print("Warning: Failed to get build number from Info.plist")
                return "Unknown"
            }
            return build
        }
        
        public static func getBundleIdentifier() -> String {
            return Bundle.main.bundleIdentifier ?? "Unknown"
        }
        
        public static func getAvailableStorage() -> Int64? {
            do {
                let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
                return (systemAttributes[.systemFreeSize] as? NSNumber)?.int64Value
            } catch {
                print("Error getting storage info: \(error)")
                return nil
            }
        }
        
        public static func getTotalStorage() -> Int64? {
            do {
                let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
                return (systemAttributes[.systemSize] as? NSNumber)?.int64Value
            } catch {
                print("Error getting storage info: \(error)")
                return nil
            }
        }
        
        public static func formatBytes(bytes: Int64) -> String {
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
            formatter.countStyle = .file
            return formatter.string(fromByteCount: bytes)
        }

        /// 获取 iCloud 总容量（以字节为单位）
        ///
        /// - Throws: `iCloudStorageError` 描述具体的错误原因
        /// - Returns: iCloud 总容量（字节）
        public static func getICloudTotalStorage() throws -> Int64 {
            #if os(macOS) || os(iOS) || os(tvOS)
            let url = FileManager.default.url(forUbiquityContainerIdentifier: nil)
            
            guard let url = url else {
                throw iCloudStorageError.notLoggedIn
            }
            
            do {
                let values = try url.resourceValues(forKeys: [.volumeTotalCapacityKey])
                guard let capacity = values.volumeTotalCapacity else {
                    throw iCloudStorageError.capacityNotFound
                }
                return Int64(capacity)
            } catch {
                throw iCloudStorageError.unknownError(error)
            }
            #else
            throw iCloudStorageError.platformNotSupported
            #endif
        }
        
        /// 获取 iCloud 可用容量（以字节为单位）
        ///
        /// - Throws: `iCloudStorageError` 描述具体的错误原因
        /// - Returns: iCloud 可用容量（字节）
        public static func getICloudAvailableStorage() throws -> Int64 {
            #if os(macOS) || os(iOS) || os(tvOS)
            let url = FileManager.default.url(forUbiquityContainerIdentifier: nil)
            
            guard let url = url else {
                throw iCloudStorageError.notLoggedIn
            }
            
            do {
                let values = try url.resourceValues(forKeys: [.volumeAvailableCapacityKey])
                guard let capacity = values.volumeAvailableCapacity else {
                    throw iCloudStorageError.capacityNotFound
                }
                return Int64(capacity)
            } catch {
                throw iCloudStorageError.unknownError(error)
            }
            #else
            throw iCloudStorageError.platformNotSupported
            #endif
        }

        /// 获取系统运行时间（秒）
        ///
        /// - Returns: 系统已运行的秒数
        public static func getUptime() -> TimeInterval {
            var boottime = timeval()
            var size = MemoryLayout<timeval>.size
            var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
            
            if sysctl(&mib, 2, &boottime, &size, nil, 0) != -1 {
                let now = Date().timeIntervalSince1970
                let uptime = now - Double(boottime.tv_sec)
                return uptime
            }
            
            return 0
        }

        /// 获取系统启动时间
        ///
        /// - Returns: 系统启动的日期
        public static func getBootTime() -> Date {
            let uptime = getUptime()
            return Date(timeIntervalSinceNow: -uptime)
        }

        /// 获取格式化的系统启动时间
        ///
        /// - Returns: 格式化的启动时间字符串，例如："2024-03-15 08:30:00"
        public static func getFormattedBootTime() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateFormatter.string(from: getBootTime())
        }

        /// 获取详细的运行时间信息
        ///
        /// - Returns: 包含天、小时、分钟、秒的元组
        public static func getDetailedUptime() -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
            let totalSeconds = Int(getUptime())
            let days = totalSeconds / (24 * 3600)
            let hours = (totalSeconds % (24 * 3600)) / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60
            return (days, hours, minutes, seconds)
        }

        /// 格式化运行时间为详细字符串
        ///
        /// - Returns: 格式化的运行时间字符串，例如："2天 3小时 45分钟 30秒"
        public static func getDetailedUptimeString() -> String {
            let uptime = getDetailedUptime()
            var components: [String] = []
            
            if uptime.days > 0 { components.append("\(uptime.days)天") }
            if uptime.hours > 0 { components.append("\(uptime.hours)小时") }
            if uptime.minutes > 0 { components.append("\(uptime.minutes)分钟") }
            if uptime.seconds > 0 || components.isEmpty { components.append("\(uptime.seconds)秒") }
            
            return components.joined(separator: " ")
        }
}

#Preview {
    MagicAppDemoView()
}
