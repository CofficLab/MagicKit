import SwiftUI

struct ShapeVisibilityButtonsPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("显示变体")
                .font(.headline)

            VStack(spacing: 16) {
                Text("始终显示形状").font(.subheadline)
                HStack {
                    MagicButton(icon: "star")
                        .magicTitle("Always")
                        .magicShapeVisibility(.always)
                        .magicDebugBorder()

                    MagicButton(icon: "star")
                        .magicStyle(.primary)
                        .magicTitle("Always")
                        .magicShapeVisibility(.always)
                        .magicDebugBorder()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(spacing: 16) {
                Text("悬停时显示形状").font(.subheadline)
                HStack {
                    MagicButton(icon: "star")
                        .magicTitle("On Hover")
                        .magicShapeVisibility(.onHover)
                        .magicDebugBorder()

                    MagicButton(icon: "star")
                        .magicStyle(.primary)
                        .magicTitle("On Hover")
                        .magicShapeVisibility(.onHover)
                        .magicDebugBorder()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}

#Preview {
    ShapeVisibilityButtonsPreview()
        .inMagicContainer()
}