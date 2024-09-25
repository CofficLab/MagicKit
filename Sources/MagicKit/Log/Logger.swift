import OSLog

@available(macOS 11.0, *)
extension Logger {
    static public var initLog: String {
        threadName + "🚩 初始化"
    }
    
    static var threadName: String {
        "\(Thread.isMainThread ? "🔥 " : "")"
    }
    
    static func getAuthor(_ className: Any) -> String {
        String("\(type(of: className))".dropLast(5))
    }
    
    static func m(_ className: Any, _ message: String) -> String {
        threadName + " " + getAuthor(className) + ": \(message)"
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
