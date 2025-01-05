import Foundation
import SwiftUI
import OSLog
import MagicKit

public class PlayLogger: ObservableObject, SuperLog {
    public static var emoji = "🎵"
    
    @Published public private(set) var logs: [PlaybackLog] = []
    
    private let maxLogs: Int
    
    public init(maxLogs: Int = 100) {
        self.maxLogs = maxLogs
    }
    
    /// 添加日志
    public func log(
        _ message: String, 
        level: PlaybackLog.Level = .info,
        file: String = #file,
        line: Int = #line
    ) {
        let log = PlaybackLog(message: message, level: level)
        
        // 使用 OSLog API 记录日志，使用调用者的文件名和行号
        #if DEBUG
        os_log(
            level.osLogType,
            dso: #dsohandle,
            log: .default,
            "%{public}@:%d %{public}@",
            (file as NSString).lastPathComponent,
            line,
            message
        )
        #else
        os_log(level.osLogType, "%{public}@", message)
        #endif
        
        DispatchQueue.main.async {
            self.logs.append(log)
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
#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
}
