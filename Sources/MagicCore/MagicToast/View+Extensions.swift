import SwiftUI

/// View扩展 - 提供Magic Toast系统的便捷接入方法
public extension View {
    /// 为 View 添加 Toast 功能
    /// 
    /// 使用这个方法可以为任何 SwiftUI View 添加 Toast 显示能力
    /// 只需要在 View 后面调用 `.withMagicToast()` 即可
    ///
    /// ```swift
    /// ContentView()
    ///     .withMagicToast()
    /// ```
    func withMagicToast() -> some View {
        MagicRootView {
            self
        }
    }
    
    /// 为 View 添加 Toast 功能，并在 View 出现时执行设置
    /// 
    /// - Parameter onSetup: 当 View 出现时调用的闭包，可以用来配置 MessageProvider
    ///
    /// ```swift
    /// ContentView()
    ///     .withMagicToast { provider in
    ///         // 配置 provider
    ///     }
    /// ```
    func withMagicToast(onSetup: @escaping (MagicMessageProvider) -> Void = { _ in }) -> some View {
        MagicRootView {
            self
                .onAppear {
                    onSetup(MagicMessageProvider.shared)
                }
        }
    }
}

#if DEBUG
#Preview {
    MagicToastExampleView()
        .withMagicToast()
        .frame(width: 400, height: 600)
}
#endif
