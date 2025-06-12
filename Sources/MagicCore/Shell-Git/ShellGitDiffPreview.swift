import SwiftUI

struct ShellGitDiffPreview: View {
    @State private var fileName: String = "README.md"
    @State private var headContent: String = ""
    @State private var workContent: String = ""
    @State private var error: String? = nil
    @State private var showResult: Bool = false

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
                    VDemoSection(title: "文件内容对比", icon: "📝") {
                        HStack {
                            TextField("文件名（相对路径）", text: $fileName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("对比") {
                                do {
                                    headContent = try ShellGit.fileContent(atCommit: "HEAD", file: fileName, at: repoPath)
                                    workContent = try ShellGit.fileContentInWorkingDirectory(file: fileName, at: repoPath)
                                    error = nil
                                    showResult = true
                                } catch let e {
                                    error = e.localizedDescription
                                    showResult = false
                                }
                            }
                        }
                        if let error = error {
                            Text("错误: \(error)").foregroundColor(.red)
                        }
                        if showResult {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("HEAD 内容:")
                                    .font(.caption)
                                ScrollView {
                                    Text(headContent)
                                        .font(.system(size: 12, design: .monospaced))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }.frame(maxHeight: 120)
                                    .background(Color.green.opacity(0.4))
                                Text("工作区内容:")
                                    .font(.caption)
                                ScrollView {
                                    Text(workContent)
                                        .font(.system(size: 12, design: .monospaced))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }.frame(maxHeight: 120)
                                    .background(Color.gray.opacity(0.4))
                            }
                            .padding(6)
                            .cornerRadius(8)
                        }
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
