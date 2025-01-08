import SwiftUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

public extension Image {
    #if os(macOS)
        typealias PlatformImage = NSImage
    #else
        typealias PlatformImage = UIImage
    #endif
}

public extension Image.PlatformImage {
    /// 图片缩放质量
    enum ResizeQuality {
        case none
        case low
        case medium
        case high
    }
    
    /// 获取默认音频图标
    static var defaultAudioIcon: Image.PlatformImage? {
        systemImage(.iconMusicNote)
    }
    
    /// 获取系统图标
    /// - Parameter name: 图标名称
    /// - Returns: 系统图标
    static func systemImage(_ name: String) -> Image.PlatformImage? {
        #if os(macOS)
        return NSImage(systemSymbolName: name, accessibilityDescription: nil)
        #else
        return UIImage(systemName: name)
        #endif
    }
    
    /// 从文件 URL 创建图片
    /// - Parameter url: 文件 URL
    /// - Returns: 创建的图片，如果失败则返回 nil
    static func fromFile(_ url: URL) -> Image.PlatformImage? {
        #if os(macOS)
        return NSImage(contentsOf: url)
        #else
        return UIImage(contentsOfFile: url.path)
        #endif
    }
    
    /// 从 CGImage 创建图片
    /// - Parameters:
    ///   - cgImage: CGImage 对象
    ///   - size: 目标大小（仅 macOS 需要）
    /// - Returns: 创建的图片
    static func fromCGImage(_ cgImage: CGImage, size: CGSize) -> Image.PlatformImage {
        #if os(macOS)
        return NSImage(cgImage: cgImage, size: size)
        #else
        return UIImage(cgImage: cgImage)
        #endif
    }
    
    /// 调整图片大小
    /// - Parameters:
    ///   - size: 目标大小
    ///   - quality: 缩放质量
    /// - Returns: 调整大小后的图片
    func resize(to size: CGSize, quality: ResizeQuality = .none) -> Image.PlatformImage {
        #if os(macOS)
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        draw(in: NSRect(origin: .zero, size: size),
             from: NSRect(origin: .zero, size: self.size),
             operation: .copy,
             fraction: 1.0)
        newImage.unlockFocus()
        return newImage
        #else
        let format = UIGraphicsImageRendererFormat()
        format.scale = quality == .none ? 1 : UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
        #endif
    }
    
    /// 从缓存数据创建图片
    static func fromCacheData(_ data: Data) -> Image.PlatformImage? {
        #if os(macOS)
        return NSImage(data: data)
        #else
        return UIImage(data: data)
        #endif
    }
    
    /// 获取图片的二进制数据
    var cacheData: Data? {
        #if os(macOS)
        return tiffRepresentation
        #else
        return pngData()
        #endif
    }
    
    /// 获取文件夹图标
    /// - Parameter size: 目标大小
    /// - Returns: 调整大小后的文件夹图标
    static func folderIcon(size: CGSize) -> Image.PlatformImage? {
        if let folderIcon = systemImage(.iconFolderFill) {
            #if !os(macOS)
            folderIcon.withTintColor(.systemBlue)
            #endif
            return folderIcon.resize(to: size)
        }
        return systemImage(.iconFolder)
    }
    
    /// Create platform image from system icon name
    /// - Parameter icon: The system icon name
    /// - Returns: Platform specific image
    static func fromSystemIcon(_ icon: String) -> Image.PlatformImage? {
        #if os(macOS)
        return NSImage(systemSymbolName: icon, accessibilityDescription: nil)
        #else
        return UIImage(systemName: icon)
        #endif
    }
    
    /// Convert platform image to SwiftUI Image
    /// - Returns: SwiftUI Image
    func toSwiftUIImage() -> Image {
        #if os(macOS)
        return Image(nsImage: self)
        #else
        return Image(uiImage: self)
        #endif
    }
}