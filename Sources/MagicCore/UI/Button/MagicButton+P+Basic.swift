import SwiftUI

struct BasicButtonsPreview: View {
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
        }
        .padding()
    }
}

#Preview {
    BasicButtonsPreview()
        .inMagicContainer()
}