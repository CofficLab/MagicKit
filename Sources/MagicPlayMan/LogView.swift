import MagicKit
import SwiftUI

struct LogView: View {
    let logs: [PlaybackLog]
    let onClear: () -> Void
    
    var body: some View {
        MagicLogView(
            logs: logs.map { log in
                MagicLogEntry(
                    message: log.message,
                    level: mapLevel(log.level),
                    timestamp: log.timestamp
                )
            },
            onClear: onClear
        )
    }
    
    private func mapLevel(_ level: PlaybackLog.Level) -> MagicLogEntry.Level {
        switch level {
        case .info:
            return .info
        case .warning:
            return .warning
        case .error:
            return .error
        }
    }
}

#Preview("With Logs") {
    MagicPlayMan.PreviewView(showLogs: true)
}
