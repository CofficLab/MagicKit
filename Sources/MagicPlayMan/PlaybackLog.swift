import Foundation

public struct PlaybackLog: Identifiable {
    public let id = UUID()
    public let timestamp: Date
    public let level: Level
    public let message: String
    
    public enum Level: String {
        case info
        case warning
        case error
        
        var symbol: String {
            switch self {
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            }
        }
    }
}

extension PlaybackLog {
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: timestamp)
    }
    
    var formattedMessage: String {
        "[\(formattedTimestamp)] \(level.symbol) \(message)"
    }
} 