import SwiftUI

struct ShellGitConfigInfoPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("⚙️ Config & Info 演示")
                .font(.title)
                .bold()
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "仓库信息", icon: "📁") {
                        VDemoButtonWithLog("检查是否为Git仓库", action: {
                            let isRepo = ShellGit.isGitRepository()
                            return "是否为Git仓库: \(isRepo)"
                        })
                        VDemoButtonWithLog("获取仓库根目录", action: {
                            do {
                                let root = try ShellGit.repositoryRoot()
                                return "仓库根目录: \(root)"
                            } catch {
                                return "获取仓库根目录失败: \(error.localizedDescription)"
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
                    VDemoSection(title: "用户配置", icon: "👤") {
                        VDemoButtonWithLog("获取用户配置", action: {
                            do {
                                let config = try ShellGit.getUserConfig(global: true)
                                return "全局用户配置:\n用户名: \(config.name)\n邮箱: \(config.email)"
                            } catch {
                                return "获取用户配置失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("配置用户信息", action: {
                            do {
                                let result = try ShellGit.configUser(name: "TestUser", email: "test@example.com", global: true)
                                return "配置结果: \(result)"
                            } catch {
                                return "配置失败: \(error.localizedDescription)"
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

#Preview("ShellGit+ConfigInfo Demo") {
    ShellGitConfigInfoPreview()
        .inMagicContainer()
} 