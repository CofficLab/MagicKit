import SwiftUI

struct ShellSystemPreviewView: View {
    @State private var debugInfo: [String] = []
    
    private func appendDebug(_ text: String) {
        debugInfo.insert(text, at: 0)
        if debugInfo.count > 10 { debugInfo = Array(debugInfo.prefix(10)) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("💻 ShellSystem 功能演示")
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
                    VDemoSection(title: "基本信息", icon: "ℹ️") {
                        VInfoRow("当前目录", ShellSystem.pwd())
                        VInfoRow("当前用户", ShellSystem.whoami())
                        VInfoRow("系统时间", ShellSystem.systemTime())
                    }
                    
                    VDemoSection(title: "硬件信息", icon: "🖥️") {
                        VInfoRow("CPU", ShellSystem.cpuInfo())
                        VInfoRow("内存", ShellSystem.memoryInfo())
                        
                        VDemoButton("获取系统版本", action: {
                            let version = ShellSystem.systemVersion()
                            appendDebug("系统版本:\n\(version)")
                        })
                    }
                    
                    VDemoSection(title: "系统状态", icon: "📊") {
                        VDemoButton("系统负载", action: {
                            let load = ShellSystem.loadAverage()
                            appendDebug("系统负载: \(load)")
                        })
                        
                        VDemoButton("磁盘使用情况", action: {
                            let disk = ShellSystem.diskUsage()
                            appendDebug("磁盘使用情况:\n\(disk)")
                        })
                        
                        VDemoButton("启动时间", action: {
                            let bootTime = ShellSystem.bootTime()
                            appendDebug("启动时间: \(bootTime)")
                        })
                    }
                    
                    VDemoSection(title: "环境变量", icon: "🌍") {
                        VDemoButton("PATH变量", action: {
                            let paths = ShellSystem.getPath()
                            appendDebug("PATH目录: \(paths.prefix(5))")
                        })
                        
                        VDemoButton("HOME目录", action: {
                            let home = ShellSystem.getEnvironmentVariable("HOME")
                            appendDebug("HOME目录: \(home)")
                        })
                    }
                    
                    VDemoSection(title: "命令检查", icon: "🔍") {
                        VCommandCheckRow("git")
                        VCommandCheckRow("node")
                        VCommandCheckRow("python3")
                        VCommandCheckRow("docker")
                    }
                    
                    VDemoSection(title: "进程信息", icon: "⚙️") {
                        VDemoButton("查看所有进程", action: {
                            let processes = ShellSystem.processes()
                            let lines = processes.components(separatedBy: .newlines)
                            appendDebug("进程总数: \(lines.count)")
                            appendDebug("前5个进程:\n\(lines.prefix(5).joined(separator: "\n"))")
                        })
                        
                        VDemoButton("查找特定进程", action: {
                            let processes = ShellSystem.processes(named: "Finder")
                            appendDebug("Finder进程:\n\(processes)")
                        })
                    }
                }
                .padding()
            }
        }
        .padding()
    }
}

#Preview("ShellSystem Demo") {
    ShellSystemPreviewView()
        .inMagicContainer()
} 