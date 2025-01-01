import SwiftUI

public struct MagicBackground: View {
    var colorScheme: ColorScheme = .light
    
    public var body: some View {
        Self.frost
    }
    
    static public var frost: some View {
        ZStack {
            Color.white.opacity(0.2)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.3),
                    Color.white.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var modernPurple: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "c471ed"),
                    Color(hex: "f64f59")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }
    
    static public var aurora: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "43cea2"),
                    Color(hex: "185a9d")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            Color.white.opacity(0.1)
                .blur(radius: 15)
        }
        .ignoresSafeArea()
    }
    
    static public var nightSky: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "141e30"),
                    Color(hex: "243b55")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            Color.white.opacity(0.1)
                .blur(radius: 0.5)
        }
        .ignoresSafeArea()
    }
    
    static public var sunset: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "ff6e7f"),
                    Color(hex: "bfe9ff")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
    
    static public var techGradient: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "0f2027"),
                    Color(hex: "203a43"),
                    Color(hex: "2c5364")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Color.white.opacity(0.05)
                .blur(radius: 1)
        }
        .ignoresSafeArea()
    }
    
    static public var oceanDepth: some View {
        ZStack {
            Color(hex: "141e30").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "141e30"),
                    Color(hex: "243b55")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var mint: some View {
        ZStack {
            Color(hex: "e6fffa").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "e6fffa"),
                    Color(hex: "a3f7bf")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var roseGold: some View {
        ZStack {
            Color(hex: "ffd700").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "ffd700"),
                    Color(hex: "ffa700")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var deepSpace: some View {
        ZStack {
            Color(hex: "141e30").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "141e30"),
                    Color(hex: "243b55")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var auroraBlue: some View {
        ZStack {
            Color(hex: "43cea2").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "43cea2"),
                    Color(hex: "185a9d")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var softCoral: some View {
        ZStack {
            Color(hex: "ff7f50").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "ff7f50"),
                    Color(hex: "ff6347")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var neonGlow: some View {
        ZStack {
            Color(hex: "ff00ff").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "ff00ff"),
                    Color(hex: "ff00ff")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var limeLight: some View {
        ZStack {
            Color(hex: "7fff00").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "7fff00"),
                    Color(hex: "7fff00")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var bloodyOrange: some View {
        ZStack {
            Color(hex: "ff4500").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "ff4500"),
                    Color(hex: "ff4500")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var serenityBlue: some View {
        ZStack {
            Color(hex: "00bfff").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "00bfff"),
                    Color(hex: "00bfff")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var darkForest: some View {
        ZStack {
            Color(hex: "1e3932").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "1e3932"),
                    Color(hex: "2c5364")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var cherryBlossom: some View {
        ZStack {
            Color(hex: "ff1493").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "ff1493"),
                    Color(hex: "ff1493")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var auroraGreen: some View {
        ZStack {
            Color(hex: "7fff00").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "7fff00"),
                    Color(hex: "7fff00")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var deepPurple: some View {
        ZStack {
            Color(hex: "4b0082").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "4b0082"),
                    Color(hex: "4b0082")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var sunrise: some View {
        ZStack {
            Color(hex: "ffa500").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "ffa500"),
                    Color(hex: "ffa500")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var lavender: some View {
        ZStack {
            Color(hex: "9a7bff").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "9a7bff"),
                    Color(hex: "9a7bff")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var oceanBreeze: some View {
        ZStack {
            Color(hex: "48c6ef").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "48c6ef"),
                    Color(hex: "6f86d6")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var warmSunset: some View {
        ZStack {
            Color(hex: "ff512f").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "ff512f"),
                    Color(hex: "dd2476")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var midnightDream: some View {
        ZStack {
            Color(hex: "000428").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "000428"),
                    Color(hex: "004e92")
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            .blur(radius: 10)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var musicNight: some View {
        ZStack {
            Color(hex: "1a1a1a").opacity(0.9)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "4a148c").opacity(0.6),  // 深紫色
                    Color(hex: "311b92").opacity(0.4),  // 靛蓝色
                    Color(hex: "880e4f").opacity(0.5)   // 深玫瑰色
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 添加轻微的光晕效果
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "e040fb").opacity(0.15),  // 霓虹紫
                    Color.clear
                ]),
                center: .topLeading,
                startRadius: 100,
                endRadius: 400
            )
            .blur(radius: 15)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var forestMist: some View {
        ZStack {
            Color(hex: "2c4c3b").opacity(0.8)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "2c4c3b"),  // 深森林绿
                    Color(hex: "1a332b"),  // 暗绿色
                    Color(hex: "365c49")   // 苔藓绿
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 添加薄雾效果
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.1),
                    Color.clear
                ]),
                center: .top,
                startRadius: 200,
                endRadius: 600
            )
            .blur(radius: 20)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var cyberNeon: some View {
        ZStack {
            Color.black.opacity(0.9)
            
            // 主渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "ff00ff").opacity(0.3),  // 霓虹粉
                    Color(hex: "00ffff").opacity(0.3)   // 霓虹青
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 网格效果
            GeometryReader { geometry in
                Path { path in
                    let step: CGFloat = 40
                    for x in stride(from: 0, to: geometry.size.width, by: step) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    }
                    for y in stride(from: 0, to: geometry.size.height, by: step) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                }
                .stroke(Color(hex: "00ffff").opacity(0.2), lineWidth: 0.5)
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var pastelDream: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "ffd1ff").opacity(0.7),  // 柔和粉
                    Color(hex: "fae8ff").opacity(0.7),  // 淡紫
                    Color(hex: "e8f0ff").opacity(0.7)   // 淡蓝
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 添加柔和光斑
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 50)
                .offset(x: -100, y: -100)
            
            Circle()
                .fill(Color(hex: "ffd1ff").opacity(0.1))
                .frame(width: 250, height: 250)
                .blur(radius: 40)
                .offset(x: 100, y: 100)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var desertSands: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "c2b280"),  // 沙色
                    Color(hex: "d4ac6e"),  // 暖棕
                    Color(hex: "b8860b")   // 暗金
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 沙丘纹理效果
            ZStack {
                ForEach(0..<3) { i in
                    Wave(phase: .degrees(Double(i) * 60))
                        .fill(Color.white.opacity(0.1))
                        .blur(radius: 20)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var frostMorning: some View {
        ZStack {
            Color(hex: "e0e0e0").opacity(0.5)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.6),
                    Color.white.opacity(0.2)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 15)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var frostNight: some View {
        ZStack {
            Color(hex: "1a1a1a").opacity(0.5)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.1),
                    Color.white.opacity(0.05)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 15)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var frostLavender: some View {
        ZStack {
            Color(hex: "e6e6fa").opacity(0.5)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "e6e6fa").opacity(0.6),
                    Color(hex: "e6e6fa").opacity(0.2)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 15)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var frostMint: some View {
        ZStack {
            Color(hex: "98ff98").opacity(0.3)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "98ff98").opacity(0.4),
                    Color(hex: "98ff98").opacity(0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 15)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
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

#Preview("Background") {
    ScrollView {
        HStack(spacing: 0) {
            // Light mode
            VStack(spacing: 20) {
                Group {
                    BackgroundPreviewItem(background: AnyView(MagicBackground.frost), title: "Frost", textColor: .primary)
                    BackgroundPreviewItem(background: AnyView(MagicBackground.modernPurple), title: "Modern Purple")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.aurora), title: "Aurora")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.nightSky), title: "Night Sky")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.sunset), title: "Sunset", textColor: .primary)
                    BackgroundPreviewItem(background: AnyView(MagicBackground.techGradient), title: "Tech Gradient")
                }
                
                Group {
                    BackgroundPreviewItem(background: AnyView(MagicBackground.oceanDepth), title: "Ocean Depth")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.mint), title: "Mint")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.roseGold), title: "Rose Gold", textColor: .primary)
                    BackgroundPreviewItem(background: AnyView(MagicBackground.deepSpace), title: "Deep Space")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.auroraBlue), title: "Aurora Blue")
                }
                
                Group {
                    BackgroundPreviewItem(background: AnyView(MagicBackground.softCoral), title: "Soft Coral", textColor: .primary)
                    BackgroundPreviewItem(background: AnyView(MagicBackground.neonGlow), title: "Neon Glow")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.limeLight), title: "Lime Light")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.bloodyOrange), title: "Bloody Orange")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.serenityBlue), title: "Serenity Blue")
                }
                
                Group {
                    BackgroundPreviewItem(background: AnyView(MagicBackground.darkForest), title: "Dark Forest")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.cherryBlossom), title: "Cherry Blossom")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.auroraGreen), title: "Aurora Green")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.deepPurple), title: "Deep Purple")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.sunrise), title: "Sunrise")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.lavender), title: "Lavender", textColor: .primary)
                }
                
                Group {
                    BackgroundPreviewItem(background: AnyView(MagicBackground.oceanBreeze), title: "Ocean Breeze")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.warmSunset), title: "Warm Sunset")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.midnightDream), title: "Midnight Dream")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.musicNight), title: "Music Night")
                }
                
                Group {
                    BackgroundPreviewItem(background: AnyView(MagicBackground.forestMist), title: "Forest Mist")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.cyberNeon), title: "Cyber Neon")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.pastelDream), title: "Pastel Dream", textColor: .primary)
                    BackgroundPreviewItem(background: AnyView(MagicBackground.desertSands), title: "Desert Sands", textColor: .primary)
                }
                
                Group {
                    BackgroundPreviewItem(background: AnyView(MagicBackground.frostMorning), title: "Frost Morning", textColor: .primary)
                    BackgroundPreviewItem(background: AnyView(MagicBackground.frostNight), title: "Frost Night")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.frostLavender), title: "Frost Lavender", textColor: .primary)
                    BackgroundPreviewItem(background: AnyView(MagicBackground.frostMint), title: "Frost Mint", textColor: .primary)
                }
            }
            .padding()
            .environment(\.colorScheme, .light)
            
            // Dark mode
            VStack(spacing: 20) {
                Group {
                    BackgroundPreviewItem(background: AnyView(MagicBackground.frost), title: "Frost", textColor: .primary)
                    BackgroundPreviewItem(background: AnyView(MagicBackground.modernPurple), title: "Modern Purple")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.aurora), title: "Aurora")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.nightSky), title: "Night Sky")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.sunset), title: "Sunset", textColor: .primary)
                    BackgroundPreviewItem(background: AnyView(MagicBackground.techGradient), title: "Tech Gradient")
                }
                
                Group {
                    BackgroundPreviewItem(background: AnyView(MagicBackground.oceanDepth), title: "Ocean Depth")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.mint), title: "Mint")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.roseGold), title: "Rose Gold", textColor: .primary)
                    BackgroundPreviewItem(background: AnyView(MagicBackground.deepSpace), title: "Deep Space")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.auroraBlue), title: "Aurora Blue")
                }
                
                Group {
                    BackgroundPreviewItem(background: AnyView(MagicBackground.softCoral), title: "Soft Coral", textColor: .primary)
                    BackgroundPreviewItem(background: AnyView(MagicBackground.neonGlow), title: "Neon Glow")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.limeLight), title: "Lime Light")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.bloodyOrange), title: "Bloody Orange")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.serenityBlue), title: "Serenity Blue")
                }
                
                Group {
                    BackgroundPreviewItem(background: AnyView(MagicBackground.darkForest), title: "Dark Forest")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.cherryBlossom), title: "Cherry Blossom")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.auroraGreen), title: "Aurora Green")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.deepPurple), title: "Deep Purple")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.sunrise), title: "Sunrise")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.lavender), title: "Lavender", textColor: .primary)
                }
                
                Group {
                    BackgroundPreviewItem(background: AnyView(MagicBackground.oceanBreeze), title: "Ocean Breeze")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.warmSunset), title: "Warm Sunset")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.midnightDream), title: "Midnight Dream")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.musicNight), title: "Music Night")
                }
                
                Group {
                    BackgroundPreviewItem(background: AnyView(MagicBackground.forestMist), title: "Forest Mist")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.cyberNeon), title: "Cyber Neon")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.pastelDream), title: "Pastel Dream", textColor: .primary)
                    BackgroundPreviewItem(background: AnyView(MagicBackground.desertSands), title: "Desert Sands", textColor: .primary)
                }
                
                Group {
                    BackgroundPreviewItem(background: AnyView(MagicBackground.frostMorning), title: "Frost Morning", textColor: .primary)
                    BackgroundPreviewItem(background: AnyView(MagicBackground.frostNight), title: "Frost Night")
                    BackgroundPreviewItem(background: AnyView(MagicBackground.frostLavender), title: "Frost Lavender", textColor: .primary)
                    BackgroundPreviewItem(background: AnyView(MagicBackground.frostMint), title: "Frost Mint", textColor: .primary)
                }
            }
            .padding()
            .background(.background)
            .environment(\.colorScheme, .dark)
        }
    }
    .frame(height: 800)
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
