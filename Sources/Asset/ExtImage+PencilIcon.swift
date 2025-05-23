import MagicCore
import SwiftUI

public extension Image {
    static func makePencilIcon(
        useDefaultBackground: Bool = true,
        borderColor: Color = .blue,
        size: CGFloat? = nil
    ) -> some View {
        IconContainer(size: size) {
            PencilIcon(
                useDefaultBackground: useDefaultBackground,
                borderColor: borderColor
            )
        }
    }
}

struct PencilIcon: View {
    let useDefaultBackground: Bool
    let borderColor: Color

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                if useDefaultBackground {
                    MagicBackground.forest
                }

                // 圆角矩形边框
                RoundedRectangle(cornerRadius: size * 0.2)
                    .stroke(borderColor, lineWidth: size * 0.08)
                    .frame(width: size * 0.9, height: size * 0.9)

                // 使用系统铅笔图标
                Image(systemName: "pencil")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size * 0.3)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.brown, Color(red: 0.4, green: 0.8, blue: 0.8), .blue],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .rotationEffect(.degrees(0))
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
            }
        }
    }
}

#Preview {
    IconPreviewHelper(title: "Pencil Icon") {
        Image.makePencilIcon()
    }
}
