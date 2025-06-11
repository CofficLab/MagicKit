import SwiftUI

struct ShellProcessPreviewView: View {
    @State private var debugInfo: [String] = []
    
    private func appendDebug(_ text: String) {
        debugInfo.insert(text, at: 0)
        if debugInfo.count > 10 { debugInfo = Array(debugInfo.prefix(10)) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("⚙️ ShellProcess 功能演示")
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
                    VDemoSection(title: "进程查找", icon: "🔍") {
                        VDemoButton("查找Finder进程", action: {
                            let processes = ShellProcess.findProcesses(named: "Finder")
                            appendDebug("找到 \(processes.count) 个Finder进程")
                            processes.prefix(3).forEach { process in
                                appendDebug("PID: \(process.pid), CPU: \(process.cpu)%, 内存: \(process.memory)%")
                            }
                        })
                        
                        VDemoButton("检查Chrome是否运行", action: {
                            let isRunning = ShellProcess.isProcessRunning("Chrome")
                            let message = isRunning ? "是" : "否"
                            appendDebug("Chrome是否运行: \(message)")
                        })
                        
                        VDemoButton("获取正在运行的应用", action: {
                            let apps = ShellProcess.getRunningApps()
                            appendDebug("正在运行的应用: \(apps.prefix(5))")
                        })
                    }
                    
                    VDemoSection(title: "系统资源", icon: "📊") {
                        VDemoButton("系统负载", action: {
                            let load = ShellProcess.getSystemLoad()
                            appendDebug("系统负载: \(load)")
                        })
                        
                        VDemoButton("内存使用情况", action: {
                            let memory = ShellProcess.getMemoryUsage()
                            let lines = memory.components(separatedBy: .newlines)
                            appendDebug("内存使用情况（前5行）:\n\(lines.prefix(5).joined(separator: "\n"))")
                        })
                    }
                    
                    VDemoSection(title: "TOP进程", icon: "🏆") {
                        VDemoButton("CPU使用率最高的进程", action: {
                            let processes = ShellProcess.getTopCPUProcesses(count: 5)
                            appendDebug("CPU使用率最高的5个进程:")
                            processes.forEach { process in
                                appendDebug("\(process.command.prefix(30)) - CPU: \(process.cpu)%")
                            }
                        })
                        
                        VDemoButton("内存使用率最高的进程", action: {
                            let processes = ShellProcess.getTopMemoryProcesses(count: 5)
                            appendDebug("内存使用率最高的5个进程:")
                            processes.forEach { process in
                                appendDebug("\(process.command.prefix(30)) - 内存: \(process.memory)%")
                            }
                        })
                    }
                    
                    VDemoSection(title: "应用程序管理", icon: "📱") {
                        VDemoButton("启动计算器", action: {
                            do {
                                try ShellProcess.launchApp("Calculator")
                                appendDebug("计算器已启动")
                            } catch {
                                appendDebug("启动计算器失败: \(error)")
                            }
                        })
                        
                        VDemoButton("启动文本编辑器", action: {
                            do {
                                try ShellProcess.launchApp("TextEdit")
                                appendDebug("文本编辑器已启动")
                            } catch {
                                appendDebug("启动文本编辑器失败: \(error)")
                            }
                        })
                    }
                    
                    VDemoSection(title: "进程详情", icon: "🔬") {
                        VProcessDetailView()
                    }
                    
                    VDemoSection(title: "系统服务", icon: "🛠️") {
                        VDemoButton("查看系统服务", action: {
                            let services = ShellProcess.getSystemServices()
                            let lines = services.components(separatedBy: .newlines)
                            appendDebug("系统服务（前10个）:\n\(lines.prefix(10).joined(separator: "\n"))")
                        })
                    }
                    
                    VDemoSection(title: "危险操作", icon: "⚠️") {
                        Text("注意：以下操作可能影响系统稳定性")
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        VDemoButton("杀死测试进程（安全）", action: {
                            // 这里只是演示，不会真的杀死重要进程
                            appendDebug("这是一个安全的演示，不会真的杀死进程")
                            appendDebug("实际使用时请谨慎操作")
                        })
                    }
                }
                .padding()
            }
        }
        .padding()
    }
}

#Preview("ShellProcess Demo") {
    ShellProcessPreviewView()
        .inMagicContainer()
}