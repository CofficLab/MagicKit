import Foundation
import OSLog
import SwiftUI

extension String {
    func saveMarkdown(_ url: URL) {
        self.replaceImageSrcWithRelativePath(url).toMarkdown().saveToFile(url)
    }
    
    func toMarkdown() -> String {
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
