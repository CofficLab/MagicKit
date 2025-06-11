import Foundation
import OSLog
import SwiftUI

/// 文件操作相关的Shell命令工具类
class ShellFile: SuperLog {
    static let emoji = "📁"
    
    /// 检查目录是否存在
    /// - Parameter dir: 目录路径
    /// - Returns: 目录是否存在
    func isDirExists(_ dir: String) -> Bool {
        do {
            let result = try Shell.run("""
                if [ ! -d "\(dir)" ]; then
                    echo "false"
                else
                    echo "true"
                fi
            """)
            return result.trimmingCharacters(in: .whitespacesAndNewlines) == "true"
        } catch {
            os_log("\(self.t)检查目录存在性失败: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 检查文件是否存在
    /// - Parameter path: 文件路径
    /// - Returns: 文件是否存在
    func isFileExists(_ path: String) -> Bool {
        do {
            let result = try Shell.run("""
                if [ ! -f "\(path)" ]; then
                    echo "false"
                else
                    echo "true"
                fi
            """)
            return result.trimmingCharacters(in: .whitespacesAndNewlines) == "true"
        } catch {
            os_log("\(self.t)检查文件存在性失败: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 创建目录
    /// - Parameters:
    ///   - dir: 目录路径
    ///   - verbose: 是否输出详细日志
    func makeDir(_ dir: String, verbose: Bool = false) {
        if verbose {
            os_log("\(self.t)MakeDir -> \(dir)")
        }
        
        do {
            _ = try Shell.run("""
                if [ ! -d "\(dir)" ]; then
                    mkdir -p "\(dir)"
                else
                    echo "\(dir) 已经存在"
                fi
            """)
        } catch {
            os_log("\(self.t)创建目录失败: \(error.localizedDescription)")
        }
    }
    
    /// 创建文件并写入内容
    /// - Parameters:
    ///   - path: 文件路径
    ///   - content: 文件内容
    func makeFile(_ path: String, content: String) {
        do {
            let escapedContent = content.replacingOccurrences(of: "\"", with: "\\\"")
            _ = try Shell.run("echo \"\(escapedContent)\" > \"\(path)\"")
        } catch {
            os_log("\(self.t)创建文件失败: \(error.localizedDescription)")
        }
    }
    
    /// 获取文件内容
    /// - Parameter path: 文件路径
    /// - Returns: 文件内容
    /// - Throws: 读取失败时抛出错误
    func getFileContent(_ path: String) throws -> String {
        try Shell.run("cat \"\(path)\"")
    }
    
    /// 删除文件或目录
    /// - Parameter path: 文件或目录路径
    /// - Throws: 删除失败时抛出错误
    func remove(_ path: String) throws {
        try Shell.run("rm -rf \"\(path)\"")
    }
    
    /// 复制文件或目录
    /// - Parameters:
    ///   - source: 源路径
    ///   - destination: 目标路径
    /// - Throws: 复制失败时抛出错误
    func copy(_ source: String, to destination: String) throws {
        try Shell.run("cp -r \"\(source)\" \"\(destination)\"")
    }
    
    /// 移动文件或目录
    /// - Parameters:
    ///   - source: 源路径
    ///   - destination: 目标路径
    /// - Throws: 移动失败时抛出错误
    func move(_ source: String, to destination: String) throws {
        try Shell.run("mv \"\(source)\" \"\(destination)\"")
    }
    
    /// 获取文件大小
    /// - Parameter path: 文件路径
    /// - Returns: 文件大小（字节）
    /// - Throws: 获取失败时抛出错误
    func getFileSize(_ path: String) throws -> Int {
        let result = try Shell.run("stat -f%z \"\(path)\"")
        return Int(result.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
    }
    
    /// 获取目录下的文件列表
    /// - Parameter dir: 目录路径
    /// - Returns: 文件名数组
    /// - Throws: 获取失败时抛出错误
    func listFiles(_ dir: String) throws -> [String] {
        let result = try Shell.run("ls -1 \"\(dir)\"")
        return result.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    /// 获取文件权限
    /// - Parameter path: 文件路径
    /// - Returns: 权限字符串
    /// - Throws: 获取失败时抛出错误
    func getPermissions(_ path: String) throws -> String {
        try Shell.run("stat -f%Sp \"\(path)\"")
    }
    
    /// 修改文件权限
    /// - Parameters:
    ///   - path: 文件路径
    ///   - permissions: 权限（如 "755"）
    /// - Throws: 修改失败时抛出错误
    func changePermissions(_ path: String, permissions: String) throws {
        try Shell.run("chmod \(permissions) \"\(path)\"")
    }
}

// MARK: - Preview

#Preview("ShellFile Demo") {
    ShellFilePreviewView()
        .inMagicContainer()
}
