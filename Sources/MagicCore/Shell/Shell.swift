import Foundation
import OSLog
import SwiftUI

/// Shell命令执行的核心类
/// 提供基础的Shell命令执行功能
class Shell: SuperLog {
    static let emoji = "🐚"

    /// 异步执行Shell命令
    /// - Parameters:
    ///   - command: 要执行的命令
    ///   - path: 执行命令的工作目录（可选）
    ///   - verbose: 是否输出详细日志
    /// - Returns: 命令执行结果
    /// - Throws: 执行失败时抛出错误
    static func run(_ command: String, at path: String? = nil, verbose: Bool = false) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            // 在后台队列执行，避免阻塞调用线程
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/bin/bash")
                process.arguments = ["-c", command]

                if let path = path {
                    process.currentDirectoryURL = URL(fileURLWithPath: path)
                }

                let outputPipe = Pipe()
                let errorPipe = Pipe()
                process.standardOutput = outputPipe
                process.standardError = errorPipe

                do {
                    try process.run()
                    
                    // 使用同步方式读取数据，避免异步handler的竞态条件
                    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                    
                    // 等待进程完成
                    process.waitUntilExit()
                    
                    // 转换数据到字符串
                    let output = String(data: outputData, encoding: .utf8) ?? ""
                    let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
                    
                    // 合并标准输出和错误输出
                    let combinedOutput = errorOutput.isEmpty ? output : "\(output)\n\(errorOutput)"

                    if verbose {
                        os_log("\(self.t) \n➡️ Path: \n\(path ?? "Current Directory") (\(FileManager.default.currentDirectoryPath)) \n➡️ Command: \n\(command) \n➡️ Output: \n\(combinedOutput)")
                    }

                    if process.terminationStatus != 0 {
                        os_log(.error, "\(self.t) ❌ Command failed \n ➡️ Path: \(path ?? "Current Directory") (\(FileManager.default.currentDirectoryPath)) \n ➡️ Command: \(command) \n ➡️ Output: \(combinedOutput) \n ➡️ Exit code: \(process.terminationStatus)")
                        continuation.resume(throwing: ShellError.commandFailed(combinedOutput, command))
                    } else {
                        let trimmedOutput = output.trimmingCharacters(in: .whitespacesAndNewlines)
                        continuation.resume(returning: trimmedOutput)
                    }
                } catch {
                    continuation.resume(throwing: ShellError.processStartFailed(error.localizedDescription))
                }
            }
        }
    }

    /// 同步执行Shell命令（向后兼容，内部调用异步版本）
    /// - Parameters:
    ///   - command: 要执行的命令
    ///   - path: 执行命令的工作目录（可选）
    ///   - verbose: 是否输出详细日志
    /// - Returns: 命令执行结果
    /// - Throws: 执行失败时抛出错误
    static func runSync(_ command: String, at path: String? = nil, verbose: Bool = false) throws -> String {
        // 使用 RunLoop 来同步等待异步操作完成，避免阻塞主线程
        var result: Result<String, Error>?
        
        Task {
            do {
                let output = try await run(command, at: path, verbose: verbose)
                result = .success(output)
            } catch {
                result = .failure(error)
            }
        }
        
        // 使用 RunLoop 等待结果，不会阻塞主线程
        while result == nil {
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01))
        }
        
        switch result! {
        case .success(let output):
            return output
        case .failure(let error):
            throw error
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
            let result = try runSync(command, at: path, verbose: verbose)
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
        
        // 使用信号量来确保数据读取完成
        let semaphore = DispatchSemaphore(value: 0)
        var isReadingComplete = false

        outputHandle.readabilityHandler = { handle in
            let data = handle.availableData
            if data.isEmpty {
                // 数据读取完成
                isReadingComplete = true
                semaphore.signal()
            } else {
                outputData.append(data)
            }
        }

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return ("执行失败: \(error.localizedDescription)", -1)
        }

        // 等待数据读取完成，最多等待1秒
        let result = semaphore.wait(timeout: .now() + 1.0)
        
        // 清理 handler
        outputHandle.readabilityHandler = nil
        
        // 如果超时，尝试读取剩余数据
        if result == .timedOut || !isReadingComplete {
            let remainingData = outputHandle.readDataToEndOfFile()
            if !remainingData.isEmpty {
                outputData.append(remainingData)
            }
        }

        guard let output = String(data: outputData, encoding: .utf8) else {
            return ("字符串转换失败: 无法将输出数据转换为UTF-8字符串，数据大小: \(outputData.count) 字节", -2)
        }

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
            _ = try runSync("which \(command)")
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
            let path = try runSync("which \(command)")
            return path.isEmpty ? nil : path
        } catch {
            return nil
        }
    }

    /// 配置Git凭证缓存
    /// - Returns: 配置结果
    static func configureGitCredentialCache() -> String {
        do {
            return try self.runSync("git config --global credential.helper cache")
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
                            let pwd = try Shell.runSync("pwd")
                            return "当前目录: \(pwd)"
                        } catch {
                            return "获取当前目录失败: \(error.localizedDescription)"
                        }
                    })

                    VDemoButtonWithLog("获取当前用户", action: {
                        do {
                            let user = try Shell.runSync("whoami")
                            return "当前用户: \(user)"
                        } catch {
                            return "获取当前用户失败: \(error.localizedDescription)"
                        }
                    })

                    VDemoButtonWithLog("获取系统时间", action: {
                        do {
                            let date = try Shell.runSync("date")
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

                VDemoSection(title: "错误处理", icon: "⚠️") {
                    VDemoButtonWithLog("测试字符串转换错误", action: {
                        // 注意：这个测试在正常情况下不会触发错误，因为大多数命令输出都是有效的UTF-8
                        // 这里只是展示错误处理的结构
                        do {
                            let result = try Shell.runSync("echo 'Test UTF-8 conversion'")
                            return "字符串转换成功: \(result)"
                        } catch let error as ShellError {
                            switch error {
                            case .stringConversionFailed(let data):
                                return "字符串转换失败: 数据大小 \(data.count) 字节"
                            case .commandFailed(let output, let command):
                                return "命令执行失败: \(command)\n输出: \(output)"
                            case .processStartFailed(let message):
                                return "进程启动失败: \(message)"
                            }
                        } catch {
                            return "未知错误: \(error.localizedDescription)"
                        }
                    })
                }

                VDemoSection(title: "稳定性测试", icon: "🔄") {
                    VDemoButtonWithLog("测试 git diff-tree 稳定性", action: {
                        // 模拟你遇到的问题：多次执行同一个 git 命令
                        var results: [String] = []
                        let testCommand = "git log --oneline -1"
                        
                        for i in 1...5 {
                            do {
                                let result = try Shell.runSync(testCommand)
                                let status = result.isEmpty ? "❌ 空结果" : "✅ 正常"
                                results.append("第\(i)次: \(status) - 长度: \(result.count)")
                            } catch {
                                results.append("第\(i)次: ❌ 错误 - \(error.localizedDescription)")
                            }
                        }
                        
                        return "Git命令稳定性测试结果:\n" + results.joined(separator: "\n")
                    })
                    
                    VDemoButtonWithLog("测试快速连续执行", action: {
                        // 测试快速连续执行多个命令
                        var results: [String] = []
                        let commands = ["echo 'test1'", "echo 'test2'", "echo 'test3'", "date", "whoami"]
                        
                        for (index, command) in commands.enumerated() {
                            do {
                                let result = try Shell.runSync(command)
                                let status = result.isEmpty ? "❌ 空结果" : "✅ 正常"
                                results.append("命令\(index + 1): \(status) - \(result.prefix(20))")
                            } catch {
                                results.append("命令\(index + 1): ❌ 错误 - \(error.localizedDescription)")
                            }
                        }
                        
                        return "快速连续执行测试结果:\n" + results.joined(separator: "\n")
                    })
                }
            }
            .padding()
        }
    }
    .padding()
    .inMagicContainer()
}
