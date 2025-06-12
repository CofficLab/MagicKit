import SwiftUI

struct ShellGitLogPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("📝 Log 演示")
                .font(.title)
                .bold()
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "提交日志", icon: "📝") {
                        VDemoButtonWithLog("获取提交日志 (字符串)", action: {
                            do {
                                let log = try ShellGit.log(limit: 5)
                                return "最近5次提交:\n\(log)"
                            } catch {
                                return "获取提交日志失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("获取提交日志 (数组)", action: {
                            do {
                                let logs = try ShellGit.logArray(limit: 5)
                                return logs.isEmpty ? "无提交记录" : logs.joined(separator: "\n")
                            } catch {
                                return "获取提交日志数组失败: \(error.localizedDescription)"
                            }
                        })
                    }
                }
                .padding()
            }
        }
        .padding()
    }
}

#Preview("ShellGit+Log Demo") {
    ShellGitLogPreview()
        .inMagicContainer()
} 