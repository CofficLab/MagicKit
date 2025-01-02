import Foundation
import SwiftUI
import OSLog

public class PlayLogger: ObservableObject {
    @Published public private(set) var logs: [PlaybackLog] = []
    private let maxLogs: Int
    
    public init(maxLogs: Int = 100) {
        self.maxLogs = maxLogs
    }
    
    /// 添加日志
    public func log(_ message: String, level: PlaybackLog.Level = .info) {
        let log = PlaybackLog(message: message, level: level)
        os_log("%{public}@", log: .default, type: level.osLogType, message)
        
        DispatchQueue.main.async {
            self.logs.append(log)
            // 保持日志数量在限制范围内
            if self.logs.count > self.maxLogs {
                self.logs.removeFirst(self.logs.count - self.maxLogs)
            }
        }
    }
    
    /// 清空日志
    public func clear() {
        logs.removeAll()
    }
    
    /// 创建日志视图
    public func makeLogView() -> some View {
        LogView(
            logs: logs,
            onClear: { [weak self] in
                self?.clear()
            }
        )
    }
}

// MARK: - Log Models

public struct PlaybackLog: Identifiable {
    public let id = UUID()
    public let message: String
    public let level: Level
    public let timestamp: Date
    
    public init(message: String, level: Level, timestamp: Date = Date()) {
        self.message = message
        self.level = level
        self.timestamp = timestamp
    }
    
    public enum Level {
        case info
        case warning
        case error
        
        var color: Color {
            switch self {
            case .info: return .primary
            case .warning: return .orange
            case .error: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .info: return "info.circle"
            case .warning: return "exclamationmark.triangle"
            case .error: return "xmark.circle"
            }
        }
        
        var osLogType: OSLogType {
            switch self {
            case .info: return .info
            case .warning: return .error
            case .error: return .fault
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let logger = PlayLogger()
    
    // 添加一些测试日志
    logger.log("Started playback", level: .info)
    logger.log("Network connection slow", level: .warning)
    logger.log("Failed to load media", level: .error)
    
    return logger.makeLogView()
        .frame(height: 200)
        .padding()
        .background(.ultraThinMaterial)
} 