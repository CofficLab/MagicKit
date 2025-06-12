import SwiftUI

/// Magic根视图 - 整合了Toast系统的内部容器
/// 用户无需直接使用此视图，应通过 View.withMagicToast() 扩展方法来使用
struct MagicRootView<Content: View>: View {
    private let content: Content
    private let toastManager = MagicToastManager.shared
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .overlay(
                MagicToastContainerView(toastManager: toastManager)
                    .allowsHitTesting(true)
            )
            .environmentObject(toastManager)
    }
} 

#if DEBUG
#Preview {
    MagicToastExampleView()
        .withMagicToast()
        .frame(width: 400, height: 600)
}
#endif
