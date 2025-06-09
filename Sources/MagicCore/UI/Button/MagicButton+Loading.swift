import SwiftUI

extension MagicButton {
    @ViewBuilder
    var loadingView: some View {
        switch loadingStyle {
        case .spinner:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(0.8)
                .frame(width: 20, height: 20)
        case .dots:
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(self.foregroundColor)
                        .frame(width: 6, height: 6)
                        .scaleEffect(isLoading ? 1.0 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: isLoading
                        )
                }
            }
        case .pulse:
            Circle()
                .fill(foregroundColor)
                .frame(width: 20, height: 20)
                .scaleEffect(isLoading ? 1.2 : 0.8)
                .opacity(isLoading ? 0.6 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                    value: isLoading
                )
        case .none:
            EmptyView()
        }
    }
}

#Preview("MagicButton") {
    MagicButtonPreview()
        .frame(height: 800)
}
