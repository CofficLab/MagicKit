import SwiftUI

extension MagicButton {
    func handleTap() {
        // 处理弹出内容
        if popoverContent != nil {
            showingPopover.toggle()
        }

        // 执行动作
        if let asyncAction = asyncAction {
            Task {
                if preventDoubleClick {
                    await MainActor.run {
                        isLoading = true
                    }
                }
                await asyncAction()
                if preventDoubleClick {
                    await MainActor.run {
                        isLoading = false
                    }
                }
            }
        } else {
            if preventDoubleClick {
                isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isLoading = false
                }
            }
            action?()
        }
    }
}

#Preview("MagicButton") {
    MagicButtonPreview()
        .frame(height: 800)
}
