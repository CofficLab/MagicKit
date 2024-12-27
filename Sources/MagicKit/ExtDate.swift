import Foundation

extension Date {
    public static func nowWithCommonFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
}


public class TimeHelper {
    static public func getTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter.string(from: Date())
    }
    
    static public func toTimeString(_ time: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let t = time {
            return dateFormatter.string(from: t)
        } else {
            return "-"
        }
    }
}

extension Date {
    /// "yyyy-MM-dd HH:mm:ss" 格式的字符串
    public var string: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current

        return dateFormatter.string(from: self)
    }
    
    /// "yyyyMMddHHmmss" 格式的字符串
    public var string2: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        dateFormatter.timeZone = TimeZone.current

        return dateFormatter.string(from: self)
    }
}
