import Foundation
import OSLog
import SwiftUI

/// 系统信息相关的Shell命令工具类
class ShellSystem: SuperLog {
    static let emoji = "💻"
    
    /// 获取当前工作目录
    /// - Returns: 当前工作目录路径
    static func pwd() -> String {
        do {
            return try Shell.run("pwd").trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 获取当前用户名
    /// - Returns: 当前用户名
    static func whoami() -> String {
        do {
            return try Shell.run("whoami").trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 获取系统信息
    /// - Returns: 系统信息字符串
    static func uname() -> String {
        do {
            return try Shell.run("uname -a").trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 获取系统版本
    /// - Returns: 系统版本信息
    static func systemVersion() -> String {
        do {
            return try Shell.run("sw_vers").trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 获取CPU信息
    /// - Returns: CPU信息
    static func cpuInfo() -> String {
        do {
            return try Shell.run("sysctl -n machdep.cpu.brand_string").trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 获取内存信息
    /// - Returns: 内存信息
    static func memoryInfo() -> String {
        do {
            let totalMemory = try Shell.run("sysctl -n hw.memsize")
            let memoryGB = Double(totalMemory.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
            return String(format: "%.1f GB", memoryGB / 1024 / 1024 / 1024)
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 获取磁盘使用情况
    /// - Parameter path: 路径（默认为根目录）
    /// - Returns: 磁盘使用情况
    static func diskUsage(path: String = "/") -> String {
        do {
            let command = "df -h '\(path)'"
            return try Shell.run(command).trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 获取系统负载
    /// - Returns: 系统负载信息
    static func loadAverage() -> String {
        do {
            return try Shell.run("uptime").trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 获取运行中的进程
    /// - Parameter processName: 进程名（可选）
    /// - Returns: 进程信息
    static func processes(named processName: String? = nil) -> String {
        do {
            if let name = processName {
                let command = "ps aux | grep '\(name)' | grep -v grep"
                return try Shell.run(command)
            } else {
                return try Shell.run("ps aux")
            }
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 获取网络接口信息
    /// - Returns: 网络接口信息
    static func networkInterfaces() -> String {
        do {
            return try Shell.run("ifconfig")
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 获取环境变量
    /// - Parameter name: 环境变量名
    /// - Returns: 环境变量值
    static func getEnvironmentVariable(_ name: String) -> String {
        do {
            let command = "echo \"$\(name)\""
            return try Shell.run(command).trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 获取PATH环境变量
    /// - Returns: PATH环境变量值
    static func getPath() -> [String] {
        let pathString = getEnvironmentVariable("PATH")
        return pathString.components(separatedBy: ":")
    }
    
    /// 检查命令是否存在
    /// - Parameter command: 命令名
    /// - Returns: 命令是否存在
    static func commandExists(_ command: String) -> Bool {
        do {
            _ = try Shell.run("which \(command)")
            return true
        } catch {
            return false
        }
    }
    
    /// 获取系统时间
    /// - Returns: 系统时间
    static func systemTime() -> String {
        do {
            return try Shell.run("date").trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 获取系统启动时间
    /// - Returns: 系统启动时间
    static func bootTime() -> String {
        do {
            return try Shell.run("sysctl -n kern.boottime").trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return error.localizedDescription
        }
    }
}
