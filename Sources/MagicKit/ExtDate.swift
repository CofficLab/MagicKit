import Foundation

public extension Date {
    // MARK: - 静态方法
    
    /// 获取当前时间的标准格式字符串 (yyyy-MM-dd HH:mm:ss)
    static var now: String {
        Date().fullDateTime
    }
    
    /// 获取当前时间的紧凑格式字符串 (yyyyMMddHHmmss)
    static var nowCompact: String {
        Date().compactDateTime
    }
    
    // MARK: - 实例属性
    
    /// 完整的日期时间字符串 (yyyy-MM-dd HH:mm:ss)
    var fullDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
    
    /// 紧凑的日期时间字符串 (yyyyMMddHHmmss)
    var compactDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
    
    /// 日志时间字符串 (HH:mm:ss)
    var logTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self)
    }
    
    // MARK: - 静态工具方法
    
    /// 将可选日期转换为字符串，如果为 nil 则返回 "-"
    /// - Parameter date: 可选的日期
    /// - Returns: 格式化的日期字符串或 "-"
    static func toString(_ date: Date?) -> String {
        guard let date = date else { return "-" }
        return date.fullDateTime
    }
}
