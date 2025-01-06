import Foundation
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
        FileHelper.getMD5(self)
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
