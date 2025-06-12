import SwiftUI

#if DEBUG
    struct MagicToastExampleView: View {
        @StateObject private var messageProvider = MagicMessageProvider()

        var body: some View {
            VStack(spacing: 20) {
                Text("Magic Toast 示例")
                    .font(.title)

                Button("信息") {
                    messageProvider.showInfo("这是信息", subtitle: "详细描述")
                }

                Button("成功") {
                    messageProvider.showSuccess("操作成功")
                }

                Button("警告") {
                    messageProvider.showWarning("注意事项")
                }

                Button("错误") {
                    messageProvider.showError("操作失败", autoDismiss: false)
                }

                Button("加载中") {
                    messageProvider.showLoading("正在处理...")
                }

                Button("隐藏加载") {
                    messageProvider.hideLoading()
                }
            }
            .buttonStyle(.bordered)
            .padding()
            .environmentObject(messageProvider)
        }
    }
#endif

#if DEBUG
#Preview {
    MagicRootView {
        MagicToastExampleView()
    }
    .frame(width: 400, height: 600)
}
#endif
