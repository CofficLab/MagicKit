import AVKit
import Foundation
import MagicKit
import OSLog
import SwiftUI

#if os(iOS) || os(visionOS)
    import UIKit
    public typealias PlatformImage = UIImage
#elseif os(macOS)
    import AppKit
    public typealias PlatformImage = NSImage
#endif

public protocol SuperCover: Identifiable, SuperLog, FileBox {
    var url: URL { get }
    var coverFolder: URL { get }
    var defaultImage: Image { get }
}

extension SuperCover {
    static var emoji: String { "🎁" }
}

public extension SuperCover {
    public func getPlatformImage() async throws -> PlatformImage? {
        if let cacheURL = try self.getCoverCacheURL(), FileManager.default.fileExists(atPath: cacheURL.path) {
            if let data = try? Data(contentsOf: cacheURL) {
                return loadPlatformImage(from: data)
            }
        } else {
            if let data = try? await getCoverData() {
                return loadPlatformImage(from: data)
            }
        }

        return nil
    }

    public func getCoverImage(verbose: Bool = false) async throws -> Image? {
        if verbose {
            os_log("\(self.t)GetCoverImage for \(self.title)")
        }

        if let image = try getCoverImageFromCache() {
            if verbose {
                os_log("\(self.t)🎉🎉🎉 GetCoverImageFromCache for \(self.title) success")
            }
            return image
        }

        guard let data = try await getCoverData() else {
            return nil
        }

        if let coverCacheURL = try self.getCoverCacheURL() {
            try saveImage(data, saveTo: coverCacheURL)
        }

        return loadImage(from: data)
    }

    private func loadPlatformImage(from data: Data) -> PlatformImage? {
        #if os(iOS)
            return UIImage(data: data)
        #elseif os(macOS)
            return NSImage(data: data)
        #elseif os(visionOS)
            return UIImage(data: data)
        #endif
    }

    private func loadImage(from data: Data) -> Image? {
        #if os(iOS)
            return UIImage(data: data).map { Image(uiImage: $0) }
        #elseif os(visionOS)
            return UIImage(data: data).map { Image(uiImage: $0) }
        #elseif os(macOS)
            return NSImage(data: data).map { Image(nsImage: $0) }
        #endif
    }

    private func saveImage(_ data: Data?, saveTo: URL) throws {
        guard let data = data else {
            return
        }

        try data.write(to: saveTo)
    }

    private func getCoverCacheURL() throws -> URL? {
        let coversDir = self.coverFolder
        let fm = FileManager.default

        try fm.createDirectory(
            at: coversDir, withIntermediateDirectories: true, attributes: nil)

        return coversDir
            .appendingPathComponent(url.lastPathComponent)
            .appendingPathExtension("jpeg")
    }

    private func getCoverImageFromCache(verbose: Bool = false) throws -> Image? {
        if verbose {
            os_log("\(self.t)GetCoverImageFromCache for \(self.title)")
        }

        let url: URL? = try getCoverCacheURL()
        let fileManager = FileManager.default

        guard let url = url else {
            return nil
        }

        if !fileManager.fileExists(atPath: url.path) {
            return nil
        }

        #if os(macOS)
            if let nsImage = NSImage(contentsOf: url) {
                return Image(nsImage: nsImage)
            } else {
                return nil
            }
        #else
            if let uiImage = UIImage(contentsOfFile: url.path) {
                return Image(uiImage: uiImage)
            } else {
                return nil
            }
        #endif
    }

    private func getCoverData(verbose: Bool = false) async throws -> Data? {
        guard isDownloaded
            && url.isFileExist()
            && !isFolder()
            && !isImage
            && !isJSON
            && !isWMA
        else {
            return nil
        }

        if verbose {
            os_log("\(self.t)GetCoverFromMeta for \(self.title)")
        }

        let asset = AVURLAsset(url: url)
        let commonMetadata = try await asset.load(.commonMetadata)
        let artworkItems = AVMetadataItem.metadataItems(
            from: commonMetadata,
            withKey: AVMetadataKey.commonKeyArtwork,
            keySpace: .common
        )

        if let artworkItem = artworkItems.first,
           let artworkData = try await artworkItem.load(.value) as? Data {
            return artworkData
        } else if let artworkItem = artworkItems.first,
                  let artworkImage = try await artworkItem.load(.value) as? PlatformImage {
            #if os(iOS)
                return artworkImage.pngData()
            #elseif os(macOS)
                return artworkImage.tiffRepresentation
            #endif
        }

        return nil
    }
}

enum SuperCoverError: Error {
    case coverCacheURLNotFound
}
