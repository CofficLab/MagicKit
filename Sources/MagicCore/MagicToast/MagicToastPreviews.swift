import SwiftUI

#if DEBUG
    struct MagicToastExampleView: View {
        private var messageProvider = MagicMessageProvider.shared

        var body: some View {
            VStack(spacing: 20) {
                Text("Magic Toast 示例")
                    .font(.title)

                Button("信息") {
                    messageProvider.info("这是信息", subtitle: "详细描述")
                }

                Button("成功") {
                    messageProvider.success("操作成功")
                }

                Button("警告") {
                    messageProvider.warning("注意事项")
                }

                Button("错误") {
                    messageProvider.error("操作失败", autoDismiss: false)
                }

                Button("加载中") {
                    messageProvider.loading("正在处理...")
                }

                Button("隐藏加载") {
                    messageProvider.hideLoading()
                }
            }
            .buttonStyle(.bordered)
            .padding()
        }
    }
#endif

#if DEBUG
#Preview {
    MagicToastExampleView()
        .withMagicToast()
        .frame(width: 400, height: 600)
}
#endif
