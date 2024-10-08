import Foundation
import OSLog
#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

extension URL {
    var name: String { self.lastPathComponent }
    
    var title: String { self.lastPathComponent.mini() }
    
    var isFolder: Bool { self.hasDirectoryPath }

    var isNotFolder: Bool { !isFolder }
    
    var f: FileManager { FileManager.default }
    
    public func removingLeadingSlashes() -> String {
        return self.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
    
    // MARK: FileManager

    public func getParent() -> URL {
        self.deletingLastPathComponent()
    }

    public func removeItem() throws {
        if self.isFileExist() {
            try f.removeItem(at: self)
        }

        if self.isDirExist() {
            try f.removeItem(at: self)
        }
    }
    
    public func nearestFolder() -> URL {
        self.isFolder ? self : self.deletingLastPathComponent()
    }
    
    public func isDirExist() -> String {
        isDirExist() ? "是" : "否"
    }

    public func isDirExist() -> Bool {
        var isDir: ObjCBool = true
        return f.fileExists(atPath: self.path(), isDirectory: &isDir)
    }
    
    public func isFileExist() -> String {
        isFileExist() ? "是" : "否"
    }

    public func isFileExist() -> Bool {
        f.fileExists(atPath: self.path)
    }
    
    public func removeParentFolder() {
        try? f.removeItem(at: self.deletingLastPathComponent())
    }
    
    public func removeParentFolderWhen(_ condition: Bool) {
        if condition {
            self.removeParentFolder()
        }
    }
    
    public func getContent() throws -> String {
        do {
            return try String(contentsOfFile: self.path, encoding: .utf8)
        } catch {
            os_log(.error, "读取文件时发生错误: \(error)")
            
            throw error
        }
    }
    
    public func getBlob() throws -> String {
        let url = self
        
        if self.isImage() {
            do {
                let data = try Data(contentsOf: url)
                return data.base64EncodedString()
            } catch {
                os_log(.error, "Error reading file: \(error)")
                return ""
            }
        } else {
            return try self.getContent()
        }
    }
    
    public func flatten() -> [URL] {
        getAllFilesInDirectory()
    }
    
    public func getChildren() -> [URL] {
        let url = self
        let fileManager = FileManager.default
        var fileURLs: [URL] = []

        do {
            // 获取目录下的所有文件和子目录的 URL
            let urls = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            
            fileURLs = urls.sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
        } catch {
            os_log(.error, "读取目录时发生错误: \(error)")
        }

        return fileURLs.filter({
            $0.lastPathComponent != ".DS_Store"
        })
    }
    
    public func getFileChildren() -> [URL] {
        let url = self
        let fileManager = FileManager.default
        var fileURLs: [URL] = []

        do {
            // 获取目录下的所有文件和子目录的 URL
            let urls = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            
            for u in urls {
                if u.hasDirectoryPath == false {
                    // 如果是文件，添加到数组
                    fileURLs.append(u)
                }
            }
        } catch {
            print("读取目录时发生错误: \(error)")
        }
        

        return fileURLs.filter({
            $0.lastPathComponent != ".DS_Store"
        }).sorted(by: {$0.lastPathComponent < $1.lastPathComponent})
    }
    
    public func getAllFilesInDirectory() -> [URL] {
        let url = self
        let fileManager = FileManager.default
        var fileURLs: [URL] = []

        do {
            // 获取目录下的所有文件和子目录的 URL
            let urls = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            
            for u in urls {
                // 检查是否是目录
                if u.hasDirectoryPath {
                    // 如果是目录，递归调用
                    fileURLs += u.getAllFilesInDirectory()
                } else {
                    // 如果是文件，添加到数组
                    fileURLs.append(u)
                }
            }
        } catch {
            os_log(.error, "读取目录时发生错误: \(error.localizedDescription)")
        }

        return fileURLs.filter({
            $0.lastPathComponent != ".DS_Store"
        })
    }
    
    public func openInBrowser() {
        #if os(iOS)
        UIApplication.shared.open(self)
        #elseif os(macOS)
        NSWorkspace.shared.open(self)
        #else
        #endif
    }

    public func getNextFile() -> URL? {
        let parent = self.getParent()
        let files = parent.getChildren()
        guard let index = files.firstIndex(of: self) else {
            return nil
        }
        
        let nextIndex = index + 1
        return files[nextIndex]
    }
    
    // MARK: HTTP
    
    public func withToken(_ token: String) -> HttpClient {
        HttpClient(url: self).withToken(token)
    }
    
    public func withBody(_ body: [String:Any]) -> HttpClient {
        HttpClient(url: self).withBody(body)
    }
    
    // MARK: Type

    // 定义常见图片格式的文件头
    public var imageSignatures: [String: [UInt8]] {
        [
            "jpg": [0xFF, 0xD8, 0xFF],
            "png": [0x89, 0x50, 0x4E, 0x47],
            "gif": [0x47, 0x49, 0x46],
            "bmp": [0x42, 0x4D],
            "webp": [0x52, 0x49, 0x46, 0x46]
        ]
    }

    // 读取文件头的函数
    public func readFileHeader(length: Int) -> [UInt8]? {
        let fileURL = self
        
        do {
            let fileData = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            return Array(fileData.prefix(length))
        } catch {
            print("读取文件头时出错: \(error)")
            return nil
        }
    }

    // 判断文件是否为图片的函数
    public func isImage() -> Bool {
        let verbose = false
        let fileURL = self
        
        // 读取最长的文件头（以字节为单位）
        let maxSignatureLength = imageSignatures.values.map { $0.count }.max() ?? 0
        
        guard let fileHeader = fileURL.readFileHeader(length: maxSignatureLength) else {
            return false
        }
        
        // 比较文件头与已知图片格式的文件头
        for (_, signature) in imageSignatures {
            if Array(fileHeader.prefix(signature.count)) == signature {
                if verbose {
                    os_log("\(self.relativePath) 是图片")
                }
                
                return true
            }
        }
        
        return false
    }
}
