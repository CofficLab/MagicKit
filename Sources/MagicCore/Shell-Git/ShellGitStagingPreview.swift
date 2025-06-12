import SwiftUI

struct ShellGitStagingPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("📥 Staging 演示")
                .font(.title)
                .bold()
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "暂存区操作", icon: "📥") {
                        VDemoButtonWithLog("添加所有文件到暂存区", action: {
                            do {
                                let result = try ShellGit.add()
                                return "添加结果: \(result)"
                            } catch {
                                return "添加失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("提交更改", action: {
                            do {
                                let result = try ShellGit.commit("测试提交")
                                return "提交结果: \(result)"
                            } catch {
                                return "提交失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("获取仓库状态", action: {
                            do {
                                let status = try ShellGit.status()
                                return status.isEmpty ? "工作区干净" : status
                            } catch {
                                return "获取状态失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("获取详细状态", action: {
                            do {
                                let status = try ShellGit.statusVerbose()
                                return status.isEmpty ? "无详细状态" : status
                            } catch {
                                return "获取详细状态失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("是否有未提交变动", action: {
                            do {
                                let hasChanges = try ShellGit.hasUncommittedChanges()
                                return hasChanges ? "有未提交变动" : "无未提交变动"
                            } catch {
                                return "检测失败: \(error.localizedDescription)"
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

#Preview("ShellGit+Staging Demo") {
    ShellGitStagingPreview()
        .inMagicContainer()
} 