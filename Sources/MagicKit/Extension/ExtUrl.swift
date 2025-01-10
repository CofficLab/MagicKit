import Foundation
import CryptoKit
import OSLog
import SwiftUI

#if os(macOS)
    import AppKit
#endif

#if os(iOS)
    import UIKit
#endif

extension URL: SuperLog {
    public static var emoji = "🌉"
}

extension URL {
    public func getHash(verbose: Bool = true) -> String {
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

    public func getBlob() throws -> String {
        let url = self

        if self.isImage {
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

    public func getContent() throws -> String {
        do {
            return try String(contentsOfFile: self.path, encoding: .utf8)
        } catch {
            os_log(.error, "读取文件时发生错误: \(error)")
            throw error
        }
    }

    public func getParent() -> URL {
        self.deletingLastPathComponent()
    }

    public var isFolder: Bool { self.hasDirectoryPath }

    public var isNotFolder: Bool { !isFolder }

    public var name: String { self.lastPathComponent }

    public func next() -> URL? {
        self.getNextFile()
    }

    public func nearestFolder() -> URL {
        self.isFolder ? self : self.deletingLastPathComponent()
    }

    public static var null: URL {
        URL(filePath: "/dev/null")
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

    public func removingLeadingSlashes() -> String {
        return self.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
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

    /// 生成默认音频缩略图
    public func defaultAudioThumbnail(size: CGSize) -> Image {
        #if os(macOS)
            if let defaultIcon = NSImage(systemSymbolName: "music.note", accessibilityDescription: nil) {
                let resizedIcon = defaultIcon.resize(to: size)
                return Image(nsImage: resizedIcon)
            }
            return Image(systemName: "music.note")
        #else
            if let defaultIcon = UIImage(systemName: "music.note") {
                let resizedIcon = defaultIcon.resize(to: size)
                return Image(uiImage: resizedIcon)
            }
            return Image(systemName: "music.note")
        #endif
    }

    /// Returns a shortened version of the URL path by showing only the last three components.
    /// This method is useful for displaying long file paths in a more readable format.
    ///
    /// - Returns: A string containing the last three components of the path, separated by "/".
    ///
    /// - Example:
    ///   ```
    ///   let url = URL(string: "file:///path/to/folder/documents/report.pdf")!
    ///   print(url.shortPath()) // Prints: "folder/documents/report.pdf"
    ///   ```
    public func shortPath() -> String {
        self.lastThreeComponents()
    }

    /// Returns the last three components of the URL path joined with "/".
    ///
    /// - Returns: A string containing up to three path components from the end, joined by "/".
    ///           If there are fewer than 3 components, returns all available components.
    ///
    /// - Example:
    ///   ```
    ///   let url = URL(string: "file:///path/to/folder/a/b/c.png")!
    ///   print(url.lastThreeComponents()) // Prints: "a/b/c.png"
    ///   ```
    public func lastThreeComponents() -> String {
        let components = self.pathComponents.filter { $0 != "/" }
        let lastThree = components.suffix(3)
        return lastThree.joined(separator: "/")
    }

    /// Appends a folder to the end of the current URL path
    /// - Parameter folderName: Name of the folder to append
    /// - Returns: A new URL with the folder appended
    /// - Example:
    ///   ```
    ///   let url = URL(string: "file:///path/to")!
    ///   let newUrl = url.appendingFolder("documents")
    ///   // Result: "file:///path/to/documents"
    ///   ```
    public func appendingFolder(_ folderName: String) -> URL {
        // Remove any trailing slashes from the folder name
        let cleanFolderName = folderName.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return self.appendingPathComponent(cleanFolderName, isDirectory: true)
    }

    /// Appends a file to the end of the current URL path
    /// - Parameter fileName: Name of the file to append
    /// - Returns: A new URL with the file appended
    /// - Example:
    ///   ```
    ///   let url = URL(string: "file:///path/to")!
    ///   let newUrl = url.appendingFile("document.txt")
    ///   // Result: "file:///path/to/document.txt"
    ///   ```
    public func appendingFile(_ fileName: String) -> URL {
        // Remove any trailing slashes from the file name
        let cleanFileName = fileName.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return self.appendingPathComponent(cleanFileName, isDirectory: false)
    }
}

#if os(macOS)
    extension NSImage {
        func resize(to size: CGSize) -> NSImage {
            let newImage = NSImage(size: size)
            newImage.lockFocus()

            NSGraphicsContext.current?.imageInterpolation = .high
            draw(in: NSRect(origin: .zero, size: size),
                 from: NSRect(origin: .zero, size: self.size),
                 operation: .copy,
                 fraction: 1.0)

            newImage.unlockFocus()
            return newImage
        }
    }
#else
    extension UIImage {
        func resize(to size: CGSize) -> UIImage {
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { _ in
                self.draw(in: CGRect(origin: .zero, size: size))
            }
        }
    }
#endif
