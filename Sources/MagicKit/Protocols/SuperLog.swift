import Foundation
import SwiftUI
import OSLog
import SwiftData

public protocol SuperLog {
    static var emoji: String { get }
    static var t: String { get }
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
        return "\(qosDesc) | \(emoji) \(author.padding(toLength: 20, withPad: " ", startingAt: 0)) | "
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

    /// 获取实现者的 onInit 字符串
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
