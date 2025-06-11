import SwiftUI

struct ShellNetworkPreviewView: View {
    @State private var debugInfo: [String] = []
    
    private func appendDebug(_ text: String) {
        debugInfo.insert(text, at: 0)
        if debugInfo.count > 10 { debugInfo = Array(debugInfo.prefix(10)) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🌐 ShellNetwork 功能演示")
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
                    VDemoSection(title: "连接测试", icon: "📡") {
                        VPingTestRow("google.com")
                        VPingTestRow("baidu.com")
                        VPingTestRow("github.com")
                        
                        VDemoButton("详细Ping测试", action: {
                            do {
                                let result = try ShellNetwork.pingDetailed("google.com", count: 3)
                                appendDebug("Ping结果:\n\(result)")
                            } catch {
                                appendDebug("Ping失败: \(error)")
                            }
                        })
                    }
                    
                    VDemoSection(title: "IP信息", icon: "🏠") {
                        VIPInfoRow("本机IP", ShellNetwork.getLocalIPs().first ?? "未知")
                        
                        VDemoButton("获取公网IP", action: {
                            let publicIP = ShellNetwork.getPublicIP()
                            appendDebug("公网IP: \(publicIP)")
                        })
                        
                        VDemoButton("所有本机IP", action: {
                            let ips = ShellNetwork.getLocalIPs()
                            appendDebug("本机IP列表: \(ips)")
                        })
                    }
                    
                    VDemoSection(title: "端口测试", icon: "🚪") {
                        VPortTestRow("google.com", 80)
                        VPortTestRow("google.com", 443)
                        VPortTestRow("github.com", 22)
                        VPortTestRow("localhost", 3000)
                    }
                    
                    VDemoSection(title: "HTTP测试", icon: "🌍") {
                        VHTTPStatusRow("https://www.google.com")
                        VHTTPStatusRow("https://www.github.com")
                        VHTTPStatusRow("https://httpstat.us/404")
                        
                        VDemoButton("获取HTTP头", action: {
                            do {
                                let headers = try ShellNetwork.getHeaders("https://www.google.com")
                                appendDebug("HTTP头信息:\n\(headers)")
                            } catch {
                                appendDebug("获取HTTP头失败: \(error)")
                            }
                        })
                    }
                    
                    VDemoSection(title: "网络信息", icon: "ℹ️") {
                        VDemoButton("网络接口状态", action: {
                            let status = ShellNetwork.getNetworkStatus()
                            appendDebug("网络接口状态:\n\(status)")
                        })
                        
                        VDemoButton("路由表", action: {
                            let routes = ShellNetwork.getRoutes()
                            let lines = routes.components(separatedBy: .newlines)
                            appendDebug("路由表（前10行）：\n\(lines.prefix(10).joined(separator: "\n"))")
                        })
                        
                        VDemoButton("WiFi信息", action: {
                            let wifi = ShellNetwork.getWiFiInfo()
                            appendDebug("WiFi信息:\n\(wifi)")
                        })
                    }
                    
                    VDemoSection(title: "DNS和路由", icon: "🔍") {
                        VDemoButton("DNS查询", action: {
                            do {
                                let result = try ShellNetwork.nslookup("google.com")
                                appendDebug("DNS查询结果:\n\(result)")
                            } catch {
                                appendDebug("DNS查询失败: \(error)")
                            }
                        })
                        
                        VDemoButton("路由追踪", action: {
                            do {
                                let result = try ShellNetwork.traceroute("8.8.8.8")
                                appendDebug("路由追踪结果:\n\(result)")
                            } catch {
                                appendDebug("路由追踪失败: \(error)")
                            }
                        })
                    }
                    
                    VDemoSection(title: "速度测试", icon: "⚡") {
                        VDemoButton("网络速度测试", action: {
                            let speed = ShellNetwork.speedTest()
                            appendDebug("网络速度: \(speed)")
                        })
                    }
                }
                .padding()
            }
        }
        .padding()
    }
}

#Preview("ShellNetwork Demo") {
    ShellNetworkPreviewView()
        .inMagicContainer()
} 