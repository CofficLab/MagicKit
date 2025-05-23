import MagicCore
import SwiftUI

/// Image 扩展，提供创建儿童教育图标的功能
public extension Image {
    /// 创建一个自定义的儿童教育图标
    ///
    /// 此方法创建一个可自定义的儿童教育图标，可用于应用中表示儿童教育、学习内容或儿童友好的功能。
    /// 图标采用明亮的色彩和活泼的设计，适合儿童教育类应用。
    ///
    /// - Parameters:
    ///   - useDefaultBackground: 是否使用默认的彩虹渐变背景，默认为 true
    ///   - borderColor: 图标边框的颜色，默认为蓝色
    ///   - size: 图标的大小，如果为 nil 则使用容器默认大小
    /// - Returns: 一个可以在 SwiftUI 视图中使用的儿童教育图标视图
    ///
    /// ## 使用示例:
    /// ```swift
    /// // 创建默认儿童教育图标
    /// Image.makeKidsEduIcon()
    ///
    /// // 创建自定义儿童教育图标
    /// Image.makeKidsEduIcon(
    ///     useDefaultBackground: false,
    ///     borderColor: .purple,
    ///     size: 120
    /// )
    /// ```
    static func makeKidsEduIcon(
        useDefaultBackground: Bool = true,
        borderColor: Color = .blue,
        size: CGFloat? = nil
    ) -> some View {
        IconContainer(size: size) {
            KidsEduIcon(
                useDefaultBackground: useDefaultBackground,
                borderColor: borderColor
            )
        }
    }
}

/// 儿童教育图标的内部实现
///
/// 这个结构体定义了儿童教育图标的视觉表现，包括彩虹背景、装饰性气泡和教育元素等。
/// 它被 `Image.makeKidsEduIcon` 方法使用，通常不需要直接使用此结构体。
struct KidsEduIcon: View {
    /// 是否使用默认的彩虹渐变背景
    let useDefaultBackground: Bool
    /// 图标边框的颜色
    let borderColor: Color

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                // 背景层：彩虹渐变背景
                if useDefaultBackground {
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.9, blue: 0.4), // 柔和的黄色
                            Color(red: 0.95, green: 0.8, blue: 0.9), // 柔和的粉色
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    // 装饰性气泡
                    ForEach(0 ..< 8) { index in
                        Circle()
                            .fill(
                                Color(
                                    hue: Double(index) / 8,
                                    saturation: 0.6,
                                    brightness: 0.9
                                ).opacity(0.3)
                            )
                            .frame(width: size * 0.1)
                            .offset(
                                x: CGFloat.random(in: -size / 3 ... size / 3),
                                y: CGFloat.random(in: -size / 3 ... size / 3)
                            )
                            .blur(radius: 2)
                    }
                }

                // 边框层：圆角矩形边框
                RoundedRectangle(cornerRadius: size * 0.2)
                    .stroke(borderColor, lineWidth: size * 0.08)
                    .frame(width: size * 0.9, height: size * 0.9)

                ZStack {
                    // 积木堆叠效果
                    ForEach(0 ..< 3) { index in
                        // 积木块
                        RoundedRectangle(cornerRadius: size * 0.05)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hue: Double(index) / 3, saturation: 0.6, brightness: 0.9),
                                        Color(hue: Double(index) / 3, saturation: 0.7, brightness: 0.7),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: size * 0.25, height: size * 0.25)
                            .rotationEffect(.degrees(Double(index * 15) - 15))
                            .offset(
                                x: CGFloat(index * 20) - 20,
                                y: CGFloat(index * 20) - 20
                            )
                            .shadow(color: .black.opacity(0.2), radius: 3, x: 2, y: 2)
                            .overlay(
                                // 积木上的字母
                                Text(String(["A", "B", "C"][index]))
                                    .font(.system(size: size * 0.15, weight: .bold))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.2), radius: 1, x: 1, y: 1)
                            )
                    }

                    // 铅笔装饰
                    Image(systemName: "pencil")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size * 0.3)
                        .rotationEffect(.degrees(45))
                        .offset(x: size * 0.2, y: -size * 0.15)
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // 星星装饰
                    Image(systemName: "star.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size * 0.15)
                        .offset(x: -size * 0.25, y: size * 0.2)
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .orange.opacity(0.3), radius: 4)
                }

                // 彩虹光晕效果
                Circle()
                    .fill(
                        AngularGradient(
                            colors: [.red, .yellow, .green, .blue, .purple, .red],
                            center: .center
                        )
                    )
                    .frame(width: size * 0.8, height: size * 0.8)
                    .opacity(0.1)
                    .blendMode(.softLight)
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        IconPreviewHelper(title: "Kids Edu Icon") {
            Image.makeKidsEduIcon()
        }

        IconPreviewHelper(title: "Kids Edu Icon (Custom)") {
            Image.makeKidsEduIcon(
                useDefaultBackground: false,
                borderColor: .purple
            )
        }
    }
}
