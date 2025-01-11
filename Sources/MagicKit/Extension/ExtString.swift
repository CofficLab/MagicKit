import Foundation
import SwiftUI
import OSLog

/// String 类型的扩展，提供常用的工具方法
public extension String {
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
}

#if DEBUG
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
#endif
