import OSLog

@available(macOS 11.0, *)
extension Logger {
    static public func qosDescription(_ qos: QualityOfService, withName: Bool = true) -> String {
        switch qos {
        case .userInteractive: return withName ? "🔥 UserInteractive" : "🔥"
        case .userInitiated: return withName ? "2️⃣ UserInitiated" : "2️⃣"
        case .default: return withName ? "3️⃣ Default" : "3️⃣"
        case .utility: return withName ? "4️⃣ Utility" : "4️⃣"
        case .background: return withName ? "5️⃣ Background" : "5️⃣"
        default: return withName ? "6️⃣ Unknown" : "6️⃣"
        }
    }
    
    static public var initLog: String {
        let qos = Thread.current.qualityOfService
        let qosDesc = qosDescription(qos, withName: false)
        
        return "\(qosDesc) 🚀 | Init"
    }
    
    static var threadInfo: String {
        let qos = Thread.current.qualityOfService
        let qosDesc = qosDescription(qos, withName: false)
        
        return "\(Thread.isMainThread ? "1️⃣ " : "🛞 ") \(qosDesc) | "
    }
    
    static func getAuthor(_ className: Any) -> String {
        String("\(type(of: className))".dropLast(5))
    }
    
    static func m(_ className: Any, _ message: String) -> String {
        threadInfo + " " + getAuthor(className) + ": \(message)"
    }
    
    static let loggingSubsystem: String = "app"
    static let app = Logger(subsystem: Self.loggingSubsystem, category: "APP")
    static let ui = Logger(subsystem: Self.loggingSubsystem, category: "UI")
    static let database = Logger(subsystem: Self.loggingSubsystem, category: "Database")
    static let dataModel = Logger(subsystem: Self.loggingSubsystem, category: "DataModel")
    
    static func category(_ category: String)-> Logger {
        Logger(subsystem: Self.loggingSubsystem, category: category)
    }
}
