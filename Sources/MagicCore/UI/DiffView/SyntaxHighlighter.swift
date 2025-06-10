import SwiftUI

/// 语法高亮器
/// 提供基本的代码语法高亮功能
struct SyntaxHighlighter {
    /// 语法高亮规则
    struct HighlightRule {
        let pattern: String
        let color: Color
        
        static let swift: [HighlightRule] = [
            // 关键字
            .init(pattern: "\\b(class|struct|enum|protocol|extension|func|var|let|if|else|guard|switch|case|default|for|while|do|try|catch|throw|throws|rethrows|return|break|continue|where|in|init|deinit|self|super|true|false|nil|async|await|some|any)\\b", color: .purple),
            
            // 字符串
            .init(pattern: "\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"", color: .red),
            
            // 数字
            .init(pattern: "\\b([0-9]+\\.?[0-9]*|\\.[0-9]+)\\b", color: .blue),
            
            // 注释
            .init(pattern: "//.*$|/\\*[\\s\\S]*?\\*/", color: .secondary),
            
            // 类型名（首字母大写）
            .init(pattern: "\\b[A-Z][a-zA-Z0-9_]*\\b", color: .orange),
            
            // 属性和函数调用
            .init(pattern: "\\.[a-zA-Z_][a-zA-Z0-9_]*", color: .teal),
            
            // 特殊字符
            .init(pattern: "@[a-zA-Z_][a-zA-Z0-9_]*", color: .blue)
        ]
        
        static let javascript: [HighlightRule] = [
            // 关键字
            .init(pattern: "\\b(const|let|var|function|class|extends|new|if|else|for|while|do|switch|case|break|continue|return|try|catch|finally|throw|async|await|import|export|default|null|undefined|true|false|this|super)\\b", color: .purple),
            
            // 字符串
            .init(pattern: "'[^'\\\\]*(?:\\\\.[^'\\\\]*)*'|\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"|`[^`\\\\]*(?:\\\\.[^`\\\\]*)*`", color: .red),
            
            // 数字
            .init(pattern: "\\b\\d*\\.?\\d+\\b", color: .blue),
            
            // 注释
            .init(pattern: "//.*$|/\\*[\\s\\S]*?\\*/", color: .secondary),
            
            // 函数调用
            .init(pattern: "\\b[a-zA-Z_][a-zA-Z0-9_]*(?=\\()", color: .teal),
            
            // 对象属性
            .init(pattern: "\\.[a-zA-Z_][a-zA-Z0-9_]*", color: .teal)
        ]
        
        static let python: [HighlightRule] = [
            // 关键字
            .init(pattern: "\\b(def|class|if|else|elif|for|while|try|except|finally|with|as|import|from|return|yield|break|continue|pass|raise|True|False|None|and|or|not|is|in|lambda|nonlocal|global|del|async|await)\\b", color: .purple),
            
            // 字符串
            .init(pattern: "'''[\\s\\S]*?'''|\"\"\"|'[^'\\\\]*(?:\\\\.[^'\\\\]*)*'|\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"", color: .red),
            
            // 数字
            .init(pattern: "\\b\\d*\\.?\\d+\\b", color: .blue),
            
            // 注释
            .init(pattern: "#.*$", color: .secondary),
            
            // 装饰器
            .init(pattern: "@[a-zA-Z_][a-zA-Z0-9_]*", color: .blue),
            
            // 函数调用
            .init(pattern: "\\b[a-zA-Z_][a-zA-Z0-9_]*(?=\\()", color: .teal)
        ]
        
        static let java: [HighlightRule] = [
            // 关键字
            .init(pattern: "\\b(public|private|protected|class|interface|abstract|extends|implements|import|package|new|return|if|else|for|while|do|switch|case|break|continue|try|catch|finally|throw|throws|static|final|void|int|long|float|double|boolean|char|byte|short|enum|assert|synchronized|volatile|transient|native|strictfp|instanceof|super|this|null|true|false)\\b", color: .purple),
            
            // 字符串
            .init(pattern: "\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"", color: .red),
            
            // 数字
            .init(pattern: "\\b\\d*\\.?\\d+[LlFfDd]?\\b", color: .blue),
            
            // 注释
            .init(pattern: "//.*$|/\\*[\\s\\S]*?\\*/", color: .secondary),
            
            // 类名
            .init(pattern: "\\b[A-Z][a-zA-Z0-9_]*\\b", color: .orange),
            
            // 注解
            .init(pattern: "@[a-zA-Z_][a-zA-Z0-9_]*", color: .blue)
        ]
        
        static let cpp: [HighlightRule] = [
            // 关键字
            .init(pattern: "\\b(auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while|class|namespace|template|public|private|protected|virtual|inline|explicit|friend|using|try|catch|throw|new|delete|this|operator|bool|true|false|nullptr)\\b", color: .purple),
            
            // 预处理指令
            .init(pattern: "#[a-zA-Z]+\\b", color: .blue),
            
            // 字符串
            .init(pattern: "\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"", color: .red),
            
            // 数字
            .init(pattern: "\\b\\d*\\.?\\d+[UuLlFf]*\\b", color: .blue),
            
            // 注释
            .init(pattern: "//.*$|/\\*[\\s\\S]*?\\*/", color: .secondary),
            
            // 类名
            .init(pattern: "\\b[A-Z][a-zA-Z0-9_]*\\b", color: .orange)
        ]
        
        static let html: [HighlightRule] = [
            // 标签
            .init(pattern: "</?[a-zA-Z][^>]*>", color: .purple),
            
            // 属性
            .init(pattern: "\\b[a-zA-Z-]+(?=\\s*=\\s*[\"'])", color: .teal),
            
            // 字符串
            .init(pattern: "\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"|'[^'\\\\]*(?:\\\\.[^'\\\\]*)*'", color: .red),
            
            // 注释
            .init(pattern: "<!--[\\s\\S]*?-->", color: .secondary),
            
            // DOCTYPE
            .init(pattern: "<!DOCTYPE[^>]*>", color: .blue)
        ]
        
        static let css: [HighlightRule] = [
            // 选择器
            .init(pattern: "[.#]?[a-zA-Z][a-zA-Z0-9_-]*(?=[\\s{,])", color: .purple),
            
            // 属性
            .init(pattern: "[a-zA-Z-]+(?=\\s*:)", color: .teal),
            
            // 值
            .init(pattern: ":\\s*[^;\\n]+", color: .blue),
            
            // 注释
            .init(pattern: "/\\*[\\s\\S]*?\\*/", color: .secondary),
            
            // 单位
            .init(pattern: "\\b\\d+(?:px|em|rem|%|pt|vh|vw)\\b", color: .orange),
            
            // 颜色
            .init(pattern: "#[a-fA-F0-9]{3,6}\\b", color: .red)
        ]
        
        static let php: [HighlightRule] = [
            // PHP标签
            .init(pattern: "<?php\\b|\\?>", color: .purple),
            
            // 关键字
            .init(pattern: "\\b(abstract|and|array|as|break|callable|case|catch|class|clone|const|continue|declare|default|die|do|echo|else|elseif|empty|enddeclare|endfor|endforeach|endif|endswitch|endwhile|eval|exit|extends|final|finally|fn|for|foreach|function|global|goto|if|implements|include|include_once|instanceof|insteadof|interface|isset|list|match|namespace|new|or|print|private|protected|public|require|require_once|return|static|switch|throw|trait|try|unset|use|var|while|yield|__CLASS__|__DIR__|__FILE__|__FUNCTION__|__LINE__|__METHOD__|__NAMESPACE__|__TRAIT__)\\b", color: .purple),
            
            // 字符串
            .init(pattern: "'[^'\\\\]*(?:\\\\.[^'\\\\]*)*'|\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"|<<<['\"](\\w+)['\"](.|\\n)*?\\1;?", color: .red),
            
            // 变量
            .init(pattern: "\\$[a-zA-Z_][a-zA-Z0-9_]*", color: .teal),
            
            // 注释
            .init(pattern: "//.*$|#.*$|/\\*[\\s\\S]*?\\*/", color: .secondary),
            
            // 数字
            .init(pattern: "\\b\\d*\\.?\\d+\\b", color: .blue)
        ]
    }
    
    /// 对文本应用语法高亮
    /// - Parameters:
    ///   - text: 要高亮的文本
    ///   - rules: 高亮规则数组
    /// - Returns: 高亮后的文本视图
    static func highlight(text: String, rules: [HighlightRule]) -> Text {
        var attributedString = AttributedString(text)
        let nsRange = NSRange(location: 0, length: text.utf16.count)
        
        for rule in rules {
            guard let regex = try? NSRegularExpression(pattern: rule.pattern, options: []) else {
                continue
            }
            
            let matches = regex.matches(in: text, options: [], range: nsRange)
            for match in matches {
                guard let range = Range(match.range, in: text) else { continue }
                let color = rule.color
                
                // 将String.Index范围转换为AttributedString.Index范围
                if let attrRange = Range(range, in: attributedString) {
                    attributedString[attrRange].foregroundColor = color
                }
            }
        }
        
        return Text(attributedString)
    }
    
    /// 检测代码语言类型
    /// - Parameter text: 要检测的代码文本
    /// - Returns: 推测的语言类型
    static func detectLanguage(_ text: String) -> CodeLanguage {
        // 基于文件特征的语言检测逻辑
        let firstLines = text.components(separatedBy: .newlines).prefix(5).joined(separator: "\n")
        
        // Swift特征
        if firstLines.contains("import SwiftUI") || firstLines.contains("import Foundation") ||
           text.contains("@State") || text.contains("struct") && text.contains(": View") {
            return .swift
        }
        
        // JavaScript特征
        if firstLines.contains("const ") || firstLines.contains("let ") ||
           firstLines.contains("import ") && firstLines.contains("from '") ||
           text.contains("function") || text.contains("=>") {
            return .javascript
        }
        
        // Python特征
        if firstLines.contains("def ") || firstLines.contains("import ") ||
           text.contains("class ") && text.contains("self") ||
           text.contains("#!") && text.contains("python") {
            return .python
        }
        
        // Java特征
        if firstLines.contains("public class ") || firstLines.contains("package ") ||
           text.contains("import java.") || text.contains("@Override") {
            return .java
        }
        
        // C++特征
        if firstLines.contains("#include") || firstLines.contains("using namespace") ||
           text.contains("int main") || text.contains("std::") {
            return .cpp
        }
        
        // HTML特征
        if firstLines.contains("<!DOCTYPE") || firstLines.contains("<html") ||
           text.contains("</div>") || text.contains("<head>") {
            return .html
        }
        
        // CSS特征
        if text.contains("{") && text.contains("}") &&
           (text.contains("px") || text.contains("em") || text.contains("#")) &&
           !text.contains("function") {
            return .css
        }
        
        // PHP特征
        if firstLines.contains("<?php") || firstLines.contains("namespace ") ||
           text.contains("function") && text.contains("$") {
            return .php
        }
        
        return .plainText
    }
}

/// 支持的代码语言
public enum CodeLanguage: String, CaseIterable {
    case swift
    case javascript
    case python
    case java
    case cpp
    case html
    case css
    case php
    case plainText
    
    /// 获取语言对应的高亮规则
    var rules: [SyntaxHighlighter.HighlightRule] {
        switch self {
        case .swift:
            return SyntaxHighlighter.HighlightRule.swift
        case .javascript:
            return SyntaxHighlighter.HighlightRule.javascript
        case .python:
            return SyntaxHighlighter.HighlightRule.python
        case .java:
            return SyntaxHighlighter.HighlightRule.java
        case .cpp:
            return SyntaxHighlighter.HighlightRule.cpp
        case .html:
            return SyntaxHighlighter.HighlightRule.html
        case .css:
            return SyntaxHighlighter.HighlightRule.css
        case .php:
            return SyntaxHighlighter.HighlightRule.php
        case .plainText:
            return []
        }
    }
    
    /// 获取语言的显示名称
    var displayName: String {
        switch self {
        case .plainText:
            return "Plain Text"
        default:
            return rawValue.capitalized
        }
    }
}

// MARK: - Preview

#Preview("MagicDiffPreviewView") {
    MagicDiffPreviewView()
        .inMagicContainer()
}
