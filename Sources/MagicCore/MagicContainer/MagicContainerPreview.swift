import SwiftUI

#if DEBUG
struct MagicContainerPreview: View {    
    public var body: some View {
        TabView {
        // MARK: Basic Example
        Text("Hello, World!")
            .padding()
            .inMagicContainer()
            .tabItem {
                Image(systemName: "1.circle.fill")
                Text("基本")
            }
        
        // MARK: Simple Content Example
        VStack {
            Image(systemName: "star.fill")
                .font(.title)
            Text("Star")
        }
        .padding()
        .inMagicContainer()
        .tabItem {
            Image(systemName: "2.circle.fill")
            Text("简单")
        }
        
        // MARK: Complex Content Example
        VStack(spacing: 12) {
            Circle()
                .fill(.blue.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "hand.wave.fill")
                        .font(.title)
                        .foregroundStyle(.blue)
                }
            
            Text("Welcome")
                .font(.headline)
            
            Text("This is a demo of MagicThemePreview")
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding()
        .inMagicContainer()
        .tabItem {
            Image(systemName: "3.circle.fill")
            Text("复杂")
        }
        
        // MARK: Scrolling Content Example
        VStack(spacing: 16) {
            ForEach(1...20, id: \.self) { index in
                HStack {
                    Circle()
                        .fill(.blue.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Text("\(index)")
                                .foregroundStyle(.blue)
                        }
                    
                    VStack(alignment: .leading) {
                        Text("Item \(index)")
                            .font(.headline)
                        Text("This is a long description for item \(index) to demonstrate scrolling behavior")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .inMagicContainer()
        .tabItem {
            Image(systemName: "4.circle.fill")
            Text("滚动")
        }
    }
    }
}
#endif

// MARK: - Preview

#if DEBUG
#Preview("MagicThemePreviewPreview") {
    MagicContainerPreview()
}
#endif
