import SwiftUI

struct ShellGitDiffPreview: View {
    var body: some View {
        ShellGitExampleRepoView { repoPath in
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "差异对比", icon: "📄") {
                        VDemoButtonWithLog("获取工作区差异", action: {
                            do {
                                let diff = try ShellGit.diff(at: repoPath)
                                return diff.isEmpty ? "无差异" : diff
                            } catch {
                                return "获取差异失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("获取暂存区差异", action: {
                            do {
                                let diff = try ShellGit.diff(staged: true, at: repoPath)
                                return diff.isEmpty ? "无暂存区差异" : diff
                            } catch {
                                return "获取暂存区差异失败: \(error.localizedDescription)"
                            }
                        })
                    }
                }
                .padding()
            }
        }
    }
}

#Preview("ShellGit+Diff Demo") {
    ShellGitDiffPreview()
        .inMagicContainer()
} 