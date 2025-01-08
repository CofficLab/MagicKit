import MagicUI
import SwiftUI

struct MagicAppDemoView: View {
    @State private var appName: String = MagicApp.getAppName()
    @State private var version: String = MagicApp.getVersion()
    @State private var buildNumber: String = MagicApp.getBuildNumber()
    @State private var isICloudEnabled: Bool = MagicApp.isICloudAvailable()
    @State private var deviceName: String = MagicApp.getDeviceName()
    @State private var deviceModel: String = MagicApp.getDeviceModel()
    @State private var systemVersion: String = MagicApp.getSystemVersion()
    @State private var availableStorage: String = MagicApp.getAvailableStorage().map { MagicApp.formatBytes(bytes: $0) } ?? "Unknown"
    @State private var totalStorage: String = MagicApp.getTotalStorage().map { MagicApp.formatBytes(bytes: $0) } ?? "Unknown"
    @State private var iCloudTotalStorage: String = "Unknown"
    @State private var iCloudAvailableStorage: String = "Unknown"

    var body: some View {
        MagicThemePreview {
            VStack(alignment: .leading, spacing: 20) {
                // 应用信息
                GroupBox(label: Text("应用信息")) {
                    VStack(alignment: .leading, spacing: 8) {
                        LabeledContent("应用名称", value: appName)
                        LabeledContent("版本", value: version)
                        LabeledContent("构建号", value: buildNumber)
                        LabeledContent("Bundle ID", value: MagicApp.getBundleIdentifier())
                    }
                    .padding(.top, 4)
                }

                // 设备信息
                GroupBox(label: Text("设备信息")) {
                    VStack(alignment: .leading, spacing: 8) {
                        LabeledContent("设备名称", value: deviceName)
                        LabeledContent("设备型号", value: deviceModel)
                        LabeledContent("系统版本", value: systemVersion)
                    }
                    .padding(.top, 4)
                }

                // 存储信息
                GroupBox(label: Text("存储信息")) {
                    VStack(alignment: .leading, spacing: 8) {
                        LabeledContent("可用空间", value: availableStorage)
                        LabeledContent("总空间", value: totalStorage)
                    }
                    .padding(.top, 4)
                }

                // iCloud 状态
                GroupBox(label: Text("iCloud 状态")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("iCloud Drive")
                            Spacer()
                            Text(isICloudEnabled ? "已启用" : "未启用")
                                .foregroundColor(isICloudEnabled ? .green : .red)
                        }
                        
                        LabeledContent("总容量", value: iCloudTotalStorage)
                        LabeledContent("可用容量", value: iCloudAvailableStorage)
                    }
                    .padding(.top, 4)
                }

                // 退出按钮
                Button("退出应用", role: .destructive) {
                    MagicApp.quit()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)
            }
            .padding()
            .task {
                await getICloudStorageInfo()
            }
        }
    }
    
    @MainActor
    private func getICloudStorageInfo() async {
        // 获取 iCloud 总容量
        do {
            let total = try MagicApp.getICloudTotalStorage()
            iCloudTotalStorage = MagicApp.formatBytes(bytes: total)
        } catch let error as iCloudStorageError {
            iCloudTotalStorage = error.localizedDescription
        } catch {
            iCloudTotalStorage = "未知错误: \(error.localizedDescription)"
        }
        
        // 获取 iCloud 可用容量
        do {
            let available = try MagicApp.getICloudAvailableStorage()
            iCloudAvailableStorage = MagicApp.formatBytes(bytes: available)
        } catch let error as iCloudStorageError {
            iCloudAvailableStorage = error.localizedDescription
        } catch {
            iCloudAvailableStorage = "未知错误: \(error.localizedDescription)"
        }
    }
}

#Preview("MagicApp 功能演示") {
    MagicAppDemoView()
}
