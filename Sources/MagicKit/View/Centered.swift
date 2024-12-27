import SwiftUI
import MagicKit

public struct Centered<Content>: View where Content: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    content
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ZStack {
        BackgroundView.type2

        VStack {
            Spacer()
            Centered {
                Text("你好").foregroundColor(.white)
            }
            Spacer()
        }.frame(width: 300, height: 300)
    }
}
