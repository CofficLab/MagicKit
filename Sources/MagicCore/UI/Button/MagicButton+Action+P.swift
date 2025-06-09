import SwiftUI

struct LoadingAndPreventDoubleClickPreview: View {
    @State private var message = "点击按钮测试功能"

    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .font(.title2)
                .padding()

            // 同步操作示例
            MagicButton(
                icon: "heart.fill",
                title: "同步操作",
                style: .primary,
                size: .auto,
                preventDoubleClick: true,
                loadingStyle: .spinner
            ) {
                message = "执行同步操作..."
                // 模拟短暂操作
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    message = "同步操作完成！"
                }
            }
            .frame(width: 200, height: 50)

            // 异步操作示例 - 旋转加载
            MagicButton(
                icon: "cloud.fill",
                title: "异步操作 (旋转)",
                style: .secondary,
                size: .auto,
                preventDoubleClick: true,
                loadingStyle: .spinner,
                asyncAction: {
                    message = "执行异步操作..."
                    // 模拟网络请求
                    try? await Task.sleep(nanoseconds: 2000000000)
                    message = "异步操作完成！"
                }
            )
            .frame(width: 200, height: 50)

            // 异步操作示例 - 点状加载
            MagicButton(
                icon: "star.fill",
                title: "异步操作 (点状)",
                style: .custom(.orange),
                size: .auto,
                preventDoubleClick: true,
                loadingStyle: .dots,
                asyncAction: {
                    message = "执行点状加载..."
                    try? await Task.sleep(nanoseconds: 1500000000)
                    message = "点状加载完成！"
                }
            )
            .frame(width: 200, height: 50)

            // 异步操作示例 - 脉冲加载
            MagicButton(
                icon: "bolt.fill",
                title: "异步操作 (脉冲)",
                style: .custom(.purple),
                size: .auto,
                preventDoubleClick: true,
                loadingStyle: .pulse,
                asyncAction: {
                    message = "执行脉冲加载..."
                    try? await Task.sleep(nanoseconds: 2500000000)
                    message = "脉冲加载完成！"
                }
            )
            .frame(width: 200, height: 50)

            // 禁用防重复点击的按钮
            MagicButton(
                icon: "exclamationmark.triangle.fill",
                title: "允许重复点击",
                style: .custom(.red),
                size: .auto,
                preventDoubleClick: false,
                loadingStyle: .none
            ) {
                message = "可以重复点击！"
            }
            .frame(width: 200, height: 50)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoadingAndPreventDoubleClickPreview()
        .inMagicContainer()
}
