import MagicKit
import SwiftUI

public extension Image {
    static func makeBookIcon(
        useDefaultBackground: Bool = true,
        borderColor: Color = .blue,
        size: CGFloat? = nil,
        shape: IconShape = .circle
    ) -> some View {
        IconContainer(size: size, shape: shape) {
            BookIcon(
                useDefaultBackground: useDefaultBackground,
                borderColor: borderColor
            )
        }
    }
}

struct BookIcon: View {
    let useDefaultBackground: Bool
    let borderColor: Color

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            ZStack {
                // 背景层：紫色到蓝色的渐变，营造知识的神秘感
                if useDefaultBackground {
                    LinearGradient(
                        colors: [.purple.opacity(0.6), .blue.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    Color.clear
                }

                // 边框层：圆角矩形边框，提供图标的基本轮廓
                RoundedRectangle(cornerRadius: size * 0.2)
                    .stroke(borderColor, lineWidth: size * 0.08)
                    .frame(width: size * 0.9, height: size * 0.9)

                // 图标层：书本图标带有渐变色填充
                Image(systemName: "book.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size * 0.5) // 控制书本图标大小为容器的一半
                    .foregroundStyle(
                        // 橙色到紫色的渐变，模拟书本的光泽和质感
                        .linearGradient(
                            colors: [.orange, .red, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    // 添加阴影增加立体感
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 2, y: 2)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        IconPreviewHelper(title: "Book Icon (Default)") {
            Image.makeBookIcon()
        }
        
        IconPreviewHelper(title: "Book Icon (Circle)") {
            Image.makeBookIcon(shape: .circle)
        }
        
        IconPreviewHelper(title: "Book Icon (Rectangle)") {
            Image.makeBookIcon(shape: .rectangle)
        }
        
        IconPreviewHelper(title: "Book Icon (Custom Rounded)") {
            Image.makeBookIcon(shape: .roundedRectangle(radius: 24))
        }
    }
}
