import SwiftUI

struct BackgroundView: View {
    var colorScheme: ColorScheme = .light
    
    var body: some View {
        BackgroundView.type1
    }
    
    static var type1: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [Color.yellow.opacity(0.4), Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Color.green.opacity(0.2).blur(radius: 2)
        }
        .ignoresSafeArea()
    }
    
    static var type2: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [Color.green.opacity(0.4), Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }.ignoresSafeArea()
    }
    
    static var type2A: some View {
        ZStack {
            type2
            Color.green.opacity(0.2).blur(radius: 2)
        }.ignoresSafeArea()
    }
    
    static var type2B: some View {
        ZStack {
            type2
            Color.white.opacity(0.2).blur(radius: 2)
        }.ignoresSafeArea()
    }
    
    static var type3: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.green.opacity(0.3),
                        Color.blue.opacity(0.3)
                    ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Color.black.opacity(0.2).blur(radius: 2)
        }
        .ignoresSafeArea()
    }
    
    static var type4: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.green.opacity(0.3),
                        Color.blue.opacity(0.3)
                    ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Color.black.opacity(0.6).blur(radius: 2)
        }
        .ignoresSafeArea()
    }
    
    static var type5: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.blue.opacity(0.3),
                        Color.blue.opacity(0.9)
                    ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }
    
    var type6: some View {
        ZStack {
            if colorScheme == .light {
                Color.white.opacity(0.9)
            }
            
            Color.green.opacity(0.2)
            Color.gray.opacity(0.6)
            
            if colorScheme == .dark {
                Color.black.opacity(0.6)
            }
        }
        .ignoresSafeArea()
    }
    
    static var preview: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.green.opacity(0.3),
                        Color.blue.opacity(0.3)
                    ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Text("Preview 专用背景").opacity(0.4).font(.title)

            Color.black.opacity(0.4).blur(radius: 2)
        }
        .ignoresSafeArea()
    }
    
    static var sky: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.blue.opacity(0.7),
                        Color.blue.opacity(0.3)
                    ]),
                startPoint: .top,
                endPoint: .bottom
            )

            Color.black.opacity(0.2).blur(radius: 2)
        }
        .ignoresSafeArea()
    }
    
    static var ocean: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.blue.opacity(0.3),
                        Color.green.opacity(0.3)
                    ]),
                startPoint: .top,
                endPoint: .bottom
            )

            Color.black.opacity(0.2).blur(radius: 2)
        }
        .ignoresSafeArea()
    }
    
    static var forest: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.green.opacity(0.3),
                        Color.green.opacity(0.1)
                    ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Color.black.opacity(0.2).blur(radius: 2)
        }
        .ignoresSafeArea()
    }
    
    static var yellow: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.yellow.opacity(0.3),
                        Color.yellow.opacity(0.6)
                    ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }
}

#Preview("Background") {
    VStack {
        ZStack {
            BackgroundView()
            Text("默认")
        }
        BackgroundView.preview
        ZStack {
            BackgroundView.type1
            Text("type1")
        }
        ZStack {
            BackgroundView.type2
            Text("type2")
        }
        ZStack {
            BackgroundView.type2A
            Text("type2A")
        }
        ZStack {
            BackgroundView.type2B
            Text("type2B")
        }
        ZStack {
            BackgroundView.type3
            Text("type3")
        }
        ZStack {
            BackgroundView.type4
            Text("type4")
        }
        ZStack {
            BackgroundView.type5
            Text("type5")
        }
        ZStack {
            BackgroundView().type6
            Text("type6")
        }
        ZStack {
            BackgroundView(colorScheme: .dark).type6
            Text("type6-暗黑")
        }
        ZStack {
            BackgroundView.sky
            Text("sky")
        }
        ZStack {
            BackgroundView.ocean
            Text("ocean")
        }
        ZStack {
            BackgroundView.forest
            Text("forest")
        }
        ZStack {
            BackgroundView.yellow
            Text("yellow")
        }
    }
    .frame(height: 700)
}
