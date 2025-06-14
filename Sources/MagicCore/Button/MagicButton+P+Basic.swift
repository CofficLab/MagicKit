import SwiftUI

struct BasicButtonsPreview: View {
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("基础按钮")
                .font(.headline)

            MagicButton(icon: "star")
                .magicTitle("默认按钮")

            MagicButton(icon: "star")
                .magicTitle("默认按钮")
                .magicDebugBorder()

            MagicButton(icon: "heart")
                .magicTitle("主要按钮")
                .magicStyle(.primary)

            MagicButton(icon: "trash")
                .magicTitle("次要按钮")
                .magicStyle(.secondary)
            
            // 测试加载状态的按钮
            MagicButton(
                icon: "arrow.clockwise",
                title: "Test Loading",
                style: .primary,
                loadingStyle: .spinner
            ) { completion in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    completion()
                }
            }
        }
        .padding()
    }
}

#Preview {
    BasicButtonsPreview()
        .inMagicContainer()
}