import SwiftUI

struct MagicAppDemoView: View {
    @State private var appName: String = MagicApp.getAppName()
    @State private var version: String = MagicApp.getVersion()
    @State private var isICloudEnabled: Bool = MagicApp.isICloudAvailable()
    
    var body: some View {
            List {
                Section("应用信息") {
                    LabeledContent("应用名称", value: appName)
                    LabeledContent("版本", value: version)
                }
                
                Section("iCloud 状态") {
                    LabeledContent {
                        Text(isICloudEnabled ? "已启用" : "未启用")
                            .foregroundStyle(isICloudEnabled ? .green : .red)
                    } label: {
                        Text("iCloud Drive")
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        MagicApp.quit()
                    } label: {
                        Text("退出应用")
                    }
                }
            }
            .navigationTitle("MagicApp Demo")
        }
}

#Preview("MagicApp 功能演示") {
    NavigationStack {
        MagicAppDemoView()
    }
}
