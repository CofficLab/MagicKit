import Combine
import SwiftUI

/// 日志管理器，用于收集和展示日志
public class MagicLogger: ObservableObject, @unchecked Sendable {
    /// 单例模式
    public static let shared = MagicLogger()

    /// 存储的日志条目
    @Published private(set) var logs: [MagicLogEntry] = []

    /// 应用名称
    @Published public var app: String

    /// 最大日志数量
    private let maxLogCount = 1000

    /// 用于同步访问的锁
    private let lock = NSLock()

    public init(app: String = "Default") {
        self.app = app
    }

    // MARK: - Static Methods

    /// 记录一条日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - level: 日志级别
    ///   - caller: 日志发生的位置
    public static func log(_ message: String, level: MagicLogEntry.Level, caller: String = #function, line: Int = #line) {
        shared.log(message, level: level, caller: caller, line: line)
    }

    // ... existing static methods ...

    // MARK: - Public Methods

    /// 记录一条日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - level: 日志级别
    ///   - caller: 日志发生的位置
    public func log(_ message: String, level: MagicLogEntry.Level, caller: String = #function, line: Int = #line) {
        addLog(.init(message: message, level: level, caller: caller, line: line))
    }

    /// 添加一条信息日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - caller: 日志发生的位置
    public static func info(_ message: String, caller: String = #function, line: Int = #line) {
        shared.info(message, caller: caller, line: line)
    }

    /// 添加一条警告日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - caller: 日志发生的位置
    public static func warning(_ message: String, caller: String = #function, line: Int = #line) {
        shared.warning(message, caller: caller, line: line)
    }

    /// 添加一条错误日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - caller: 日志发生的位置
    public static func error(_ message: String, caller: String = #function, line: Int = #line) {
        shared.error(message, caller: caller, line: line)
    }

    /// 添加一条调试日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - caller: 日志发生的位置
    public static func debug(_ message: String, caller: String = #function, line: Int = #line) {
        shared.debug(message, caller: caller, line: line)
    }

    /// 清空所有日志
    public static func clearLogs() {
        shared.clearLogs()
    }

    /// 获取日志视图
    /// - Parameters:
    ///   - title: 视图标题
    ///   - onClose: 关闭回调
    /// - Returns: 日志视图
    public static func logView(
        title: String = "Logs",
        onClose: (() -> Void)? = nil
    ) -> MagicLogView {
        shared.logView(title: title, onClose: onClose)
    }

    /// 获取一个带日志视图弹出框的按钮
    /// - Parameters:
    ///   - icon: 按钮图标
    ///   - title: 按钮标题
    ///   - style: 按钮样式
    ///   - size: 按钮大小
    ///   - shape: 按钮形状
    /// - Returns: 日志按钮
    public static func logButton(
        icon: String = "doc.text.magnifyingglass",
        title: String? = nil,
        style: MagicButton.Style = .secondary,
        size: MagicButton.Size = .regular,
        shape: MagicButton.Shape = .circle
    ) -> MagicButton {
        shared.logButton(
            icon: icon,
            title: title,
            style: style,
            size: size,
            shape: shape
        )
    }

    // MARK: - Public Methods

    /// 添加一条信息日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - caller: 日志发生的位置
    public func info(_ message: String, caller: String = #function, line: Int = #line) {
        addLog(.init(message: message, level: .info, caller: caller, line: line))
    }

    /// 添加一条警告日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - caller: 日志发生的位置
    public func warning(_ message: String, caller: String = #function, line: Int = #line) {
        addLog(.init(message: message, level: .warning, caller: caller, line: line))
    }

    /// 添加一条错误日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - caller: 日志发生的位置
    public func error(_ message: String, caller: String = #function, line: Int = #line) {
        addLog(.init(message: message, level: .error, caller: caller, line: line))
    }

    /// 添加一条调试日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - caller: 日志发生的位置
    public func debug(_ message: String, caller: String = #function, line: Int = #line) {
        addLog(.init(message: message, level: .debug, caller: caller, line: line))
    }

    /// 清空所有日志
    public func clearLogs() {
        logs.removeAll()
    }

    /// 获取日志视图
    /// - Parameters:
    ///   - title: 视图标题
    ///   - onClose: 关闭回调
    /// - Returns: 日志视图
    public func logView(
        title: String = "Logs",
        onClose: (() -> Void)? = nil
    ) -> MagicLogView {
        MagicLogView(
            title: title,
            logger: self,
            onClose: onClose
        )
    }

    /// 获取一个带日志视图弹出框的按钮
    /// - Parameters:
    ///   - icon: 按钮图标
    ///   - title: 按钮标题
    ///   - style: 按钮样式
    ///   - size: 按钮大小
    ///   - shape: 按钮形状
    /// - Returns: 日志按钮
    public func logButton(
        icon: String = "doc.text.magnifyingglass",
        title: String? = nil,
        style: MagicButton.Style = .secondary,
        size: MagicButton.Size = .regular,
        shape: MagicButton.Shape = .circle
    ) -> MagicButton {
        MagicButton(
            icon: icon,
            title: title,
            style: style,
            size: size,
            shape: shape,
            popoverContent: AnyView(
                logView()
                    .frame(width: 600, height: 400)
            )
        )
    }

    // MARK: - Private Methods

    private func addLog(_ entry: MagicLogEntry) {
        lock.lock()
        defer { lock.unlock() }
        
        DispatchQueue.main.async {
            self.logs.append(entry)
            // 限制日志数量
            if self.logs.count > self.maxLogCount {
                self.logs.removeFirst(self.logs.count - self.maxLogCount)
            }
        }
    }
}

// MARK: - Preview

#Preview("MagicLogger") {
    VStack(spacing: 20) {
        // 测试日志按钮
        MagicLogger.logButton()

        // 使用 shared 实例的日志视图
        MagicLogger.logView()
            .frame(height: 300)
    }
    .padding()
    .onAppear {
        // 清除之前的日志
        MagicLogger.clearLogs()

        // 添加一些测试日志
        MagicLogger.info("Application started")
        MagicLogger.debug("Debug message")
        MagicLogger.warning("Warning message")
        MagicLogger.error("Error message")
    }
    .inMagicContainer()
}
