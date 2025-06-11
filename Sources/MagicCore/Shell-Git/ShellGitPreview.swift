import SwiftUI

struct ShellGitPreviewView: View {
    @State private var debugInfo: [String] = []
    
    private func appendDebug(_ text: String) {
        debugInfo.insert(text, at: 0)
        if debugInfo.count > 10 { debugInfo = Array(debugInfo.prefix(10)) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🔧 Git 命令演示")
                .font(.title)
                .bold()
            
            if !debugInfo.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("调试信息：")
                        .font(.headline)
                    ForEach(debugInfo, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }
                }
                .padding(8)
                .background(.background)
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "仓库信息", icon: "📁") {
                        VDemoButton("检查是否为Git仓库", action: {
                            let isRepo = ShellGit.isGitRepository()
                            appendDebug("是否为Git仓库: \(isRepo)")
                        })
                        
                        VDemoButton("获取当前分支", action: {
                            do {
                                let branch = try ShellGit.currentBranch()
                                appendDebug("当前分支: \(branch)")
                            } catch {
                                appendDebug("获取当前分支失败: \(error)")
                            }
                        })
                        
                        VDemoButton("获取仓库状态", action: {
                            do {
                                let status = try ShellGit.status()
                                let message = status.isEmpty ? "工作区干净" : status
                                appendDebug("仓库状态: \(message)")
                            } catch {
                                appendDebug("获取仓库状态失败: \(error)")
                            }
                        })
                    }
                    
                    VDemoSection(title: "分支操作", icon: "🌿") {
                        VDemoButton("获取分支列表", action: {
                            do {
                                let branches = try ShellGit.branches()
                                appendDebug("分支列表:\n\(branches)")
                            } catch {
                                appendDebug("获取分支列表失败: \(error)")
                            }
                        })
                        
                        VDemoButton("获取远程分支", action: {
                            do {
                                let branches = try ShellGit.branches(includeRemote: true)
                                appendDebug("所有分支:\n\(branches)")
                            } catch {
                                appendDebug("获取远程分支失败: \(error)")
                            }
                        })
                    }
                    
                    VDemoSection(title: "提交历史", icon: "📝") {
                        VDemoButton("获取提交日志", action: {
                            do {
                                let log = try ShellGit.log(limit: 5)
                                appendDebug("最近5次提交:\n\(log)")
                            } catch {
                                appendDebug("获取提交日志失败: \(error)")
                            }
                        })
                        
                        VDemoButton("获取最新提交哈希", action: {
                            do {
                                let hash = try ShellGit.lastCommitHash(short: true)
                                appendDebug("最新提交哈希: \(hash)")
                            } catch {
                                appendDebug("获取提交哈希失败: \(error)")
                            }
                        })
                    }
                    
                    VDemoSection(title: "远程仓库", icon: "🌐") {
                        VDemoButton("获取远程仓库", action: {
                            do {
                                let remotes = try ShellGit.remotes(verbose: true)
                                appendDebug("远程仓库:\n\(remotes)")
                            } catch {
                                appendDebug("获取远程仓库失败: \(error)")
                            }
                        })
                    }
                    
                    VDemoSection(title: "暂存操作", icon: "📦") {
                        VDemoButton("获取暂存列表", action: {
                            do {
                                let stashes = try ShellGit.stashList()
                                let message = stashes.isEmpty ? "无暂存" : stashes
                                appendDebug("暂存列表:\n\(message)")
                            } catch {
                                appendDebug("获取暂存列表失败: \(error)")
                            }
                        })
                    }
                    
                    VDemoSection(title: "标签管理", icon: "🏷️") {
                        VDemoButton("获取标签列表", action: {
                            do {
                                let tags = try ShellGit.tags()
                                let message = tags.isEmpty ? "无标签" : tags
                                appendDebug("标签列表:\n\(message)")
                            } catch {
                                appendDebug("获取标签列表失败: \(error)")
                            }
                        })
                    }
                    
                    VDemoSection(title: "用户配置", icon: "👤") {
                        VDemoButton("获取用户配置", action: {
                            do {
                                let config = try ShellGit.getUserConfig(global: true)
                                appendDebug("全局用户配置:\n用户名: \(config.name)\n邮箱: \(config.email)")
                            } catch {
                                appendDebug("获取用户配置失败: \(error)")
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