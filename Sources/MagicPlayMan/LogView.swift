import SwiftUI
import MagicUI

struct LogView: View {
    let logs: [PlaybackLog]
    let onClear: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Logs")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                MagicButton(
                    icon: "trash",
                    title: "Clear",
                    style: .secondary,
                    size: .small,
                    shape: .capsule,
                    action: onClear
                )
            }
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(logs.reversed()) { log in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(logColor(for: log.level))
                                .frame(width: 8, height: 8)
                            
                            Text(formatTime(log.timestamp))
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                            
                            Text(log.message)
                                .font(.caption)
                                .foregroundStyle(log.level == .error ? .red : .primary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
    }
    
    private func logColor(for level: PlaybackLog.Level) -> Color {
        switch level {
        case .info:
            return .green
        case .warning:
            return .orange
        case .error:
            return .red
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
} 