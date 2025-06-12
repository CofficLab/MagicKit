import SwiftUI

public extension View {
    /// 应用Magic Toast系统
    func withMagicToast() -> some View {
        MagicRootView {
            self
        }
    }
} 

#if DEBUG
#Preview {
    MagicRootView {
        MagicToastExampleView()
    }
    .frame(width: 400, height: 600)
}
#endif
