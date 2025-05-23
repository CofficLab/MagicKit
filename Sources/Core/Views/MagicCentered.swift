import SwiftUI

public struct MagicCentered<Content>: View where Content: View {
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
    MagicCentered {
        Text("Hello, World!")
    }
    .border(.red)
}
