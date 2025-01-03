import SwiftUI

public struct MagicBackground: View {
    var colorScheme: ColorScheme = .light
    
    public var body: some View {
        Self.frost
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct Wave: Shape {
    var phase: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height * 0.5
        let wavelength = width * 0.8
        let amplitude = height * 0.1
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / wavelength
            let sine = sin(relativeX * 2 * .pi + phase.radians)
            let y = midHeight + amplitude * sine
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

// 预览辅助视图
struct BackgroundPreviewItem: View {
    let background: AnyView
    let title: String
    var textColor: Color = .white
    
    init<V: View>(background: V, title: String, textColor: Color = .white) {
        self.background = AnyView(background)
        self.title = title
        self.textColor = textColor
    }
    
    var body: some View {
        ZStack {
            background
            Text(title)
                .foregroundColor(textColor)
        }
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// 添加主题预览容器
struct ThemePreviewContainer<Content: View>: View {
    let content: (ColorScheme) -> Content
    
    init(@ViewBuilder content: @escaping (ColorScheme) -> Content) {
        self.content = content
    }
    
    var body: some View {
            HStack(spacing: 0) {
                // 左侧明亮模式
                VStack(spacing: 20) {
                    content(.light)
                }
                .padding()
                .background(.background)
                .environment(\.colorScheme, .light)
                
                // 右侧暗色模式
                VStack(spacing: 20) {
                    content(.dark)
                }
                .padding()
                .background(.background)
                .environment(\.colorScheme, .dark)
            }
    }
}
