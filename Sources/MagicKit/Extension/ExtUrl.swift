import Foundation
import CryptoKit
import OSLog
import SwiftUI

/// URL 类型的扩展，提供常用的工具方法
extension URL: SuperLog {
    public static var emoji = "🌉"
}

/// URL 类型的扩展，提供文件操作和路径处理功能
public extension URL {
    /// 计算文件的 MD5 哈希值
    /// 
    /// 用于获取文件的唯一标识或验证文件完整性
    /// ```swift
    /// let fileURL = URL(fileURLWithPath: "/path/to/file.txt")
    /// let hash = fileURL.getHash() // "d41d8cd98f00b204e9800998ecf8427e"
    /// ```
    /// - Parameter verbose: 是否打印详细日志，默认为 false
    /// - Returns: 文件的 MD5 哈希值字符串，如果是文件夹或计算失败则返回空字符串
    func getHash(verbose: Bool = false) -> String {
        if self.isFolder {
            return ""
        }

        do {
            let bufferSize = 1024
            var hash = Insecure.MD5()
            let fileHandle = try FileHandle(forReadingFrom: self)
            defer { fileHandle.closeFile() }

            while autoreleasepool(invoking: {
                let data = fileHandle.readData(ofLength: bufferSize)
                hash.update(data: data)
                return data.count > 0
            }) {}

            return hash.finalize().map { String(format: "%02hhx", $0) }.joined()
        } catch {
            os_log(.error, "计算MD5出错 -> \(error.localizedDescription)")
            print(error)
            return ""
        }
    }

    /// 获取文件内容的 Base64 编码或文本内容
    /// 
    /// 如果是图片文件，返回 Base64 编码；如果是文本文件，返回文本内容
    /// ```swift
    /// let imageURL = URL(fileURLWithPath: "/path/to/image.jpg")
    /// let base64 = try imageURL.getBlob() // "data:image/jpeg;base64,..."
    /// ```
    /// - Returns: 文件内容的 Base64 编码或文本内容
    /// - Throws: 读取文件失败时抛出错误
    func getBlob() throws -> String {
        if self.isImage {
            do {
                let data = try Data(contentsOf: self)
                return data.base64EncodedString()
            } catch {
                os_log(.error, "读取文件失败: \(error)")
                return ""
            }
        } else {
            return try self.getContent()
        }
    }

    /// 读取文件文本内容
    /// 
    /// ```swift
    /// let fileURL = URL(fileURLWithPath: "/path/to/file.txt")
    /// let content = try fileURL.getContent() // "文件内容..."
    /// ```
    /// - Returns: 文件的文本内容
    /// - Throws: 读取文件失败时抛出错误
    func getContent() throws -> String {
        do {
            return try String(contentsOfFile: self.path, encoding: .utf8)
        } catch {
            os_log(.error, "读取文件时发生错误: \(error)")
            throw error
        }
    }

    /// 获取父目录路径
    /// 
    /// ```swift
    /// let fileURL = URL(fileURLWithPath: "/path/to/file.txt")
    /// let parent = fileURL.getParent() // "/path/to"
    /// ```
    /// - Returns: 父目录的 URL
    func getParent() -> URL {
        self.deletingLastPathComponent()
    }

    /// 判断是否为文件夹
    var isFolder: Bool { self.hasDirectoryPath }

    /// 判断是否不是文件夹
    var isNotFolder: Bool { !isFolder }

    /// 获取文件或文件夹名称
    var name: String { self.lastPathComponent }

    /// 获取下一个文件
    func next() -> URL? {
        self.getNextFile()
    }

    /// 获取最近的文件夹路径
    /// 
    /// 如果当前路径是文件夹，返回自身；如果是文件，返回父目录
    /// ```swift
    /// let fileURL = URL(fileURLWithPath: "/path/to/file.txt")
    /// let folder = fileURL.nearestFolder() // "/path/to"
    /// ```
    /// - Returns: 最近的文件夹 URL
    func nearestFolder() -> URL {
        self.isFolder ? self : self.deletingLastPathComponent()
    }

    /// 获取空设备路径
    static var null: URL {
        URL(filePath: "/dev/null")
    }

    /// 读取文件头部字节
    /// 
    /// 用于判断文件类型
    /// ```swift
    /// let fileURL = URL(fileURLWithPath: "/path/to/image.jpg")
    /// let header = fileURL.readFileHeader(length: 3) // [0xFF, 0xD8, 0xFF]
    /// ```
    /// - Parameter length: 要读取的字节数
    /// - Returns: 文件头部字节数组，读取失败时返回 nil
    func readFileHeader(length: Int) -> [UInt8]? {
        do {
            let fileData = try Data(contentsOf: self, options: .mappedIfSafe)
            return Array(fileData.prefix(length))
        } catch {
            print("读取文件头时出错: \(error)")
            return nil
        }
    }

    /// 移除路径开头的斜杠
    /// 
    /// ```swift
    /// let url = URL(string: "/path/to/file")!
    /// let path = url.removingLeadingSlashes() // "path/to/file"
    /// ```
    /// - Returns: 移除开头斜杠后的路径字符串
    func removingLeadingSlashes() -> String {
        return self.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    /// 获取简短标题
    var title: String { self.lastPathComponent.mini() }

    /// 添加请求体
    /// - Parameter body: 请求体参数
    /// - Returns: HTTP 客户端实例
    func withBody(_ body: [String: Any]) -> HttpClient {
        HttpClient(url: self).withBody(body)
    }

    /// 添加认证令牌
    /// - Parameter token: 认证令牌
    /// - Returns: HTTP 客户端实例
    func withToken(_ token: String) -> HttpClient {
        HttpClient(url: self).withToken(token)
    }

    // MARK: - 文件类型判断

    /// 文件类型签名字典
    var imageSignatures: [String: [UInt8]] {
        [
            "jpg": [0xFF, 0xD8, 0xFF],
            "png": [0x89, 0x50, 0x4E, 0x47],
            "gif": [0x47, 0x49, 0x46],
            "bmp": [0x42, 0x4D],
            "webp": [0x52, 0x49, 0x46, 0x46],
        ]
    }

    /// 生成默认音频缩略图
    /// - Parameter size: 缩略图大小
    /// - Returns: 音频缩略图
    func defaultAudioThumbnail(size: CGSize) -> Image {
        #if os(macOS)
            if let defaultIcon = NSImage(systemSymbolName: .iconMusicNote, accessibilityDescription: nil) {
                let resizedIcon = defaultIcon.resize(to: size)
                return Image(nsImage: resizedIcon)
            }
            return Image(systemName: .iconMusicNote)
        #else
            if let defaultIcon = UIImage(systemName: .iconMusicNote) {
                let resizedIcon = defaultIcon.resize(to: size)
                return Image(uiImage: resizedIcon)
            }
            return Image(systemName: .iconMusicNote)
        #endif
    }

    /// 获取路径的最后三个组件
    /// 
    /// 用于显示较长路径的简短版本
    /// ```swift
    /// let url = URL(string: "file:///path/to/folder/documents/report.pdf")!
    /// print(url.shortPath()) // "folder/documents/report.pdf"
    /// ```
    /// - Returns: 包含最后三个路径组件的字符串
    func shortPath() -> String {
        self.lastThreeComponents()
    }

    /// 获取路径的最后三个组件
    /// 
    /// ```swift
    /// let url = URL(string: "file:///path/to/folder/a/b/c.png")!
    /// print(url.lastThreeComponents()) // "a/b/c.png"
    /// ```
    /// - Returns: 最后三个路径组件组成的字符串
    func lastThreeComponents() -> String {
        let components = self.pathComponents.filter { $0 != "/" }
        let lastThree = components.suffix(3)
        return lastThree.joined(separator: "/")
    }

    /// 添加文件夹到路径末尾
    /// 
    /// ```swift
    /// let url = URL(string: "file:///path/to")!
    /// let newUrl = url.appendingFolder("documents")
    /// // 结果: "file:///path/to/documents"
    /// ```
    /// - Parameter folderName: 要添加的文件夹名称
    /// - Returns: 添加文件夹后的新 URL
    func appendingFolder(_ folderName: String) -> URL {
        let cleanFolderName = folderName.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return self.appendingPathComponent(cleanFolderName, isDirectory: true)
    }

    /// 添加文件到路径末尾
    /// 
    /// ```swift
    /// let url = URL(string: "file:///path/to")!
    /// let newUrl = url.appendingFile("document.txt")
    /// // 结果: "file:///path/to/document.txt"
    /// ```
    /// - Parameter fileName: 要添加的文件名
    /// - Returns: 添加文件后的新 URL
    func appendingFile(_ fileName: String) -> URL {
        let cleanFileName = fileName.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return self.appendingPathComponent(cleanFileName, isDirectory: false)
    }
}

/// URL 扩展功能演示视图
struct URLExtensionDemoView: View {
    var body: some View {
        TabView {
            // 路径操作演示
            MagicThemePreview {
                VStack(spacing: 20) {
                    // 基础路径操作
                    VStack(alignment: .leading, spacing: 12) {
                        Text("基础路径操作")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 8) {
                            let url = URL(string: "/path/to/folder/file.txt")!
                            MagicKeyValue(key: "url.name", value: url.name) {
                                Image(systemName: .iconDocument)
                            }
                            MagicKeyValue(key: "url.shortPath()", value: url.shortPath()) {
                                Image(systemName: .iconFolder)
                            }
                            MagicKeyValue(key: "url.isFolder", value: url.isFolder.description) {
                                Image(systemName: .iconFolderFill)
                            }
                        }
                        .padding()
                        .background(.background.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // 路径组合
                    VStack(alignment: .leading, spacing: 12) {
                        Text("路径组合")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 8) {
                            let baseURL = URL(string: "/base/path")!
                            MagicKeyValue(
                                key: "appendingFolder(\"docs\")",
                                value: baseURL.appendingFolder("docs").path
                            ) {
                                Image(systemName: .iconFolderFill)
                            }
                            MagicKeyValue(
                                key: "appendingFile(\"note.txt\")",
                                value: baseURL.appendingFile("note.txt").path
                            ) {
                                Image(systemName: .iconDocument)
                            }
                        }
                        .padding()
                        .background(.background.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
            }
            .tabItem {
                Image(systemName: .iconFolder)
                Text("路径")
            }
            
            // 文件操作演示
            MagicThemePreview {
                VStack(spacing: 20) {
                    // 文件操作
                    VStack(alignment: .leading, spacing: 12) {
                        Text("文件操作")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 8) {
                            MagicKeyValue(key: "getHash()", value: "计算文件MD5哈希值") {
                                Image(systemName: .iconFingerprint)
                            }
                            MagicKeyValue(key: "getContent()", value: "读取文件内容") {
                                Image(systemName: .iconDoc)
                            }
                            MagicKeyValue(key: "getBlob()", value: "获取Base64编码") {
                                Image(systemName: .iconDocBinary)
                            }
                        }
                        .padding()
                        .background(.background.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
            }
            .tabItem {
                Image(systemName: .iconDoc)
                Text("文件")
            }
        }
    }
}

#Preview("URL 扩展演示") {
    NavigationStack {
        URLExtensionDemoView()
    }
}
