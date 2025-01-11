import SwiftUI

public struct IconContainer<Content: View>: View {
    private let content: Content
    private let fixedSize: CGFloat?
    
    public init(
        size: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.fixedSize = size
    }
    
    public var body: some View {
        if let size = fixedSize {
            // 固定尺寸
            content
                .frame(width: size, height: size)
        } else {
            // 自适应尺寸
            content
        }
    }
}

// 为了方便预览
#Preview {
    VStack(spacing: 20) {
        // 固定尺寸
        IconContainer(size: 100) {
            Color.red
        }
        
        // 自适应尺寸
        IconContainer {
            Color.blue
        }
        .frame(width: 200, height: 200)
        
        // 在 HStack 中自适应
        HStack {
            IconContainer {
                Color.green
            }
            IconContainer {
                Color.yellow
            }
        }
        .frame(height: 50)
    }
} 