import SwiftUI

public extension View {
    /// 为预览视图添加通用容器
    func inMagicContainer() -> some View {
        MagicContainer {
            self
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("MagicThemePreviewPreview") {
    MagicContainerPreview()
}
#endif
