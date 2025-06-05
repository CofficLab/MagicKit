import Foundation
import SwiftUI
import OSLog
import SwiftData

/// 提供统一的日志记录和调试信息格式化功能的协议
///
/// `SuperLog` 协议为应用程序提供了一致的日志记录格式和调试信息输出功能。
/// 它支持自动生成 emoji 标识、线程信息显示，以及统一的日志前缀格式。
///
/// ## 使用示例:
/// ```swift
/// class UserManager: SuperLog {
///     static var emoji: String { "👤" }  // 自定义 emoji
///     
///     func login() {
///         print("\(t)开始登录处理") // 输出带有线程信息和标识的日志
///         
///         if isMain {
///             print("\(t)在主线程执行")
///         }
///         
///         // 使用原因标记
///         print("\(t)登录失败\(r("密码错误"))")
///     }
/// }
///
/// // 输出示例:
/// // [UI] | 👤 UserManager           | 开始登录处理
/// // [UI] | 👤 UserManager           | 在主线程执行
/// // [UI] | 👤 UserManager           | 登录失败 ➡️ 密码错误
/// ```
public protocol SuperLog {
    /// 获取实现者的标识 emoji
    static var emoji: String { get }
    
    /// 获取带有线程信息的完整前缀
    static var t: String { get }
    
    /// 获取实现者的类型名称
    static var author: String { get }
}

extension SuperLog {
    // MARK: - Static Properties

    /// 如果实现者没有提供 emoji，则根据 author 生成默认 emoji
    public static var emoji: String {
        return Self.author.generateContextEmoji()
    }

    /// 获取当前线程的质量描述和 emoji
    public static var t: String {
        let emoji = Self.emoji
        let qosDesc = Thread.currentQosDescription
        return "\(qosDesc) | \(emoji) \(author.padding(toLength: 27, withPad: " ", startingAt: 0)) | "
    }

    /// 获取实现者的作者名称
    public static var author: String {
        let fullName = String(describing: Self.self)
        return fullName.split(separator: "<").first.map(String.init) ?? fullName
    }

    // MARK: - Instance Properties

    /// 获取实现者的作者名称
    public var author: String { Self.author }

    /// 获取实现者的类名
    public var className: String { author }

    /// 判断当前线程是否为主线程
    public var isMain: Bool { Thread.isMainThread }

    /// 获取当前线程的质量描述和 emoji
    public var t: String { Self.t }

    // MARK: - Instance Methods

    /// 生成带有原因的字符串
    /// - Parameter s: 原始字符串
    /// - Returns: 带有原因的字符串
    public func r(_ s: String) -> String { makeReason(s) }

    /// 生成原因字符串
    /// - Parameter s: 原始字符串
    /// - Returns: 生成的原因字符串
    public func makeReason(_ s: String) -> String { " ➡️ " + s }

    // MARK: - Static Methods

    /// 获取实现者的 onAppear 字符串
    public static var onAppear: String { "\(t)📺 OnAppear " }

    /// 适用于表示初始化的场景，如 View 的 init 方法
    public static var onInit: String { "\(t)🚩 Init " }

    // MARK: - Static Properties for Instance Methods

    /// 获取实现者的 a 字符串
    public var a: String { Self.a }

    /// 获取实现者的 i 字符串
    public var i: String { Self.i }

    /// 获取实现者的 a 字符串
    public static var a: String { Self.onAppear }

    /// 获取实现者的 i 字符串
    public static var i: String { Self.onInit }
}
