import SwiftUI

/// 通用日志视图组件
public struct MagicLogView: View {
    @ObservedObject private var logger: MagicLogger
    let title: String
    let onClose: (() -> Void)?
    @State private var copiedLogId: UUID?
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var selectedCaller: String?

    public init(
        title: String = "Logs",
        logger: MagicLogger,
        onClose: (() -> Void)? = nil
    ) {
        self.title = title
        self.logger = logger
        self.onClose = onClose
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if let onClose {
                    MagicButton(
                        icon: "xmark",
                        style: .secondary,
                        size: .small,
                        shape: .circle,
                        action: {_ in
                            onClose()
                        }
                    )

                    Spacer()
                }

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text("(\(logger.app))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Menu {
                    Button("全部") {
                        selectedCaller = nil
                    }
                    
                    Divider()
                    
                    ForEach(Array(Set(logger.logs.map(\.caller))).sorted(), id: \.self) { caller in
                        Button(caller) {
                            selectedCaller = caller
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        if let selectedCaller {
                            Text(selectedCaller)
                                .lineLimit(1)
                        }
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                MagicButton(
                    icon: "doc.on.doc",
                    style: .secondary,
                    size: .small,
                    shape: .circle,
                    action: {_ in
                        copyAllLogs()}
                )

                MagicButton(
                    icon: "trash",
                    style: .secondary,
                    size: .small,
                    shape: .circle,
                    action: { _ in
                        logger.clearLogs() }
                )
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

            Table(logger.logs.filter { log in
                selectedCaller == nil || log.caller == selectedCaller
            }.reversed()) {
                TableColumn("Time") { log in
                    Text(log.timestamp.logTime)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
                .width(50)
                
                TableColumn("Line") { log in
                    if let line = log.line {
                        Text("\(line)")
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                    }
                }
                .width(28)
                
                TableColumn("Caller") { log in
                    Text(log.caller)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
                .width(150)

                TableColumn("Message") { log in
                    Text(log.message)
                        .font(.caption)
                        .foregroundStyle(logColor(for: log.level))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }

                TableColumn("") { log in
                    CopyColumn(log: log, copiedLogId: copiedLogId, onCopy: copyLog)
                }
                .width(30)
            }
        }
        .padding()
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
        logger.logs.map { formatLogEntry($0) }
            .joined(separator: "\n")
            .copy()

        showToastMessage("所有日志已复制")
    }

    private func copyLog(_ log: MagicLogEntry) {
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

    private func formatLogEntry(_ log: MagicLogEntry) -> String {
        "\(log.timestamp.logTime) [\(log.level)] [\(log.caller)] \(log.message)"
    }

    private func logColor(for level: MagicLogEntry.Level) -> Color {
        switch level {
        case .info:
            return .primary
        case .warning:
            return .orange
        case .error:
            return .red
        case .debug:
            return .blue
        }
    }

    private struct CopyColumn: View {
        let log: MagicLogEntry
        let copiedLogId: UUID?
        let onCopy: (MagicLogEntry) -> Void

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
    MagicThemePreview {
        let logger = MagicLogger.shared
        logger.logView()
            .frame(height: 500)
            .onAppear {
                logger.clearLogs()
                logger.info("This is an info message")
                logger.warning("This is a warning message")
                logger.error("This is an error message")
            }
    }
}
