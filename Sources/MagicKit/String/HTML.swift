import Foundation
import OSLog

extension String {
    /// 将HTML代码中的base64图片存储到磁盘，并替换HTML代码中的图片路径，然后返回
    public func replaceImageSrcWithRelativePath(_ url: URL) -> String {
        let htmlContent = self
        let imagePrefix = url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: " ", with: "_")

        let imageDirName = "images"

        // 定义正则表达式模式，用于匹配 Base64 图片
        let base64ImagePattern = "src=\"data:image/(.*?);base64,(.*?)\""

        // 创建正则表达式
        guard let regex = try? NSRegularExpression(pattern: base64ImagePattern, options: []) else {
            print("无效的正则表达式")
            return htmlContent
        }

        let nsString = htmlContent as NSString
        let results = regex.matches(in: htmlContent, options: [], range: NSRange(location: 0, length: nsString.length))

        var modifiedHTML = htmlContent
        let parentDirectory = url.deletingLastPathComponent()
        let imageDir = parentDirectory.appendingPathComponent(imageDirName)

        for (index, result) in results.enumerated() {
            // 提取图片类型和 Base64 数据
            if let imageTypeRange = Range(result.range(at: 1), in: htmlContent),
               let base64DataRange = Range(result.range(at: 2), in: htmlContent) {
                let imageType = String(htmlContent[imageTypeRange]) // 图片类型，如 'png'
                let base64Data = String(htmlContent[base64DataRange]) // Base64 数据

                // 解码 Base64 数据
                if let imageData = Data(base64Encoded: base64Data) {
                    let fileName = "\(imagePrefix)_\(index + 1).\(imageType)"
                    let fileURL = imageDir.appendingPathComponent(fileName)

                    // 保存到文件
                    imageData.save(fileURL)

                    // 替换 HTML 中的 src 地址
                    let newSrc = "./\(imageDirName)/\(fileName)"
                    modifiedHTML = modifiedHTML.replacingOccurrences(of: "src=\"data:image/\(imageType);base64,\(base64Data)\"", with: "src=\"\(newSrc)\"")
                } else {
                    print("无效的 Base64 数据")
                }
            }
        }

        return modifiedHTML
    }
}
