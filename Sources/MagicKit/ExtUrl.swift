import Foundation
import OSLog
import SwiftUI

#if os(macOS)
    import AppKit
#endif

#if os(iOS)
    import UIKit
#endif

extension URL {
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

    public func openInBrowser() {
        #if os(iOS)
            UIApplication.shared.open(self)
        #elseif os(macOS)
            NSWorkspace.shared.open(self)
        #else
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

#Preview {
    NavigationStack {
        List {
            Section("文件信息测试") {
                let testFile = URL.documentsDirectory.appendingPathComponent("test.txt")
                VStack(alignment: .leading) {
                    Text("文件路径: \(testFile.path)")
                    Text("是否存在: \(testFile.isFileExist as Bool ? "是" : "否")")
                    Text("文件大小: \(testFile.getSizeReadable())")
                    Text("是否是图片: \(testFile.isImage.description)")
                }
            }
            
            Section("iCloud 状态") {
                let iCloudFile = URL(string: "file:///iCloud/test.pdf")!
                VStack(alignment: .leading) {
                    Text("是否是 iCloud 文件: \(iCloudFile.isiCloud.description)")
                    Text("是否已下载: \(iCloudFile.isDownloaded.description)")
                    if iCloudFile.isDownloading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
            }
            
            Section("文件导航") {
                let currentFile = URL.documentsDirectory.appendingPathComponent("current.txt")
                HStack {
                    Button("上一个") {
                        if let prev = currentFile.getPrevFile() {
                            print("Previous file: \(prev.path)")
                        }
                    }
                    Spacer()
                    Button("下一个") {
                        if let next = currentFile.getNextFile() {
                            print("Next file: \(next.path)")
                        }
                    }
                }
            }
            
            Section("文件操作") {
                HStack {
                    Button("打开文件夹") {
                        URL.documentsDirectory.openFolder()
                    }
                    Spacer()
                    #if os(macOS)
                    Button("在访达中显示") {
                        URL.documentsDirectory.showInFinder()
                    }
                    #endif
                }
            }
            
            Section("缩略图测试") {
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        // 测试图片缩略图
                        if let imageUrl = Bundle.main.url(forResource: "test", withExtension: "jpg") {
                            AsyncPreviewCell(url: imageUrl, title: "图片缩略图")
                        }
                        
                        // 测试音频缩略图
                        if let audioUrl = Bundle.main.url(forResource: "test", withExtension: "mp3") {
                            AsyncPreviewCell(url: audioUrl, title: "音频缩略图")
                        }
                        
                        // 测试视频缩略图
                        if let videoUrl = Bundle.main.url(forResource: "test", withExtension: "mp4") {
                            AsyncPreviewCell(url: videoUrl, title: "视频缩略图")
                        }
                    }
                    .frame(height: 150)
                    
                    // 测试默认音频图标
                    VStack {
                        Text("默认音频图标")
                        URL.documentsDirectory
                            .defaultAudioThumbnail(size: CGSize(width: 100, height: 100))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("URL 扩展测试")
    }
    .padding()
}

// 辅助预览组件
private struct AsyncPreviewCell: View {
    let url: URL
    let title: String
    @State private var thumbnail: Image?
    
    var body: some View {
        VStack {
            if let thumbnail = thumbnail {
                thumbnail
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
            }
            Text(title)
                .font(.caption)
        }
        .task {
            thumbnail = try? await url.thumbnail(size: CGSize(width: 100, height: 100))
        }
    }
}
