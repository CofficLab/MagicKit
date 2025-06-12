import SwiftUI

struct ShellGitRemotePreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🌐 Remote 演示")
                .font(.title)
                .bold()
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "远程仓库操作", icon: "🌐") {
                        VDemoButtonWithLog("获取远程仓库列表", action: {
                            do {
                                let remotes = try ShellGit.remotes(verbose: true)
                                return remotes.isEmpty ? "无远程仓库" : remotes
                            } catch {
                                return "获取远程仓库失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("添加远程仓库", action: {
                            do {
                                let result = try ShellGit.addRemote("test-remote", url: "https://github.com/example/repo.git")
                                return "添加远程仓库结果: \(result)"
                            } catch {
                                return "添加远程仓库失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("删除远程仓库", action: {
                            do {
                                let result = try ShellGit.removeRemote("test-remote")
                                return "删除远程仓库结果: \(result)"
                            } catch {
                                return "删除远程仓库失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("获取第一个远程仓库URL", action: {
                            do {
                                let url = try ShellGit.firstRemoteURL()
                                return url ?? "无远程仓库URL"
                            } catch {
                                return "获取远程仓库URL失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("推送到远程仓库", action: {
                            do {
                                let result = try ShellGit.push()
                                return "推送结果: \(result)"
                            } catch {
                                return "推送失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("从远程仓库拉取", action: {
                            do {
                                let result = try ShellGit.pull()
                                return "拉取结果: \(result)"
                            } catch {
                                return "拉取失败: \(error.localizedDescription)"
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

#Preview("ShellGit+Remote Demo") {
    ShellGitRemotePreview()
        .inMagicContainer()
} 
