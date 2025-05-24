yonimport Foundation
import SwiftUI
import UniformTypeIdentifiers
#if os(macOS)
import AppKit
#endif

/// 图像处理和转换工具类
/// 
/// `MagicImage` 提供了一系列用于图像处理的静态方法，包括：
/// - SwiftUI视图转换为图像
/// - 屏幕截图功能
/// - 多种格式的图像保存
public class MagicImage {
    /// 将 CGImage 转换为 JPEG 格式并保存到下载目录
    /// 
    /// - Parameter image: 需要转换和保存的 CGImage 对象
    /// - Note: 图像将以 'c.jpeg' 的文件名保存到用户的下载目录中
    ///        如果操作失败，错误信息将打印到控制台
    static public func toJpeg(image: CGImage) {
        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            print("Failed to access downloads folder.")
            return
        }

        let path = downloadsURL.appendingPathComponent("c.jpeg")

        guard let destination = CGImageDestinationCreateWithURL(path as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else {
            print("创建图像目标失败")
            return
        }

        CGImageDestinationAddImage(destination, image, nil)

        guard CGImageDestinationFinalize(destination) else {
            print("图像保存失败")
            return
        }
    }
    
    #if os(macOS)
    /// 将 NSImage 转换为 JPEG 格式并保存到指定位置或下载目录
    /// 
    /// - Parameters:
    ///   - image: 需要转换和保存的 NSImage 对象
    ///   - saveTo: 保存文件的目标 URL，如果为 nil 则保存到下载目录
    /// - Note: 图像将以当前时间戳命名，JPEG 压缩质量为 80%
    ///        如果保存失败，错误信息将打印到控制台
    static public func toJpeg(image: NSImage, saveTo: URL? = nil) {
        var saveToUrl = saveTo
        if saveToUrl == nil {
            guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
                let message = "Failed to access downloads folder."
                print(message)
                return
            }

            saveToUrl = downloadsURL.appendingPathComponent("\(getTimeString()).jpeg")
        }
        
        // 将 NSImage 对象转换为 NSBitmapImageRep 对象
        guard let imageData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: imageData) else {
            // 转换失败
            return
        }

        // 设置保存选项
        let properties: [NSBitmapImageRep.PropertyKey: Any] = [
            .compressionFactor: 0.8 // 设置 JPEG 压缩质量为 80%
        ]

        // 将位图写入磁盘
        if let jpgData = bitmapRep.representation(using: .jpeg, properties: properties) {
            do {
                try jpgData.write(to: saveToUrl!)
            } catch {
                // 保存失败
                print("保存图像失败：\(error)")
            }
        }
    }
    #endif
    
    /// 生成当前时间的格式化字符串
    /// 
    /// - Returns: 返回格式为 "yyyyMMddHHmmss" 的时间字符串，
    ///           例如："20240101235959"
    static public func getTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter.string(from: Date())
    }
    
    /// 获取 SwiftUI 视图的宽度
    /// 
    /// - Parameter view: 需要测量的 SwiftUI 视图
    /// - Returns: 视图的宽度（像素）
    /// - Note: 此方法必须在主线程上调用
    @MainActor static public func getViewWidth(_ view: some View) -> Int {
        makeCGImage(view).width
    }

    /// 获取 SwiftUI 视图的高度
    /// 
    /// - Parameter view: 需要测量的 SwiftUI 视图
    /// - Returns: 视图的高度（像素）
    /// - Note: 此方法必须在主线程上调用
    @MainActor static public func getViewHeigth(_ view: some View) -> Int {
        makeCGImage(view).height
    }
    
    /// 将 SwiftUI 视图转换为 CGImage
    /// 
    /// - Parameter view: 需要转换的 SwiftUI 视图
    /// - Returns: 转换后的 CGImage 对象
    /// - Note: 此方法必须在主线程上调用
    ///        该方法假设转换总是会成功，如果转换失败会触发运行时错误
    @MainActor static public func makeCGImage(_ view: some View) -> CGImage {
        ImageRenderer(content: view).cgImage!
    }

    /// 将 SwiftUI 视图转换为 SwiftUI Image 对象
    /// 
    /// - Parameter view: 需要转换的 SwiftUI 视图
    /// - Returns: 转换后的 SwiftUI Image 对象
    /// - Note: 此方法必须在主线程上调用
    ///        返回的 Image 对象比例因子为 1，标签文本为"目标图像"
    @MainActor static public func makeImage(_ view: some View) -> Image {
        Image(makeCGImage(view), scale: 1, label: Text("目标图像"))
    }
    
    /// 将 SwiftUI 视图保存为 PNG 图像文件
    /// 
    /// - Parameters:
    ///   - view: 需要截图的 SwiftUI 视图
    ///   - path: 保存文件的目标 URL，如果为 nil 则保存到下载目录
    ///   - title: 文件名，如果为 nil 则使用时间戳和尺寸信息命名
    /// - Returns: 操作结果的描述信息，成功时返回"已存储到下载文件夹"，失败时返回错误信息
    /// - Note: 此方法必须在主线程上调用
    @MainActor static public func snapshot(_ view: some View, path: URL? = nil, title: String? = nil) -> String {
        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            return "Failed to access downloads folder."
        }

        let width = getViewWidth(view)
        let heigth = getViewHeigth(view)
        let fileName = title != nil ? "\(title!).png" : "\(getTimeString())-\(width)x\(heigth).png"
        let defaultPath = downloadsURL.appendingPathComponent(fileName)
        let path = path == nil ? defaultPath : path!

        guard let destination = CGImageDestinationCreateWithURL(path as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            return "创建图像目标失败"
        }

        CGImageDestinationAddImage(destination, makeCGImage(view), nil)

        guard CGImageDestinationFinalize(destination) else {
            return "图像保存失败"
        }

        return "已存储到下载文件夹"
    }
}