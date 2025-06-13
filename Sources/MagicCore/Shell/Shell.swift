import Foundation
import OSLog
import SwiftUI

/// Shell命令执行的核心类
/// 提供基础的Shell命令执行功能
class Shell: SuperLog {
    static let emoji = "🐚"
    
    /// 执行Shell命令
    /// - Parameters:
    ///   - command: 要执行的命令
    ///   - path: 执行命令的工作目录（可选）
    ///   - verbose: 是否输出详细日志
    /// - Returns: 命令执行结果
    /// - Throws: 命令执行失败时抛出错误
    static func run(_ command: String, at path: String? = nil, verbose: Bool = false) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]

        if let path = path {
            process.currentDirectoryURL = URL(fileURLWithPath: path)
        }

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        let outputHandle = pipe.fileHandleForReading
        var outputData = Data()

        outputHandle.readabilityHandler = { handle in
            outputData.append(handle.availableData)
        }

        try process.run()
        process.waitUntilExit()

        outputHandle.readabilityHandler = nil

        let output = String(data: outputData, encoding: .utf8) ?? ""

        if verbose {
            os_log("\(self.t) ➡️ Path: \(path ?? "Current Directory")")
            os_log("\(self.t) ➡️ Command: \(command)")
            os_log("\(self.t) ➡️ Output: \(output)")
        }

        if process.terminationStatus != 0 {
            if verbose {
                os_log("\(self.t) ❌ Command failed")
                os_log("\(self.t) ➡️ Path: \(path ?? "Current Directory")")
                os_log("\(self.t) ➡️ Command: \(command)")
                os_log("\(self.t) ➡️ Output: \(output)")
                os_log("\(self.t) ➡️ Exit code: \(process.terminationStatus)")
            }
            throw ShellError.commandFailed(output + "\n" + command)
        }

        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 异步执行Shell命令
    /// - Parameters:
    ///   - command: 要执行的命令
    ///   - path: 执行命令的工作目录（可选）
    ///   - verbose: 是否输出详细日志
    /// - Returns: 命令执行结果
    static func runAsync(_ command: String, at path: String? = nil, verbose: Bool = false) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                do {
                    let result = try run(command, at: path, verbose: verbose)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// 执行多个命令
    /// - Parameters:
    ///   - commands: 命令数组
    ///   - path: 执行命令的工作目录（可选）
    ///   - verbose: 是否输出详细日志
    /// - Returns: 所有命令的执行结果数组
    /// - Throws: 任何命令执行失败时抛出错误
    static func runMultiple(_ commands: [String], at path: String? = nil, verbose: Bool = false) throws -> [String] {
        var results: [String] = []
        
        for command in commands {
            let result = try run(command, at: path, verbose: verbose)
            results.append(result)
        }
        
        return results
    }
    
    /// 执行命令并返回退出状态码
    /// - Parameters:
    ///   - command: 要执行的命令
    ///   - path: 执行命令的工作目录（可选）
    ///   - verbose: 是否输出详细日志
    /// - Returns: 元组包含输出和退出状态码
    static func runWithStatus(_ command: String, at path: String? = nil, verbose: Bool = false) -> (output: String, exitCode: Int32) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]

        if let path = path {
            process.currentDirectoryURL = URL(fileURLWithPath: path)
        }

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        let outputHandle = pipe.fileHandleForReading
        var outputData = Data()

        outputHandle.readabilityHandler = { handle in
            outputData.append(handle.availableData)
        }

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return ("执行失败: \(error.localizedDescription)", -1)
        }

        outputHandle.readabilityHandler = nil

        let output = String(data: outputData, encoding: .utf8) ?? ""

        if verbose {
            os_log("\(self.t)\(command)")
            os_log("\(output)")
            os_log("\(self.t)Exit code: \(process.terminationStatus)")
        }

        return (output.trimmingCharacters(in: .whitespacesAndNewlines), process.terminationStatus)
    }
    
    /// 检查命令是否可用
    /// - Parameter command: 命令名
    /// - Returns: 命令是否可用
    static func isCommandAvailable(_ command: String) -> Bool {
        do {
            _ = try run("which \(command)")
            return true
        } catch {
            return false
        }
    }
    
    /// 获取命令的完整路径
    /// - Parameter command: 命令名
    /// - Returns: 命令的完整路径
    static func getCommandPath(_ command: String) -> String? {
        do {
            let path = try run("which \(command)")
            return path.isEmpty ? nil : path
        } catch {
            return nil
        }
    }
    
    /// 配置Git凭证缓存
    /// - Returns: 配置结果
    static func configureGitCredentialCache() -> String {
        do {
            return try self.run("git config --global credential.helper cache")
        } catch {
            return error.localizedDescription
        }
    }
}

// MARK: - Preview

#Preview("Shell Demo") {
    VStack(spacing: 20) {
        Text("🐚 Shell 核心功能演示")
            .font(.title)
            .bold()
        
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                VDemoSection(title: "基础命令", icon: "⚡") {
                    VDemoButtonWithLog("获取当前目录", action: {
                        do {
                            let pwd = try Shell.run("pwd")
                            return "当前目录: \(pwd)"
                        } catch {
                            return "获取当前目录失败: \(error.localizedDescription)"
                        }
                    })
                    
                    VDemoButtonWithLog("获取当前用户", action: {
                        do {
                            let user = try Shell.run("whoami")
                            return "当前用户: \(user)"
                        } catch {
                            return "获取当前用户失败: \(error.localizedDescription)"
                        }
                    })
                    
                    VDemoButtonWithLog("获取系统时间", action: {
                        do {
                            let date = try Shell.run("date")
                            return "系统时间: \(date)"
                        } catch {
                            return "获取系统时间失败: \(error.localizedDescription)"
                        }
                    })
                }
                
                VDemoSection(title: "命令检查", icon: "🔍") {
                    VCommandAvailabilityRow("git")
                    VCommandAvailabilityRow("node")
                    VCommandAvailabilityRow("python3")
                    VCommandAvailabilityRow("docker")
                    VCommandAvailabilityRow("nonexistent_command")
                }
                
                VDemoSection(title: "多命令执行", icon: "📋") {
                    VDemoButtonWithLog("执行多个命令", action: {
                        do {
                            let commands = ["echo 'Hello'", "echo 'World'", "date"]
                            let results = try Shell.runMultiple(commands)
                            return "多命令执行结果:\n" + results.enumerated().map { "命令\($0.offset + 1): \($0.element)" }.joined(separator: "\n")
                        } catch {
                            return "多命令执行失败: \(error.localizedDescription)"
                        }
                    })
                }
                
                VDemoSection(title: "状态码检查", icon: "📊") {
                    VDemoButtonWithLog("成功命令（echo）", action: {
                        let (output, exitCode) = Shell.runWithStatus("echo 'Hello World'")
                        return "输出: \(output)\n退出码: \(exitCode)"
                    })
                    
                    VDemoButtonWithLog("失败命令（不存在的命令）", action: {
                        let (output, exitCode) = Shell.runWithStatus("nonexistent_command_12345")
                        return "输出: \(output)\n退出码: \(exitCode)"
                    })
                }
                
                VDemoSection(title: "异步执行", icon: "⏱️") {
                    VAsyncCommandButton()
                }
                
                VDemoSection(title: "Git配置", icon: "🔧") {
                    VDemoButtonWithLog("配置Git凭证缓存", action: {
                        let result = Shell.configureGitCredentialCache()
                        return "Git凭证缓存配置结果: \(result)"
                    })
                }
            }
            .padding()
        }
    }
    .padding()
    .inMagicContainer()
}
