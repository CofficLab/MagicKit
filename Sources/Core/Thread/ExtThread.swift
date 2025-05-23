import Foundation

/// Thread 类型的扩展，提供线程服务质量相关的功能
extension Thread {
    /// 获取当前线程的服务质量(QoS)描述字符串
    ///
    /// 返回当前线程的服务质量级别的描述，不包含名称部分，只返回对应的标识符
    ///
    /// ## 返回值示例:
    /// - 主线程: "[UI]"
    /// - 用户交互线程: "[UI]"
    /// - 用户发起线程: "[IN]"
    /// - 默认线程: "[DF]"
    /// - 实用工具线程: "[UT]"
    /// - 后台线程: "[BG]"
    /// - 未指定: "[UN]"
    ///
    /// ## 使用示例:
    /// ```swift
    /// // 在任意线程中获取当前线程的QoS描述
    /// let qosDesc = Thread.currentQosDescription
    /// print("当前线程: \(qosDesc)") // 例如输出: "当前线程: [BG]"
    /// ```
    public static var currentQosDescription: String {
        current.qualityOfService.description(withName: false)
    }
}