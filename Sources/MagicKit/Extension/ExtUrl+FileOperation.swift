import Foundation
import OSLog
import SwiftUI

public extension URL {
    /// Deletes the file or directory at the specified URL.
    ///
    /// This method removes the file or directory from the file system. If the URL points to a directory,
    /// all of its contents will also be deleted.
    ///
    /// - Throws: An error if the deletion fails or if the file doesn't have sufficient permissions.
    /// - Note: This operation cannot be undone.
    func delete() throws {
        guard FileManager.default.fileExists(atPath: self.path) else {
            return
        }
        try FileManager.default.removeItem(at: self)
    }

    /// Returns all files in the directory and its subdirectories recursively.
    ///
    /// - Returns: An array of URLs representing all files found in the directory tree.
    /// - Note: This method filters out .DS_Store files automatically.
    func flatten() -> [URL] {
        getAllFilesInDirectory()
    }

    /// Returns all files in the directory and its subdirectories recursively.
    ///
    /// - Returns: An array of URLs representing all files found in the directory tree.
    /// - Note: This method filters out .DS_Store files automatically.
    /// - Important: This method logs an error if the directory cannot be accessed.
    func getAllFilesInDirectory() -> [URL] {
        let fileManager = FileManager.default
        var fileURLs: [URL] = []

        do {
            let urls = try fileManager.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])

            for url in urls {
                if url.hasDirectoryPath {
                    fileURLs += url.getAllFilesInDirectory()
                } else {
                    fileURLs.append(url)
                }
            }
        } catch {
            os_log(.error, "读取目录时发生错误: \(error.localizedDescription)")
        }

        return fileURLs.filter { $0.lastPathComponent != ".DS_Store" }
    }

    /// Returns immediate children (files and directories) of the current directory.
    ///
    /// - Returns: An array of URLs representing immediate children, sorted by name.
    /// - Note: This method filters out .DS_Store files automatically.
    func getChildren() -> [URL] {
        let fileManager = FileManager.default
        var fileURLs: [URL] = []

        do {
            let urls = try fileManager.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])
            fileURLs = urls.sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
        } catch {
            os_log(.error, "读取目录时发生错误: \(error)")
        }

        return fileURLs.filter { $0.lastPathComponent != ".DS_Store" }
    }

    /// Returns immediate file children (excluding directories) of the current directory.
    ///
    /// - Returns: An array of URLs representing immediate file children, sorted by name.
    /// - Note: This method filters out .DS_Store files automatically.
    func getFileChildren() -> [URL] {
        let fileManager = FileManager.default
        var fileURLs: [URL] = []

        do {
            let urls = try fileManager.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])
            fileURLs = urls.filter { !$0.hasDirectoryPath }
        } catch {
            os_log(.error, "读取目录时发生错误: \(error)")
        }

        return fileURLs
            .filter { $0.lastPathComponent != ".DS_Store" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    /// Returns the next file in the parent directory.
    ///
    /// - Returns: The URL of the next file, or `nil` if this is the last file.
    /// - Note: Files are ordered alphabetically by name.
    func getNextFile() -> URL? {
        let parent = deletingLastPathComponent()
        let files = parent.getChildren()
        guard let index = files.firstIndex(of: self) else {
            return nil
        }

        return index < files.count - 1 ? files[index + 1] : nil
    }

    /// Returns the previous file in the parent directory.
    ///
    /// - Returns: The URL of the previous file, or `nil` if this is the first file.
    /// - Note: Files are ordered alphabetically by name.
    func getPrevFile() -> URL? {
        let parent = deletingLastPathComponent()
        let files = parent.getChildren()
        guard let index = files.firstIndex(of: self) else {
            return nil
        }

        return index > 0 ? files[index - 1] : nil
    }

    /// Calculates the size of a file or directory in bytes.
    ///
    /// For directories, this method recursively calculates the total size of all contained files.
    ///
    /// - Returns: The size in bytes.
    /// - Note: Returns 0 if the size cannot be determined.
    func getSize() -> Int {
        // 如果是文件夹，计算所有子项的大小总和
        if hasDirectoryPath {
            return getAllFilesInDirectory()
                .reduce(0) { $0 + $1.getSize() }
        }

        // 如果是文件，返回文件大小
        let attributes = try? resourceValues(forKeys: [.fileSizeKey])
        return attributes?.fileSize ?? 0
    }

    /// Returns the file or directory size in a human-readable format.
    ///
    /// The size is automatically converted to the most appropriate unit (B, KB, MB, GB, or TB).
    ///
    /// - Returns: A formatted string representing the size (e.g., "1.5 MB").
    func getSizeReadable() -> String {
        let size = Double(getSize())
        let units = ["B", "KB", "MB", "GB", "TB"]
        var index = 0
        var convertedSize = size

        while convertedSize >= 1024 && index < units.count - 1 {
            convertedSize /= 1024
            index += 1
        }

        return String(format: "%.1f %@", convertedSize, units[index])
    }

    /// Checks if the URL points to an existing directory.
    var isDirExist: Bool {
        var isDir: ObjCBool = true
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
    }

    /// Checks if the URL points to an existing file.
    var isFileExist: Bool {
        FileManager.default.fileExists(atPath: path)
    }

    var isNotFileExist: Bool {
        !isFileExist
    }

    var isNotDirExist: Bool {
        !isDirExist
    }

    /// Removes the parent folder of the current file or directory.
    ///
    /// - Throws: An error if the deletion fails or if the folder doesn't have sufficient permissions.
    /// - Important: This operation cannot be undone and will delete all contents of the parent folder.
    func removeParentFolder() throws {
        try FileManager.default.removeItem(at: deletingLastPathComponent())
    }

    /// Conditionally removes the parent folder of the current file or directory.
    ///
    /// - Parameter condition: A Boolean value that determines whether the parent folder should be removed.
    /// - Note: This method silently ignores any errors that occur during deletion.
    func removeParentFolderWhen(_ condition: Bool) {
        if condition {
            try? removeParentFolder()
        }
    }

    /// Creates the directory or file at the URL if it doesn't exist and returns the URL.
    ///
    /// - For directories: Creates the directory and any necessary intermediate directories.
/// - For files: reates an empty file and any necessary parent directories.
    ///
    /// - Returns: The current URL (self)
    /// - Throws: An error if the creation fails
    func createIfNotExist() throws -> URL {
        // 首先确保父目录存在
        let parentDir = deletingLastPathComponent()
        if parentDir.isNotDirExist {
            try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
        }
        
        // 然后处理当前路径
        if hasDirectoryPath {
            if isNotDirExist {
                try FileManager.default.createDirectory(at: self, withIntermediateDirectories: true)
            }
        } else {
            if isNotFileExist {
                do {
                    try Data().write(to: self)
                } catch {
                    os_log(.error, "\(self.t)无法创建文件 \(self.path): \(error.localizedDescription)")
                    throw error
                }
            }
        }
        return self
    }
}

// MARK: - Preview

#Preview("File Operations") {
    FileOperationTestView()
}

private struct FileOperationTestView: View {
    @State private var selectedFile: URL?
    @State private var error: Error?
    @State private var showError = false

    let testDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent("FileOperationTest", isDirectory: true)

    var body: some View {
        List {
            Section("文件操作") {
                // 创建测试文件
                Button("创建测试文件") {
                    do {
                        try FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)

                        // 创建一些测试文件
                        for i in 1 ... 5 {
                            let fileURL = testDirectory.appendingPathComponent("test\(i).txt")
                            try "Test content \(i)".write(to: fileURL, atomically: true, encoding: .utf8)
                        }

                        // 创建子文件夹
                        let subDir = testDirectory.appendingPathComponent("subdir")
                        try FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true)
                        try "Subdir content".write(to: subDir.appendingPathComponent("subfile.txt"), atomically: true, encoding: .utf8)

                    } catch {
                        self.error = error
                        showError = true
                    }
                }

                // 显示文件列表
                if testDirectory.isDirExist {
                    ForEach(testDirectory.getChildren(), id: \.path) { url in
                        FileRow(url: url, selectedFile: $selectedFile)
                    }
                }

                // 清理测试文件
                Button("清理测试文件", role: .destructive) {
                    try? testDirectory.delete()
                }
            }

            if let selectedFile = selectedFile {
                Section("文件信息") {
                    Text("大小: \(selectedFile.getSizeReadable())")
                    Text("上级目录: \(selectedFile.deletingLastPathComponent().path)")
                    if let prev = selectedFile.getPrevFile() {
                        Text("上一个: \(prev.lastPathComponent)")
                    }
                    if let next = selectedFile.getNextFile() {
                        Text("下一个: \(next.lastPathComponent)")
                    }
                }

                Section("操作") {
                    #if os(macOS)
                        Button("在访达中显示") {
                            selectedFile.showInFinder()
                        }
                    #endif

                    Button("打开文件夹") {
                        selectedFile.openFolder()
                    }

                    Button("删除", role: .destructive) {
                        try? selectedFile.delete()
                        self.selectedFile = nil
                    }
                }
            }
        }
        .alert("错误", isPresented: $showError, presenting: error) { _ in
            Button("确定") {}
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}

private struct FileRow: View {
    let url: URL
    @Binding var selectedFile: URL?

    var body: some View {
        HStack {
            Image(systemName: url.hasDirectoryPath ? "folder" : "doc")

            VStack(alignment: .leading) {
                Text(url.lastPathComponent)
                Text(url.getSizeReadable())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedFile = url
        }
    }
}
