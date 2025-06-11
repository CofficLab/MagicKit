import SwiftUI

struct ShellGitPreviewView: View {
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🔧 Git 命令演示")
                .font(.title)
                .bold()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "仓库信息", icon: "📁") {
                        VDemoButtonWithLog("检查是否为Git仓库", action: {
                            let isRepo = ShellGit.isGitRepository()
                            return "是否为Git仓库: \(isRepo)"
                        })
                        
                        VDemoButtonWithLog("获取当前分支", action: {
                            do {
                                let branch = try ShellGit.currentBranch()
                                return "当前分支: \(branch)"
                            } catch {
                                return "获取当前分支失败: \(error.localizedDescription)"
                            }
                        })
                        
                        VDemoButtonWithLog("获取仓库状态", action: {
                            do {
                                let status = try ShellGit.status()
                                let message = status.isEmpty ? "工作区干净" : status
                                return "仓库状态: \(message)"
                            } catch {
                                return "获取仓库状态失败: \(error.localizedDescription)"
                            }
                        })
                    }
                    
                    VDemoSection(title: "分支操作", icon: "🌿") {
                        VDemoButtonWithLog("获取分支列表", action: {
                            do {
                                let branches = try ShellGit.branches()
                                return "分支列表:\n\(branches)"
                            } catch {
                                return "获取分支列表失败: \(error.localizedDescription)"
                            }
                        })
                        
                        VDemoButtonWithLog("获取远程分支", action: {
                            do {
                                let branches = try ShellGit.branches(includeRemote: true)
                                return "所有分支:\n\(branches)"
                            } catch {
                                return "获取远程分支失败: \(error.localizedDescription)"
                            }
                        })
                    }
                    
                    VDemoSection(title: "提交历史", icon: "📝") {
                        VDemoButtonWithLog("获取提交日志", action: {
                            do {
                                let log = try ShellGit.log(limit: 5)
                                return "最近5次提交:\n\(log)"
                            } catch {
                                return "获取提交日志失败: \(error.localizedDescription)"
                            }
                        })
                        
                        VDemoButtonWithLog("获取最新提交哈希", action: {
                            do {
                                let hash = try ShellGit.lastCommitHash(short: true)
                                return "最新提交哈希: \(hash)"
                            } catch {
                                return "获取提交哈希失败: \(error.localizedDescription)"
                            }
                        })
                    }
                    
                    VDemoSection(title: "远程仓库", icon: "🌐") {
                        VDemoButtonWithLog("获取远程仓库", action: {
                            do {
                                let remotes = try ShellGit.remotes(verbose: true)
                                return "远程仓库:\n\(remotes)"
                            } catch {
                                return "获取远程仓库失败: \(error.localizedDescription)"
                            }
                        })
                    }
                    
                    VDemoSection(title: "暂存操作", icon: "📦") {
                        VDemoButtonWithLog("获取暂存列表", action: {
                            do {
                                let stashes = try ShellGit.stashList()
                                let message = stashes.isEmpty ? "无暂存" : stashes
                                return "暂存列表:\n\(message)"
                            } catch {
                                return "获取暂存列表失败: \(error.localizedDescription)"
                            }
                        })
                    }
                    
                    VDemoSection(title: "标签管理", icon: "🏷️") {
                        VDemoButtonWithLog("获取标签列表", action: {
                            do {
                                let tags = try ShellGit.tags()
                                let message = tags.isEmpty ? "无标签" : tags
                                return "标签列表:\n\(message)"
                            } catch {
                                return "获取标签列表失败: \(error.localizedDescription)"
                            }
                        })
                    }
                    
                    VDemoSection(title: "用户配置", icon: "👤") {
                        VDemoButtonWithLog("获取用户配置", action: {
                            do {
                                let config = try ShellGit.getUserConfig(global: true)
                                return "全局用户配置:\n用户名: \(config.name)\n邮箱: \(config.email)"
                            } catch {
                                return "获取用户配置失败: \(error.localizedDescription)"
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

#Preview("ShellGit Demo") {
    ShellGitPreviewView()
        .inMagicContainer()
} 