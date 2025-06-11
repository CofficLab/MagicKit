import SwiftUI

struct ShellFilePreviewView: View {
    @State private var debugInfo: [String] = []
    
    private func appendDebug(_ text: String) {
        debugInfo.insert(text, at: 0)
        if debugInfo.count > 10 { debugInfo = Array(debugInfo.prefix(10)) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🐚 ShellFile 功能演示")
                .font(.title)
                .bold()
            
            if !debugInfo.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("调试信息：")
                        .font(.headline)
                    ForEach(debugInfo, id: \ .self) { line in
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
                    VDemoSection(title: "文件操作", icon: "📁") {
                        VDemoButton("检查目录存在", action: {
                            let shell = ShellFile()
                            let exists = shell.isDirExists("/tmp")
                            appendDebug("目录 /tmp 存在: \(exists)")
                        })
                        
                        VDemoButton("创建测试目录", action: {
                            let shell = ShellFile()
                            shell.makeDir("/tmp/test_dir", verbose: true)
                            appendDebug("已尝试创建 /tmp/test_dir")
                        })
                        
                        VDemoButton("创建测试文件", action: {
                            let shell = ShellFile()
                            shell.makeFile("/tmp/test_file.txt", content: "Hello, World!")
                            appendDebug("已尝试创建 /tmp/test_file.txt")
                        })
                    }
                    
                    VDemoSection(title: "文件信息", icon: "ℹ️") {
                        VDemoButton("获取文件大小", action: {
                            let shell = ShellFile()
                            do {
                                let size = try shell.getFileSize("/tmp/test_file.txt")
                                appendDebug("文件大小: \(size) 字节")
                            } catch {
                                appendDebug("获取文件大小失败: \(error)")
                            }
                        })
                        
                        VDemoButton("获取文件权限", action: {
                            let shell = ShellFile()
                            do {
                                let permissions = try shell.getPermissions("/tmp/test_file.txt")
                                appendDebug("文件权限: \(permissions)")
                            } catch {
                                appendDebug("获取文件权限失败: \(error)")
                            }
                        })
                    }
                    
                    VDemoSection(title: "目录操作", icon: "📂") {
                        VDemoButton("列出文件", action: {
                            let shell = ShellFile()
                            do {
                                let files = try shell.listFiles("/tmp")
                                appendDebug("文件列表: \(Array(files.prefix(5)))")
                            } catch {
                                appendDebug("列出文件失败: \(error)")
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

#Preview("ShellFile Demo") {
    ShellFilePreviewView()
        .inMagicContainer()
}
