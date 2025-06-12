import SwiftUI

struct ShellGitResetPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("♻️ Reset 演示")
                .font(.title)
                .bold()
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "重置操作", icon: "♻️") {
                        VDemoButtonWithLog("软重置所有文件", action: {
                            do {
                                let result = try ShellGit.reset()
                                return "软重置结果: \(result)"
                            } catch {
                                return "软重置失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("硬重置所有文件", action: {
                            do {
                                let result = try ShellGit.reset(hard: true)
                                return "硬重置结果: \(result)"
                            } catch {
                                return "硬重置失败: \(error.localizedDescription)"
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

#Preview("ShellGit+Reset Demo") {
    ShellGitResetPreview()
        .inMagicContainer()
} 