import SwiftUI

/// 应用程序打开类型
public enum OpenAppType: String {
    /// 在Xcode中打开
    case xcode
    /// 在VS Code中打开
    case vscode
    /// 在Chrome中打开
    case chrome
    /// 在Safari中打开
    case safari
    /// 在终端中打开
    case terminal
    /// 在预览中打开
    case preview
    /// 在文本编辑器中打开
    case textEdit
    /// 在访达中显示
    case finder
    /// 在默认浏览器中打开
    case browser
    
    /// 获取应用程序的Bundle ID
    var bundleId: String? {
        switch self {
        case .xcode:
            return "com.apple.dt.Xcode"
        case .vscode:
            return "com.microsoft.VSCode"
        case .chrome:
            return "com.google.Chrome"
        case .safari:
            return "com.apple.Safari"
        case .terminal:
            return "com.apple.Terminal"
        case .preview:
            return "com.apple.Preview"
        case .textEdit:
            return "com.apple.TextEdit"
        case .finder:
            return "com.apple.finder"
        case .browser:
            return nil
        }
    }
    
    /// 获取应用程序的图标
    var icon: String {
        switch self {
        case .xcode:
            return .iconXcode
        case .vscode:
            return .iconCode // 使用code图标代表VS Code
        case .chrome:
            return .iconGlobe // 使用globe图标代替Chrome
        case .safari:
            return .iconSafari
        case .terminal:
            return .iconTerminal
        case .preview:
            return .iconPreview
        case .textEdit:
            return .iconTextEdit
        case .finder:
            return .iconShowInFinder
        case .browser:
            return .iconSafari
        }
    }
    
    /// 获取应用程序的显示名称
    var displayName: String {
        switch self {
        case .xcode:
            return "在Xcode中打开"
        case .vscode:
            return "在VS Code中打开"
        case .chrome:
            return "在Chrome中打开"
        case .safari:
            return "在Safari中打开"
        case .terminal:
            return "在终端中打开"
        case .preview:
            return "在预览中打开"
        case .textEdit:
            return "在文本编辑器中打开"
        case .finder:
            return "在访达中显示"
        case .browser:
            return "在浏览器中打开"
        }
    }
}

#Preview("Open Buttons") {
    OpenPreivewView()
        .inMagicContainer()
}