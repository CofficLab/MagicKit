import MagicUI
import SwiftUI

struct LogView: View {
    let logs: [PlaybackLog]
    let onClear: () -> Void
    @State private var copiedLogId: UUID?
    @State private var showToast = false
    @State private var toastMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Logs")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer().frame(maxWidth: .infinity)

                MagicButton(
                    icon: "doc.on.doc",
                    style: .secondary,
                    size: .small,
                    shape: .circle,
                    action: copyAllLogs
                )
                .magicDebugBorder()

                MagicButton(
                    icon: "trash",
                    style: .secondary,
                    size: .small,
                    shape: .circle,
                    action: onClear
                )
                .magicDebugBorder()
            }
            .frame(height: 40)
            .overlay {
                if showToast {
                    Text(toastMessage)
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
                TableColumn("Time") { log in
                    Text(log.timestamp.logTime)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
                .width(50)

                TableColumn("Message") { log in
                    HStack {
                        Circle()
                            .fill(logColor(for: log.level))
                            .frame(width: 8, height: 8)

                        Text(log.message)
                            .font(.caption)
                            .foregroundStyle(log.level == .error ? .red : .primary)
                    }
                }

                TableColumn("") { log in
                    CopyColumn(log: log, copiedLogId: copiedLogId, onCopy: copyLog)
                }
                .width(30)
            }
        }
    }

    private func showToastMessage(_ message: String) {
        toastMessage = message
        withAnimation {
            showToast = true
        }

        // 2秒后隐藏提示
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }

    private func copyAllLogs() {
        logs.map { formatLogEntry($0) }
            .joined(separator: "\n")
            .copy()

        showToastMessage("所有日志已复制")
    }

    private func copyLog(_ log: PlaybackLog) {
        formatLogEntry(log).copy()

        withAnimation {
            copiedLogId = log.id
        }

        showToastMessage("日志已复制")

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
}
