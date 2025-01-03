import SwiftUI

extension MagicBackground {
    static public var frost: some View {
        ZStack {
            // 基础毛玻璃效果
            Rectangle()
                .fill(.ultraThinMaterial)
            
            // 霜花效果
            GeometryReader { geometry in
                ForEach(0..<10) { _ in
                    Path { path in
                        let startPoint = CGPoint(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        path.move(to: startPoint)
                        
                        for _ in 0..<3 {
                            let endPoint = CGPoint(
                                x: startPoint.x + CGFloat.random(in: -20...20),
                                y: startPoint.y + CGFloat.random(in: -20...20)
                            )
                            path.addLine(to: endPoint)
                        }
                    }
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    .blur(radius: 1)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    static public var gradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "a8c0ff").opacity(0.7),
                Color(hex: "3f2b96").opacity(0.7)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var aurora: some View {
        ZStack {
            Color.black.opacity(0.8)
            
            // 极光效果
            GeometryReader { geometry in
                ForEach(0..<3) { index in
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.4))
                        path.addCurve(
                            to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.4),
                            control1: CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height * 0.3),
                            control2: CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height * 0.5)
                        )
                    }
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "00ff87").opacity(0.3),
                                Color(hex: "60efff").opacity(0.3)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 50
                    )
                    .blur(radius: 30)
                    .offset(y: CGFloat(index) * 30)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var ocean: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "1CB5E0").opacity(0.7),
                Color(hex: "000046").opacity(0.7)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var sunset: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "FF512F").opacity(0.7),
                Color(hex: "F09819").opacity(0.7)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var forest: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "134E5E").opacity(0.7),
                Color(hex: "71B280").opacity(0.7)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var lavender: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "E6E6FA").opacity(0.7),
                Color(hex: "9890E3").opacity(0.7)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var desert: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "FFB75E").opacity(0.7),
                Color(hex: "ED8F03").opacity(0.7)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var midnight: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "232526").opacity(0.7),
                Color(hex: "414345").opacity(0.7)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var cherry: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "EB3349").opacity(0.7),
                Color(hex: "F45C43").opacity(0.7)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var mint: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "00B09B").opacity(0.7),
                Color(hex: "96C93D").opacity(0.7)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var twilight: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "2C3E50").opacity(0.7),
                Color(hex: "3498DB").opacity(0.7)
            ]),
            startPoint: .bottom,
            endPoint: .top
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var rose: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "FF9A9E").opacity(0.7),
                Color(hex: "FECFEF").opacity(0.7)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var emerald: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "348F50").opacity(0.7),
                Color(hex: "56B4D3").opacity(0.7)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var amethyst: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "9D50BB").opacity(0.7),
                Color(hex: "6E48AA").opacity(0.7)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var coral: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "FF7E5F").opacity(0.7),
                Color(hex: "FEB47B").opacity(0.7)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var slate: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "516395").opacity(0.7),
                Color(hex: "614385").opacity(0.7)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var sage: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "96A7CF").opacity(0.7),
                Color(hex: "ABBF90").opacity(0.7)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var dusk: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "2C3E50").opacity(0.7),
                Color(hex: "FD746C").opacity(0.7)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var serenity: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "CFDEF3").opacity(0.7),
                Color(hex: "E0EAFC").opacity(0.7)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
}

#Preview("Basic Themes") {
    ThemePreviewContainer { _ in
        Group {
            BackgroundPreviewItem(background: AnyView(MagicBackground.frost), title: "Frost", textColor: .primary)
            BackgroundPreviewItem(background: AnyView(MagicBackground.gradient), title: "Gradient")
            BackgroundPreviewItem(background: AnyView(MagicBackground.aurora), title: "Aurora")
            BackgroundPreviewItem(background: AnyView(MagicBackground.ocean), title: "Ocean")
            BackgroundPreviewItem(background: AnyView(MagicBackground.sunset), title: "Sunset", textColor: .primary)
            BackgroundPreviewItem(background: AnyView(MagicBackground.forest), title: "Forest")
            BackgroundPreviewItem(background: AnyView(MagicBackground.lavender), title: "Lavender", textColor: .primary)
            BackgroundPreviewItem(background: AnyView(MagicBackground.desert), title: "Desert", textColor: .primary)
            BackgroundPreviewItem(background: AnyView(MagicBackground.midnight), title: "Midnight")
            BackgroundPreviewItem(background: AnyView(MagicBackground.cherry), title: "Cherry")
            BackgroundPreviewItem(background: AnyView(MagicBackground.mint), title: "Mint", textColor: .primary)
            BackgroundPreviewItem(background: AnyView(MagicBackground.twilight), title: "Twilight")
            BackgroundPreviewItem(background: AnyView(MagicBackground.rose), title: "Rose", textColor: .primary)
            BackgroundPreviewItem(background: AnyView(MagicBackground.emerald), title: "Emerald")
            BackgroundPreviewItem(background: AnyView(MagicBackground.amethyst), title: "Amethyst")
            BackgroundPreviewItem(background: AnyView(MagicBackground.coral), title: "Coral", textColor: .primary)
            BackgroundPreviewItem(background: AnyView(MagicBackground.slate), title: "Slate")
            BackgroundPreviewItem(background: AnyView(MagicBackground.sage), title: "Sage", textColor: .primary)
            BackgroundPreviewItem(background: AnyView(MagicBackground.dusk), title: "Dusk")
            BackgroundPreviewItem(background: AnyView(MagicBackground.serenity), title: "Serenity", textColor: .primary)
        }
    }
} 
