import SwiftUI
import MagicUI

struct LogView: View {
    let logs: [PlaybackLog]
    let onClear: () -> Void
    @State private var copiedLogId: UUID?
    @State private var showCopyAllToast = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Logs")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                MagicButton(
                    icon: "doc.on.doc",
                    title: "Copy All",
                    style: .secondary,
                    size: .small,
                    shape: .capsule,
                    action: copyAllLogs
                )
                
                MagicButton(
                    icon: "trash",
                    title: "Clear",
                    style: .secondary,
                    size: .small,
                    shape: .capsule,
                    action: onClear
                )
            }
            .overlay {
                if showCopyAllToast {
                    Text("All logs copied!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            Table(logs.reversed()) {
                TableColumn("Level") { log in
                    Circle()
                        .fill(logColor(for: log.level))
                        .frame(width: 8, height: 8)
                }
                .width(20)
                
                TableColumn("Time") { log in
                    Text(log.timestamp.logTime)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
                .width(70)
                
                TableColumn("Message") { log in
                    Text(log.message)
                        .font(.caption)
                        .foregroundStyle(log.level == .error ? .red : .primary)
                }
                
                TableColumn("") { log in
                    CopyColumn(log: log, copiedLogId: copiedLogId, onCopy: copyLog)
                }
                .width(50)
            }
        }
    }
    
    private func copyAllLogs() {
        logs.map { formatLogEntry($0) }
            .joined(separator: "\n")
            .copy()
        
        withAnimation {
            showCopyAllToast = true
        }
        
        // 2秒后隐藏提示
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopyAllToast = false
            }
        }
    }
    
    private func copyLog(_ log: PlaybackLog) {
        formatLogEntry(log).copy()
        
        withAnimation {
            copiedLogId = log.id
        }
        
        // 2秒后清除复制状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                if copiedLogId == log.id {
                    copiedLogId = nil
                }
            }
        }
    }
    
    private func formatLogEntry(_ log: PlaybackLog) -> String {
        "\(log.timestamp.logTime) [\(log.level)] \(log.message)"
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
    
    private struct CopyColumn: View {
        let log: PlaybackLog
        let copiedLogId: UUID?
        let onCopy: (PlaybackLog) -> Void
        
        var body: some View {
            HStack {
                if copiedLogId == log.id {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.green)
                        .font(.caption)
                        .transition(.scale.combined(with: .opacity))
                }
                
                Button(action: { onCopy(log) }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            .animation(.default, value: copiedLogId)
        }
    }
}

#Preview("With Logs") {
    MagicPlayMan.PreviewView(showLogs: true)
        .frame(width: 650, height: 650)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
}
