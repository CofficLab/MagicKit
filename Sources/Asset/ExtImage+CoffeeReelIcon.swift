import Core
import SwiftUI

public extension Image {
    static func makeCoffeeReelIcon(
        useDefaultBackground: Bool = true,
        plateColor: Color = .white,
        size: CGFloat? = nil
    ) -> some View {
        IconContainer(size: size) {
            CoffeeReelIcon(
                useDefaultBackground: useDefaultBackground,
                plateColor: plateColor
            )
        }
    }
}

struct CoffeeReelIcon: View {
    let showBrownCircle: Bool = true
    let showRedCircle: Bool = false
    let useDefaultBackground: Bool
    let plateColor: Color
    let cupColor: Color = Color(red: 0.8, green: 0.6, blue: 0.2)

    init(useDefaultBackground: Bool = true, plateColor: Color = .white) {
        self.useDefaultBackground = useDefaultBackground
        self.plateColor = plateColor
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let plateSize = size * 0.6 // 盘子尺寸略小于整体视图
            let cupSize = plateSize * 0.8
            let brownCircleSize = cupSize * 1
            let redCircleSize = brownCircleSize * 0.5
            let dotSize = redCircleSize * 0.5
            let dotOffset = redCircleSize * 0.5
            let centerDotSize = dotSize * 0.6
            let handleWidth = cupSize * 0.16
            let handleLength = cupSize * 0.7

            ZStack {
                if useDefaultBackground {
                    // 渐变背景
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.5, blue: 0.4),
                            Color(red: 0.2, green: 0.5, blue: 0.7),
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    Color.clear
                }

                // 盘子背景
                Circle()
                    .stroke(plateColor, lineWidth: plateSize - cupSize)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 3)
                    .frame(width: plateSize, height: plateSize)
                    .mask {
                        // 咖啡杯手柄
                        Circle()
                            .stroke(.white, lineWidth: plateSize - cupSize)
                            .frame(width: plateSize, height: plateSize)
                            .overlay {
                                Capsule()
                                    .frame(width: handleLength, height: handleWidth)
                                    .offset(x: cupSize * 0.3)
                                    .rotationEffect(.degrees(30))
                                    .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
                                    .blendMode(.destinationOut)
                            }
                    }

                // 咖啡杯图标
                Circle()
                    .fill(Color.clear)
                    .stroke(cupColor, lineWidth: 14)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                    .frame(width: cupSize, height: cupSize)

                // 咖啡色圆形和圆点
                if showBrownCircle {
                    Circle()
                        .fill(Color(red: 0.35, green: 0.22, blue: 0.17))
                        .frame(width: brownCircleSize, height: brownCircleSize)
                        .mask {
                            Circle()
                                .fill(Color.white)
                                .frame(width: brownCircleSize, height: brownCircleSize)
                                .overlay {
                                    ZStack {
                                        // 四个蓝色圆点位置的遮罩
                                        ForEach(0 ..< 4) { index in
                                            Circle()
                                                .frame(width: dotSize, height: dotSize)
                                                .offset(
                                                    x: dotOffset * cos(Double(index) * .pi / 2),
                                                    y: dotOffset * sin(Double(index) * .pi / 2)
                                                )
                                                .blendMode(.destinationOut)
                                        }
                                        // 中心小圆点位置的遮罩
                                        Circle()
                                            .frame(width: centerDotSize, height: centerDotSize)
                                            .blendMode(.destinationOut)
                                    }
                                }
                        }
                }
            }
        }
    }
}

#Preview {
    IconPreviewHelper(title: "Coffee Reel Icon") {
        Image.makeCoffeeReelIcon()
    }
}
