import Foundation

public extension TimeInterval {
    /// 将时间间隔转换为播放器显示格式
    /// - Returns: 格式化后的时间字符串，格式为 "mm:ss" 或 "hh:mm:ss"
    var displayFormat: String {
        TimeFormatter.format(self)
    }
}

public struct TimeFormatter {
    /// 将时间间隔转换为显示格式
    /// - Parameter timeInterval: 时间间隔（秒）
    /// - Returns: 格式化后的时间字符串，格式为 "mm:ss" 或 "hh:mm:ss"
    public static func format(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval / 3600)
        let minutes = Int(timeInterval.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
} 