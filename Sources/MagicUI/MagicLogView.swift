import SwiftUI

/// 通用日志条目模型
public struct MagicLogEntry: Identifiable {
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
        
        public var color: Color {
            switch self {
            case .info: return .primary
            case .warning: return .orange
            case .error: return .red
            }
        }
        
        public var icon: String {
            switch self {
            case .info: return "info.circle"
            case .warning: return "exclamationmark.triangle"
            case .error: return "xmark.circle"
            }
        }
    }
}

/// 通用日志视图组件
public struct MagicLogView: View {
    let logs: [MagicLogEntry]
    let onClear: () -> Void
    @State private var copiedLogId: UUID?
    @State private var showToast = false
    @State private var toastMessage = ""
    
    public init(logs: [MagicLogEntry], onClear: @escaping () -> Void) {
        self.logs = logs
        self.onClear = onClear
    }
    
    public var body: some View {
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
                
                MagicButton(
                    icon: "trash",
                    style: .secondary,
                    size: .small,
                    shape: .circle,
                    action: onClear
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
        "\(log.timestamp.logTime) [\(log.level)] \(log.message)"
    }
    
    private func logColor(for level: MagicLogEntry.Level) -> Color {
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
    MagicLogView(logs: [
        MagicLogEntry(message: "This is an info message", level: .info),
        MagicLogEntry(message: "This is a warning message", level: .warning),
        MagicLogEntry(message: "This is an error message", level: .error)
    ], onClear: {})
    .frame(width: 400, height: 300)
    .padding()
}

// MARK: - Date Extension

extension Date {
    var logTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self)
    }
}

// MARK: - String Extension

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension String {
    func copy() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(self, forType: .string)
        #else
        UIPasteboard.general.string = self
        #endif
    }
} 