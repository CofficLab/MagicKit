import Foundation
import SwiftUI

/// Date 类型的扩展，提供常用的日期格式化和转换功能
public extension Date {    
    /// 获取当前时间的标准格式字符串
    ///
    /// 返回格式为 "yyyy-MM-dd HH:mm:ss" 的当前时间字符串，使用系统当前时区
    ///
    /// # 示例
    /// ```swift
    /// let currentTime = Date.now
    /// print(currentTime) // 输出类似: "2024-03-15 14:30:45"
    /// ```
    static var now: String {
        Date().fullDateTime
    }
    
    /// 获取当前时间的紧凑格式字符串
    ///
    /// 返回格式为 "yyyyMMddHHmmss" 的当前时间字符串，使用系统当前时区
    ///
    /// # 示例
    /// ```swift
    /// let compactTime = Date.nowCompact
    /// print(compactTime) // 输出类似: "20240315143045"
    /// ```
    static var nowCompact: String {
        Date().compactDateTime
    }
    
    // MARK: - 实例属性
    
    /// 完整的日期时间字符串
    ///
    /// 将日期转换为 "yyyy-MM-dd HH:mm:ss" 格式的字符串，使用系统当前时区
    ///
    /// # 示例
    /// ```swift
    /// let date = Date()
    /// print(date.fullDateTime) // 输出类似: "2024-03-15 14:30:45"
    /// ```
    var fullDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
    
    /// 紧凑的日期时间字符串
    ///
    /// 将日期转换为 "yyyyMMddHHmmss" 格式的字符串，使用系统当前时区
    ///
    /// # 示例
    /// ```swift
    /// let date = Date()
    /// print(date.compactDateTime) // 输出类似: "20240315143045"
    /// ```
    var compactDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
    
    /// 日志时间字符串
    ///
    /// 将日期转换为 "HH:mm:ss" 格式的字符串，适用于日志记录
    ///
    /// # 示例
    /// ```swift
    /// let date = Date()
    /// print(date.logTime) // 输出类似: "14:30:45"
    /// ```
    var logTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self)
    }
    
    // MARK: - 静态工具方法
    
    /// 将可选日期转换为字符串
    ///
    /// - Parameter date: 需要转换的可选日期
    /// - Returns: 如果日期存在，返回格式化的日期字符串；如果为 nil，返回 "-"
    ///
    /// # 示例
    /// ```swift
    /// let date: Date? = Date()
    /// print(Date.toString(date)) // 输出类似: "2024-03-15 14:30:45"
    ///
    /// let nilDate: Date? = nil
    /// print(Date.toString(nilDate)) // 输出: "-"
    /// ```
    static func toString(_ date: Date?) -> String {
        guard let date = date else { return "-" }
        return date.fullDateTime
    }
}

/// 日期格式化演示视图
struct DateFormattingDemoView: View {
    @State private var date = Date()
    
    var body: some View {
        MagicThemePreview {
            VStack(spacing: 20) {
                // 静态属性部分
                VStack(alignment: .leading, spacing: 12) {
                    Text("静态属性")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 8) {
                        MagicKeyValue(key: "now", value: Date.now)
                        MagicKeyValue(key: "nowCompact", value: Date.nowCompact)
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // 实例属性部分
                VStack(alignment: .leading, spacing: 12) {
                    Text("实例属性")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 8) {
                        MagicKeyValue(key: "fullDateTime", value: date.fullDateTime)
                        MagicKeyValue(key: "compactDateTime", value: date.compactDateTime)
                        MagicKeyValue(key: "logTime", value: date.logTime)
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // 工具方法部分
                VStack(alignment: .leading, spacing: 12) {
                    Text("工具方法")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 8) {
                        MagicKeyValue(key: "toString(date)", value: Date.toString(date))
                        MagicKeyValue(key: "toString(nil)", value: Date.toString(nil))
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
            .navigationTitle("Date 扩展演示")
        }
    }
}

#Preview("Date 格式化演示") {
    NavigationStack {
        DateFormattingDemoView()
    }
}
