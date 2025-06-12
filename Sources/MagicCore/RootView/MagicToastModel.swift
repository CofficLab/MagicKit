import Foundation
import SwiftUI

/// Toast模型
public struct MagicToastModel: Identifiable, Equatable {
    public let id = UUID()
    let type: MagicToastType
    let title: String
    let subtitle: String?
    let displayMode: MagicToastDisplayMode
    let duration: TimeInterval
    let autoDismiss: Bool
    let tapToDismiss: Bool
    let showProgress: Bool
    let onTap: (() -> Void)?
    let onDismiss: (() -> Void)?
    
    public init(
        type: MagicToastType,
        title: String,
        subtitle: String? = nil,
        displayMode: MagicToastDisplayMode = .overlay,
        duration: TimeInterval = 3.0,
        autoDismiss: Bool = true,
        tapToDismiss: Bool = true,
        showProgress: Bool = false,
        onTap: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.displayMode = displayMode
        self.duration = duration
        self.autoDismiss = autoDismiss
        self.tapToDismiss = tapToDismiss
        self.showProgress = showProgress
        self.onTap = onTap
        self.onDismiss = onDismiss
    }
    
    public static func == (lhs: MagicToastModel, rhs: MagicToastModel) -> Bool {
        lhs.id == rhs.id
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
