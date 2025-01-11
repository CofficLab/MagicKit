import SwiftUI
import MagicKit

public extension Image {
    static func makeVideoPlayerIcon(useDefaultBackground: Bool = true, borderColor: Color = .blue) -> some View {
        VideoPlayerIcon(useDefaultBackground: useDefaultBackground, borderColor: borderColor)
    }
}

struct VideoPlayerIcon: View {
    let useDefaultBackground: Bool
    let borderColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            
            ZStack {
                // 背景层：深色渐变背景，营造影院氛围
                if useDefaultBackground {
                    LinearGradient(
                        colors: [
                            Color(red: 0.1, green: 0.1, blue: 0.2),
                            Color(red: 0.2, green: 0.2, blue: 0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    Color.clear
                }
                
                // 边框层：圆角矩形边框
                RoundedRectangle(cornerRadius: size * 0.2)
                    .stroke(borderColor, lineWidth: size * 0.08)
                    .frame(width: size * 0.9, height: size * 0.9)
                
                ZStack {
                    // 电影胶片效果
                    Image(systemName: "film")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size * 0.6)
                        .foregroundStyle(
                            // 银色渐变，模拟胶片质感
                            .linearGradient(
                                colors: [.gray.opacity(0.8), .white.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // 播放按钮：居中偏下
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size * 0.35)
                        .foregroundStyle(
                            // 红色渐变，突出播放按钮
                            .linearGradient(
                                colors: [.red.opacity(0.9), .orange.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .offset(y: size * 0.05) // 稍微向下偏移
                        
                    // 装饰性光效：顶部光晕
                    Circle()
                        .fill(
                            .radialGradient(
                                colors: [.white.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: size * 0.3
                            )
                        )
                        .frame(width: size * 0.4)
                        .offset(y: -size * 0.2)
                        .blendMode(.softLight)
                }
                // 整体阴影效果
                .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 3)
            }
        }
    }
}

#Preview {
    MagicThemePreview {
        VStack(spacing: 20) {
            Image.makeVideoPlayerIcon(useDefaultBackground: true)
                .frame(width: 500, height: 500)
            
            Image.makeVideoPlayerIcon(useDefaultBackground: false, borderColor: .red)
                .frame(width: 500, height: 500)
                .background(Color.gray.opacity(0.2))
        }
    }
} 