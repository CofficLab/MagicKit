import Foundation
import SwiftUI
import OSLog

extension String {
    public var isNotEmpty: Bool {
        !isEmpty
    }
    
    public func noSpaces() -> String {
        self.trimmingCharacters(in: .whitespaces)
    }
    
    public func removingLeadingSlashes() -> String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
    
    public func mini() -> String {
        self.count <= 30 ? self : String(self.prefix(30)) + "..."
    }
    
    public func max(_ max: Int) -> String {
        self.count <= max ? self : String(self.prefix(max)) + "..."
    }
    
    public func toURL() -> URL {
        URL(string: self)!
    }
    
    public func toData() -> Data? {
        self.data(using: .utf8)
    }
    
    public func saveToFile(_ url: URL) {
        let verbose = false
        
        if verbose {
            os_log("保存到 -> \(url.relativePath)")
        }
        
        let f = FileManager.default
        let folder = url.deletingLastPathComponent()
        
        if !f.fileExists(atPath: folder.path) {
            do {
                try f.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("创建文件夹时发生错误: \(error)")
            }
        }

        do {
            try self.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            os_log(.error, "保存失败 -> \(error)")
        }
    }
}

extension String {
    public func toBase64() -> String {
        if let data = self.data(using: .utf8) {
            let base64String = data.base64EncodedString()
            
            return base64String
        } else {
            return ""
        }
    }
}

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

extension String {
    public func getIntFromJSON(for keyPath: String) -> Int? {
        self.getValueFromJSON(for: keyPath) as? Int
    }

    public func getStringFromJSON(for keyPath: String) -> String? {
        self.getValueFromJSON(for: keyPath) as? String
    }

    public func getArrayFromJSON(for keyPath: String) -> [String: Any]? {
        self.getValueFromJSON(for: keyPath) as? [String: Any]
    }
    
    /*
    示例使用
    let jsonString = """
    {
        "ref": "refs/heads/master",
        "node_id": "MDM6UmVmMjgyOTA1MjA2OnJlZnMvaGVhZHMvbWFzdGVy",
        "url": "https://api.github.com/repos/nookery/nookery.github.io/git/refs/heads/master",
        "object": {
            "sha": "f14ed6bd9bb8e0f1ea5e384ff57ee7e1e11dcc59",
            "type": "commit",
            "url": "https://api.github.com/repos/nookery/nookery.github.io/git/commits/f14ed6bd9bb8e0f1ea5e384ff57ee7e1e11dcc59"
        }
    }
    """

    if let shaValue = getValue(from: jsonString, for: "object.sha") {
        print("SHA: \(shaValue)") // 输出: SHA: f14ed6bd9bb8e0f1ea5e384ff57ee7e1e11dcc59
    } else {
        print("Key not found.")
    }
    */
    public func getValueFromJSON(for keyPath: String) -> Any? {
        let jsonString = self
        
        // 将 JSON 字符串转换为 Data
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Invalid JSON string.")
            return nil
        }
        
        do {
            // 解析 JSON
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                // 分割键路径
                let keys = keyPath.split(separator: ".").map(String.init)
                var currentObject: Any = jsonObject
                
                // 遍历键路径，逐层获取值
                for key in keys {
                    if let dict = currentObject as? [String: Any], let value = dict[key] {
                        currentObject = value
                    } else if let array = currentObject as? [[String: Any]], let firstItem = array.first, let value = firstItem[key] {
                        currentObject = value
                    } else {
                        return nil
                    }
                }
                return currentObject
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
        
        return nil
    }
}
extension String {
    public func saveMarkdown(_ url: URL) {
        self.replaceImageSrcWithRelativePath(url).toMarkdown().saveToFile(url)
    }
    
    public func toMarkdown() -> String {
        var markdown = self
        
        // 替换标题（h1-h6）
        for i in 1...6 {
            let tag = "h\(i)"
            let markdownHeader = String(repeating: "#", count: i) + " "
            let pattern = "<\(tag)(?:\\s+[^>]*?)?>(.*?)</\(tag)>"
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: markdown, options: [], range: NSRange(location: 0, length: markdown.utf16.count))
            
            for match in matches.reversed() {
                let range = match.range(at: 1)
                let headerContent = (markdown as NSString).substring(with: range)
                
                // 清理内容中的<strong>标签
                let cleanedHeaderContent = headerContent
                    .replacingOccurrences(of: "<strong[^>]*?>", with: "", options: .regularExpression)
                    .replacingOccurrences(of: "</strong>", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                markdown = markdown.replacingOccurrences(
                    of: "<\(tag)(?:\\s+[^>]*?)?>\(headerContent)</\(tag)>",
                    with: "\(markdownHeader)\(cleanedHeaderContent)\n\n",
                    options: .regularExpression
                )
            }
        }
        
        // 替换段落
        markdown = markdown.replacingOccurrences(of: "<p>", with: "")
        markdown = markdown.replacingOccurrences(of: "</p>", with: "\n\n")
        
        // 替换链接
        let linkPattern = "<a href=\"(.*?)\">(.*?)</a>"
        let linkRegex = try! NSRegularExpression(pattern: linkPattern, options: [])
        let linkRange = NSRange(location: 0, length: markdown.utf16.count)
        markdown = linkRegex.stringByReplacingMatches(in: markdown, options: [], range: linkRange, withTemplate: "[$2]($1)")
        
        // 替换 img 标签
        let imgPattern = "<img[^>]*?src=\"(.*?)\"(?:\\s+alt=\"(.*?)\")?[^>]*?/?>"
        let imgRegex = try! NSRegularExpression(pattern: imgPattern, options: [])
        let imgRange = NSRange(location: 0, length: markdown.utf16.count)
        markdown = imgRegex.stringByReplacingMatches(in: markdown, options: [], range: imgRange, withTemplate: "![$2]($1)\n\n")
        
        // 替换其他标签
        markdown = markdown.replacingOccurrences(of: "<strong[^>]*?>", with: "**", options: .regularExpression)
        markdown = markdown.replacingOccurrences(of: "</strong>", with: "**")
        markdown = markdown.replacingOccurrences(of: "<em>", with: "*")
        markdown = markdown.replacingOccurrences(of: "</em>", with: "*")
        markdown = markdown.replacingOccurrences(of: "<ul>", with: "")
        markdown = markdown.replacingOccurrences(of: "</ul>", with: "")
        markdown = markdown.replacingOccurrences(of: "<ol>", with: "")
        markdown = markdown.replacingOccurrences(of: "</ol>", with: "")
        markdown = markdown.replacingOccurrences(of: "<li>", with: "- ")
        markdown = markdown.replacingOccurrences(of: "</li>", with: "\n")
        
        // 移除剩余的 HTML 标签
        markdown = markdown.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // 去除多余的空行
        markdown = markdown.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        
        return markdown.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Clipboard Extension
extension String {
    /// 将字符串复制到剪贴板
    public func copy() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(self, forType: .string)
        #elseif os(iOS) || os(tvOS)
        UIPasteboard.general.string = self
        #endif
    }
}

#Preview {
    VStack {
        Spacer()
        Button("1", action: {
            let htmlContent = """
            <h1 id="heading-1"><strong class="my-custom-class">向Kong添加服务</strong></h1>
            <img src="https://example.com/image.png" alt="示例图片" />
            """

            let markdown = htmlContent.toMarkdown()
            print(markdown)
        })
        Spacer()
        
        Button("2", action: {
            let htmlContent = """
            <img src="./images/Cloud Server_1.png">
            """

            let markdown = htmlContent.toMarkdown()
            print("===========")
            print(markdown)
            print("===========")
        })
        Spacer()
        
        
    }
    .frame(width: 100)
}
