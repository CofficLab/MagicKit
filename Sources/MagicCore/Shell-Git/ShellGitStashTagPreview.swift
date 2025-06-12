import SwiftUI

struct ShellGitStashTagPreview: View {
    var body: some View {
        ShellGitExampleRepoView { repoPath in
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "暂存操作", icon: "📦") {
                        VDemoButtonWithLog("暂存更改", action: {
                            do {
                                let result = try ShellGit.stash("测试暂存", at: repoPath)
                                return "暂存结果: \(result)"
                            } catch {
                                return "暂存失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("恢复最新暂存", action: {
                            do {
                                let result = try ShellGit.stashPop(at: repoPath)
                                return "恢复结果: \(result)"
                            } catch {
                                return "恢复失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("获取暂存列表", action: {
                            do {
                                let list = try ShellGit.stashList(at: repoPath)
                                return list.isEmpty ? "无暂存" : list
                            } catch {
                                return "获取暂存列表失败: \(error.localizedDescription)"
                            }
                        })
                    }
                    VDemoSection(title: "标签管理", icon: "🏷️") {
                        VDemoButtonWithLog("获取标签列表", action: {
                            do {
                                let tags = try ShellGit.tags(at: repoPath)
                                return tags.isEmpty ? "无标签" : tags
                            } catch {
                                return "获取标签列表失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("创建标签", action: {
                            do {
                                let result = try ShellGit.createTag("test-tag", message: "测试标签", at: repoPath)
                                return "创建标签结果: \(result)"
                            } catch {
                                return "创建标签失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("删除标签", action: {
                            do {
                                let result = try ShellGit.deleteTag("test-tag", at: repoPath)
                                return "删除标签结果: \(result)"
                            } catch {
                                return "删除标签失败: \(error.localizedDescription)"
                            }
                        })
                    }
                }
                .padding()
            }
        }
    }
}

#Preview("ShellGit+StashTag Demo") {
    ShellGitStashTagPreview()
        .inMagicContainer()
} 