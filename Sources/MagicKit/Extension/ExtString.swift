import Foundation
import OSLog
import SwiftUI

extension String {
    /// 将字符串转换为UTF-8编码的Data对象
    /// - Returns: 转换后的Data对象，如果转换失败则返回nil
    /// 
    /// ## 使用示例:
    /// ```swift
    /// let str = "Hello"
    /// if let data = str.toData() {
    ///     print("转换成功，数据长度: \(data.count)")
    /// }
    /// ```
    public func toData() -> Data? {
        self.data(using: .utf8)
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
                    try? imageData.save(fileURL)

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

/// String 类型的扩展，提供常用的工具方法
public extension String {
    func toURL() -> URL {
        URL(string: self)!
    }

    // MARK: - 基础工具方法

    /// 检查字符串是否非空
    /// ```swift
    /// let text = "Hello"
    /// if text.isNotEmpty {
    ///     print("字符串不为空")
    /// }
    /// ```
    var isNotEmpty: Bool {
        !isEmpty
    }

    /// 移除字符串两端的空格
    /// ```swift
    /// let text = "  Hello World  "
    /// print(text.noSpaces()) // "Hello World"
    /// ```
    func noSpaces() -> String {
        self.trimmingCharacters(in: .whitespaces)
    }

    /// 移除字符串开头的斜杠
    /// ```swift
    /// let path = "/user/home/"
    /// print(path.removingLeadingSlashes()) // "user/home"
    /// ```
    func removingLeadingSlashes() -> String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    /// 将字符串截断为最多30个字符，超出部分用...替代
    /// ```swift
    /// let text = "这是一个很长的字符串，需要被截断"
    /// print(text.mini()) // "这是一个很长的字符串，需要被截..."
    /// ```
    func mini() -> String {
        self.count <= 30 ? self : String(self.prefix(30)) + "..."
    }

    /// 将字符串截断为指定长度，超出部分用...替代
    /// - Parameter max: 最大长度
    /// - Returns: 截断后的字符串
    /// ```swift
    /// let text = "这是一个很长的字符串"
    /// print(text.max(5)) // "这是一个..."
    /// ```
    func max(_ max: Int) -> String {
        self.count <= max ? self : String(self.prefix(max)) + "..."
    }

    // MARK: - 数字相关

    /// 检查字符串是否为偶数（假设字符串可以转换为整数）
    /// ```swift
    /// let number = "42"
    /// if number.isEven {
    ///     print("是偶数")
    /// }
    /// ```
    var isEven: Bool {
        guard let number = Int(self) else { return false }
        return number % 2 == 0
    }

    /// 检查字符串是否为奇数（假设字符串可以转换为整数）
    /// ```swift
    /// let number = "7"
    /// if number.isOdd {
    ///     print("是奇数")
    /// }
    /// ```
    var isOdd: Bool {
        !isEven
    }

    /// 创建一个带有图标预览的按钮
    /// ```swift
    /// let button = "star".previewIconButton()
    /// ```
    /// - Returns: 一个 MagicButton，点击后会显示所有图标的预览
    func previewIconButton() -> MagicButton {
        MagicButton(
            icon: self,
            style: .secondary,
            size: .regular,
            shape: .roundedRectangle,
            popoverContent: AnyView(
                StringIconExtensionDemoView()
                    .frame(width: 500)
            )
        )
    }

    func saveToFile(_ url: URL, verbose: Bool = true) throws {
        if verbose {
            os_log("保存到 -> \(url.relativePath)")
        }
        
        try url.deletingLastPathComponent().createIfNotExist()
        
        try self.write(to: url, atomically: true, encoding: .utf8)
    }
}

/// String 扩展功能演示视图
struct StringExtensionDemoView: View {
    var body: some View {
        TabView {
            // 基础功能演示
            MagicThemePreview {
                VStack(spacing: 20) {
                    // 字符串处理
                    VStack(alignment: .leading, spacing: 12) {
                        Text("字符串处理")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        VStack(spacing: 8) {
                            MagicKeyValue(key: "  Hello  .noSpaces()", value: "  Hello  ".noSpaces())
                            MagicKeyValue(key: "/path/to/file/.removingLeadingSlashes()", value: "/path/to/file/".removingLeadingSlashes())
                            MagicKeyValue(key: "长文本.mini()", value: "这是一个很长的字符串，需要被截断显示以便于阅读".mini())
                            MagicKeyValue(key: "长文本.max(10)", value: "这是一个很长的字符串".max(10))
                        }
                        .padding()
                        .background(.background.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // 数字判断
                    VStack(alignment: .leading, spacing: 12) {
                        Text("数字判断")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        VStack(spacing: 8) {
                            MagicKeyValue(key: "42.isEven", value: "true") {
                                Image(systemName: "42".isEven ? .iconCheckmark : .iconClose)
                                    .foregroundStyle(.green)
                            }
                            MagicKeyValue(key: "7.isOdd", value: "true") {
                                Image(systemName: "7".isOdd ? .iconCheckmark : .iconClose)
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding()
                        .background(.background.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // 图标预览按钮
                    VStack(alignment: .leading, spacing: 12) {
                        Text("图标预览按钮")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        VStack(spacing: 8) {
                            MagicKeyValue(key: "\"star\".previewIconButton()", value: "") {
                                "star".previewIconButton()
                            }

                            MagicKeyValue(key: "组合使用", value: "") {
                                HStack(spacing: 12) {
                                    "heart".previewIconButton()
                                    "music.note".previewIconButton()
                                    "photo".previewIconButton()
                                }
                            }
                        }
                        .padding()
                        .background(.background.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
            }
            .tabItem {
                Image(systemName: "1.circle.fill")
                Text("基础")
            }

            // 其他功能演示标签页...
        }
    }
}

#Preview("String 扩展演示") {
    NavigationStack {
        StringExtensionDemoView()
    }
}