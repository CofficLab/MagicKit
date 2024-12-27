import Foundation
import MagicKit
import OSLog

#if os(macOS)
    import AppKit
#endif

#if os(iOS)
    import UIKit
#endif

extension URL {
    public func copyTo(_ destination: URL, downloadProgress: ((Double) -> Void)? = nil) async throws {
        if self.isiCloud && self.isNotDownloaded {
            try await download(onProgress: downloadProgress)
        }
        
        try FileManager.default.copyItem(at: self, to: destination)
    }

    public func delete() throws {
        // Check if file exists before attempting deletion
        guard FileManager.default.fileExists(atPath: self.path) else {
            return
        }
        try FileManager.default.removeItem(at: self)
    }

    public func download(onProgress: ((Double) -> Void)? = nil) async throws {
        let fm = FileManager.default

        if self.isDownloaded {
            onProgress?(100)
            return
        }

        try fm.startDownloadingUbiquitousItem(at: self)

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let itemQuery = ItemQuery(queue: queue)

        let result = itemQuery.searchMetadataItems(predicates: [
            NSPredicate(format: "%K == %@", NSMetadataItemURLKey, self as NSURL),
        ])

        for try await collection in result {
            if let item = collection.first {
                let progress = item.downloadProgress
                onProgress?(progress)

                if item.isDownloaded {
                    onProgress?(100)
                    itemQuery.stop()
                    break
                }
            }
        }
    }

    public func flatten() -> [URL] {
        getAllFilesInDirectory()
    }

    public var f: FileManager { FileManager.default }

    public func getAllFilesInDirectory() -> [URL] {
        let url = self
        let fileManager = FileManager.default
        var fileURLs: [URL] = []

        do {
            let urls = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])

            for u in urls {
                if u.hasDirectoryPath {
                    fileURLs += u.getAllFilesInDirectory()
                } else {
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

    public func getChildren() -> [URL] {
        let url = self
        let fileManager = FileManager.default
        var fileURLs: [URL] = []

        do {
            let urls = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])

            fileURLs = urls.sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
        } catch {
            os_log(.error, "读取目录时发生错误: \(error)")
        }

        return fileURLs.filter({
            $0.lastPathComponent != ".DS_Store"
        })
    }

    public func getContent() throws -> String {
        do {
            return try String(contentsOfFile: self.path, encoding: .utf8)
        } catch {
            os_log(.error, "读取文件时发生错误: \(error)")
            throw error
        }
    }

    public func getFileChildren() -> [URL] {
        let url = self
        let fileManager = FileManager.default
        var fileURLs: [URL] = []

        do {
            let urls = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])

            for u in urls {
                if u.hasDirectoryPath == false {
                    fileURLs.append(u)
                }
            }
        } catch {
            print("读取目录时发生错误: \(error)")
        }

        return fileURLs.filter({
            $0.lastPathComponent != ".DS_Store"
        }).sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
    }

    public func getSize() -> Int {
        let fileURL = self
        
        // 如果是文件夹，计算所有子项的大小总和
        if fileURL.hasDirectoryPath {
            return getAllFilesInDirectory()
                .reduce(0) { $0 + $1.getSize() }
        }
        
        // 如果是文件，返回文件大小
        let attributes = try? fileURL.resourceValues(forKeys: [.fileSizeKey])
        return attributes?.fileSize ?? 0
    }

    public func getSizeReadable() -> String {
        let size = Double(self.getSize())
        let units = ["B", "KB", "MB", "GB", "TB"]
        var index = 0
        var convertedSize = size

        while convertedSize >= 1024 && index < units.count - 1 {
            convertedSize /= 1024
            index += 1
        }

        return String(format: "%.1f %@", convertedSize, units[index])
    }

    public func getNextFile() -> URL? {
        let parent = self.getParent()
        let files = parent.getChildren()
        guard let index = files.firstIndex(of: self) else {
            return nil
        }

        if index == files.count - 1 {
            return nil
        }

        let nextIndex = index + 1
        return files[nextIndex]
    }

    public func getParent() -> URL {
        self.deletingLastPathComponent()
    }

    public func getPrevFile() -> URL? {
        let parent = self.getParent()
        let files = parent.getChildren()
        guard let index = files.firstIndex(of: self) else {
            return nil
        }

        if index == 0 {
            return nil
        }

        let previousIndex = index - 1
        return files[previousIndex]
    }

    public func isDirExist() -> Bool {
        var isDir: ObjCBool = true
        return f.fileExists(atPath: self.path(), isDirectory: &isDir)
    }

    public func isDirExist() -> String {
        isDirExist() ? "是" : "否"
    }

    public func isFileExist() -> Bool {
        f.fileExists(atPath: self.path)
    }

    public func isFileExist() -> String {
        isFileExist() ? "是" : "否"
    }

    public func isImage() -> Bool {
        let verbose = false
        let fileURL = self

        let maxSignatureLength = imageSignatures.values.map { $0.count }.max() ?? 0

        guard let fileHeader = fileURL.readFileHeader(length: maxSignatureLength) else {
            return false
        }

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

    public var isFolder: Bool { self.hasDirectoryPath }

    public var isNotFolder: Bool { !isFolder }

    public var isDownloaded: Bool {
        isFolder || iCloudHelper.isDownloaded(self)
    }

    public var isDownloading: Bool {
        iCloudHelper.isDownloading(self)
    }

    public var isNotDownloaded: Bool {
        !isDownloaded
    }

    public var isiCloud: Bool {
        iCloudHelper.isCloudPath(url: self)
    }

    public var isNotiCloud: Bool {
        !isiCloud
    }

    public var isLocal: Bool {
        isNotiCloud
    }

    public var name: String { self.lastPathComponent }

    public func next() -> URL? {
        self.getNextFile()
    }

    public func nearestFolder() -> URL {
        self.isFolder ? self : self.deletingLastPathComponent()
    }

    public func openInBrowser() {
        #if os(iOS)
            UIApplication.shared.open(self)
        #elseif os(macOS)
            NSWorkspace.shared.open(self)
        #else
        #endif
    }

    public func openFolder() {
        #if os(macOS)
        NSWorkspace.shared.open(self)
        #endif
        
        #if os(iOS)
            // 检查 Files 应用程序是否可用
            if UIApplication.shared.canOpenURL(self) {
                // 打开 URL 并在 Files 应用程序中处理
                UIApplication.shared.open(self, options: [:], completionHandler: nil)
            } else {
                // 如果 Files 应用程序不可用,可以显示一个错误提示或采取其他措施
                print("无法打开文件")
            }
        #endif
    }

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

    public func removeItem() throws {
        if self.isFileExist() {
            try f.removeItem(at: self)
        }

        if self.isDirExist() {
            try f.removeItem(at: self)
        }
    }

    public func removeParentFolder() {
        try? f.removeItem(at: self.deletingLastPathComponent())
    }

    public func removeParentFolderWhen(_ condition: Bool) {
        if condition {
            self.removeParentFolder()
        }
    }

    public func removingLeadingSlashes() -> String {
        return self.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    public func showInFinder() {
        #if os(macOS)
            NSWorkspace.shared.activateFileViewerSelecting([self])
        #endif
    }

    public var title: String { self.lastPathComponent.mini() }

    public func withBody(_ body: [String: Any]) -> HttpClient {
        HttpClient(url: self).withBody(body)
    }

    public func withToken(_ token: String) -> HttpClient {
        HttpClient(url: self).withToken(token)
    }

    // MARK: Type

    public var imageSignatures: [String: [UInt8]] {
        [
            "jpg": [0xFF, 0xD8, 0xFF],
            "png": [0x89, 0x50, 0x4E, 0x47],
            "gif": [0x47, 0x49, 0x46],
            "bmp": [0x42, 0x4D],
            "webp": [0x52, 0x49, 0x46, 0x46],
        ]
    }
}
