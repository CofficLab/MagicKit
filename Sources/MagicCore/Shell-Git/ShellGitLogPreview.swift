import SwiftUI

struct ShellGitLogPreview: View {
    @State private var repoPath: String? = nil
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    
    private let repoURL = "https://github.com/CofficLab/MagicKit"
    private let tempDirName = "MagicKitDemoRepo"
    
    private func prepareRepoIfNeeded(completion: @escaping (String?) -> Void) {
        let tempDir = NSTemporaryDirectory().appending(tempDirName)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: tempDir + "/.git") {
            completion(tempDir)
            return
        }
        DispatchQueue.global().async {
            do {
                if fileManager.fileExists(atPath: tempDir) {
                    try fileManager.removeItem(atPath: tempDir)
                }
                _ = try ShellGit.clone(self.repoURL, to: tempDir)
                DispatchQueue.main.async { completion(tempDir) }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Clone 失败: \(error.localizedDescription)"
                    completion(nil)
                }
            }
        }
    }
    
    private func ensureRepo() {
        isLoading = true
        errorMessage = nil
        prepareRepoIfNeeded { path in
            self.repoPath = path
            self.isLoading = false
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("📝 Log 演示")
                .font(.title)
                .bold()
            if isLoading {
                ProgressView("正在准备演示仓库...")
                    .onAppear { ensureRepo() }
            } else if let error = errorMessage {
                Text(error).foregroundColor(.red)
                Button("重试") { ensureRepo() }
            } else if let repoPath = repoPath {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        VDemoSection(title: "提交日志", icon: "📝") {
                            VDemoButtonWithLog("获取提交日志 (字符串)", action: {
                                do {
                                    let log = try ShellGit.log(limit: 5, at: repoPath)
                                    return "最近5次提交:\n\(log)"
                                } catch {
                                    return "获取提交日志失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("获取提交日志 (数组)", action: {
                                do {
                                    let logs = try ShellGit.logArray(limit: 5, at: repoPath)
                                    return logs.isEmpty ? "无提交记录" : logs.joined(separator: "\n")
                                } catch {
                                    return "获取提交日志数组失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("未推送到远程的提交", action: {
                                do {
                                    let commits = try ShellGit.unpushedCommits(at: repoPath)
                                    return commits.isEmpty ? "所有提交已同步到远程" : commits.joined(separator: "\n")
                                } catch {
                                    return "获取未推送提交失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("带标签的提交列表", action: {
                                do {
                                    let commits = try ShellGit.commitsWithTags(limit: 10, at: repoPath)
                                    if commits.isEmpty { return "无提交" }
                                    return commits.map { c in
                                        if c.tags.isEmpty {
                                            return "\(c.hash.prefix(7))  \(c.message)"
                                        } else {
                                            return "\(c.hash.prefix(7))  \(c.message)  [tags: \(c.tags.joined(separator: ", "))]"
                                        }
                                    }.joined(separator: "\n")
                                } catch {
                                    return "获取带标签的提交失败: \(error.localizedDescription)"
                                }
                            })
                        }
                    }
                    .padding()
                }
            }
        }
        .padding()
    }
}

#Preview("ShellGit+Log Demo") {
    ShellGitLogPreview()
        .inMagicContainer()
} 