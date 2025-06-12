import SwiftUI

/// Magic根视图 - 整合了Toast系统的根视图容器
public struct MagicRootView<Content: View>: View {
    private let content: Content
    private let toastManager = MagicToastManager.shared
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .overlay(
                MagicToastContainerView(toastManager: toastManager)
                    .allowsHitTesting(toastManager.toasts.contains { !$0.tapToDismiss })
            )
            .environmentObject(toastManager)
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
