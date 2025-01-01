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
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(logs.reversed()) { log in
                        LogEntryView(
                            log: log,
                            isCopied: copiedLogId == log.id,
                            onCopy: {
                                copyToClipboard(log)
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
                        )
                    }
                }
            }
        }
    }
    
    private func copyAllLogs() {
        let text = logs.map { formatLogEntry($0) }.joined(separator: "\n")
        copyToClipboard(text)
        
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
    
    private func formatLogEntry(_ log: PlaybackLog) -> String {
        "\(formatTime(log.timestamp)) [\(log.level)] \(log.message)"
    }
    
    private func copyToClipboard(_ log: PlaybackLog) {
        copyToClipboard(formatLogEntry(log))
    }
    
    private func copyToClipboard(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

private struct LogEntryView: View {
    let log: PlaybackLog
    let isCopied: Bool
    let onCopy: () -> Void
    @State private var isHovering = false
    
    var body: some View {
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
            
            if isHovering || isCopied {
                Spacer()
                
                Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                    .foregroundStyle(isCopied ? .green : .secondary)
                    .font(.caption)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.primary.opacity(isHovering ? 0.05 : 0))
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .onTapGesture(count: 2) {
            onCopy()
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

#Preview("With Logs") {
    MagicPlayMan.PreviewView(showLogs: true)
        .frame(width: 650, height: 650)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
}
