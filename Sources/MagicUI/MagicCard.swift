import SwiftUI

public struct MagicCard<Content, Background>: View where Content: View, Background: View {
    private let content: Content
    private var background: Background
    private var paddingVertical: CGFloat = 8

    public init(background: Background, paddingVertical: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.background = background
        self.content = content()
        self.paddingVertical = paddingVertical ?? self.paddingVertical
    }

    public var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, paddingVertical)
            .background(background)
            .clipShape(
                RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    ZStack {
        VStack {
            MagicCard(background: Color.accentColor) {
                Text("你好")
                    .foregroundColor(.white)
            }
            MagicCard(background: Color.accentColor) {
                Text("你好")
                    .foregroundColor(.white)
            }
            MagicCard(background: Color.accentColor) {
                Text("你好")
                    .foregroundColor(.white)
            }
            MagicCard(background: Color.accentColor) {
                Text("你好")
                    .foregroundColor(.white)
            }
        }.frame(width: 300, height: 300)
    }
}
