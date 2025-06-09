import SwiftUI

struct CustomShapeButtonsPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("自定义形状")
                .font(.headline)

            VStack(spacing: 16) {
                Text("自定义圆角矩形").font(.subheadline)
                VStack(spacing: 12) {
                    MagicButton(icon: "star")
                        .magicTitle("仅上圆角")
                        .magicShape(.customRoundedRectangle(
                            topLeft: 16,
                            topRight: 16,
                            bottomLeft: 0,
                            bottomRight: 0
                        ))
                        .magicDebugBorder()

                    MagicButton(icon: "star")
                        .magicTitle("仅右圆角")
                        .magicShape(.customRoundedRectangle(
                            topLeft: 0,
                            topRight: 16,
                            bottomLeft: 0,
                            bottomRight: 16
                        ))
                        .magicDebugBorder()

                    MagicButton(icon: "star")
                        .magicTitle("不同圆角")
                        .magicShape(.customRoundedRectangle(
                            topLeft: 8,
                            topRight: 16,
                            bottomLeft: 16,
                            bottomRight: 8
                        ))
                        .magicDebugBorder()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(spacing: 16) {
                Text("自定义胶囊形").font(.subheadline)
                VStack(spacing: 12) {
                    MagicButton(icon: "star")
                        .magicTitle("左大右小")
                        .magicShape(.customCapsule(
                            leftRadius: 24,
                            rightRadius: 8
                        ))

                    MagicButton(icon: "star")
                        .magicTitle("左小右大")
                        .magicShape(.customCapsule(
                            leftRadius: 8,
                            rightRadius: 24
                        ))
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
    CustomShapeButtonsPreview()
        .inMagicContainer()
}