import SwiftUI
import MagicKit

public extension Image {
    static func makePencilIcon(useDefaultBackground: Bool = true, borderColor: Color = .blue) -> some View {
        PencilIcon(useDefaultBackground: useDefaultBackground, borderColor: borderColor)
    }
}

struct PencilIcon: View {
    let useDefaultBackground: Bool
    let borderColor: Color
    
    init(useDefaultBackground: Bool = true, borderColor: Color = .blue) {
        self.useDefaultBackground = useDefaultBackground
        self.borderColor = borderColor
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            
            ZStack {
                if useDefaultBackground {
                    MagicBackground.forest
                } else {
                    Color.clear
                }
                
                // 圆角矩形边框
                RoundedRectangle(cornerRadius: size * 0.2)
                    .stroke(borderColor, lineWidth: size * 0.08)
                    .frame(width: size * 0.7, height: size * 0.7)
                
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
    MagicThemePreview {
        VStack(spacing: 20) {
            Image.makePencilIcon(useDefaultBackground: true)
                .frame(width: 500, height: 500)
            
            Image.makePencilIcon(useDefaultBackground: false, borderColor: .red)
                .frame(width: 500, height: 500)
                .background(Color.gray.opacity(0.2))
        }
    }
} 
