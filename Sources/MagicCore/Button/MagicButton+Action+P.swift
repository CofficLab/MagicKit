import SwiftUI

struct LoadingAndPreventDoubleClickPreview: View {
    @State private var message = "点击按钮测试功能"

    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .font(.title2)
                .padding()

            // 同步操作示例（向后兼容）
            MagicButton.simple(
                icon: "heart.fill",
                title: "同步操作",
                style: .primary,
                size: .auto,
                preventDoubleClick: true,
                loadingStyle: .spinner
            ) {
                message = "执行同步操作..."
                // 模拟CPU密集型同步操作
                let startTime = Date()
                var result = 0.0
                while Date().timeIntervalSince(startTime) < 1.0 {
                    result += sin(Double.random(in: 0...1000))
                }
                DispatchQueue.main.async {
                    message = "同步操作完成！"
                }
            }
            .frame(width: 200, height: 50)

            // 用户控制完成的同步操作示例
            MagicButton(
                icon: "star.fill",
                title: "用户控制完成",
                style: .secondary,
                size: .auto,
                preventDoubleClick: true,
                loadingStyle: .dots
            ) { completion in
                print("🔥 开始执行用户控制的操作")
                
                // 立即更新message
                DispatchQueue.main.async {
                    message = "执行用户控制的操作..."
                }
                
                // 模拟耗时操作
                DispatchQueue.global().async {
                    Thread.sleep(forTimeInterval: 2.0)
                    
                    DispatchQueue.main.async {
                        message = "用户控制的操作完成！"
                        // 用户主动调用完成回调
                        completion()
                    }
                }
            }
            .frame(width: 200, height: 50)

            // 异步操作示例
            MagicButton(
                icon: "cloud.fill",
                title: "异步操作",
                style: .custom(.blue),
                size: .auto,
                preventDoubleClick: true,
                loadingStyle: .spinner
            ) { completion in
                Task {
                    await MainActor.run {
                        message = "执行异步操作..."
                    }
                    
                    // 模拟网络请求
                    try? await Task.sleep(nanoseconds: 2000000000)
                    
                    await MainActor.run {
                        message = "异步操作完成！"
                        // 异步操作完成后调用回调
                        completion()
                    }
                }
            }
            .frame(width: 200, height: 50)

            // 条件完成示例
            MagicButton(
                icon: "checkmark.circle.fill",
                title: "条件完成",
                style: .custom(.green),
                size: .auto,
                preventDoubleClick: true,
                loadingStyle: .pulse
            ) { completion in
                let shouldSucceed = Bool.random()
                
                Task {
                    await MainActor.run {
                        message = shouldSucceed ? "执行成功操作..." : "执行失败操作..."
                    }
                    
                    try? await Task.sleep(nanoseconds: 1500000000)
                    
                    await MainActor.run {
                        if shouldSucceed {
                            message = "操作成功完成！"
                            completion()
                        } else {
                            message = "操作失败，继续loading..."
                            // 不调用completion()，保持loading状态
                        }
                    }
                }
            }
            .frame(width: 200, height: 50)

            // 多步骤操作示例
            MagicButton(
                icon: "gearshape.fill",
                title: "多步骤操作",
                style: .custom(.orange),
                size: .auto,
                preventDoubleClick: true,
                loadingStyle: .spinner
            ) { completion in
                Task {
                    // 步骤1
                    await MainActor.run {
                        message = "步骤1: 准备数据..."
                    }
                    try? await Task.sleep(nanoseconds: 800000000)
                    
                    // 步骤2
                    await MainActor.run {
                        message = "步骤2: 处理数据..."
                    }
                    try? await Task.sleep(nanoseconds: 800000000)
                    
                    // 步骤3
                    await MainActor.run {
                        message = "步骤3: 保存结果..."
                    }
                    try? await Task.sleep(nanoseconds: 800000000)
                    
                    // 完成
                    await MainActor.run {
                        message = "多步骤操作完成！"
                        completion()
                    }
                }
            }
            .frame(width: 200, height: 50)

            // 禁用防重复点击的按钮
            MagicButton.simple(
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
