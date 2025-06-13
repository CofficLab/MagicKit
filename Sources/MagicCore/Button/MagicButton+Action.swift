import SwiftUI

extension MagicButton {
    func handleTap() {
        // 处理弹出内容
        if popoverContent != nil {
            showingPopover.toggle()
        }

        // 执行动作
        guard let action = action else { return }
        
        if preventDoubleClick {
            // 立即显示loading状态
            isLoading = true
            
            // 创建完成回调
            let completion = {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            
            // 在后台执行用户操作
            DispatchQueue.global().async {
                action(completion)
            }
        } else {
            // 不需要防重复点击时，立即执行
            let completion = {}
            action(completion)
        }
    }
}

#Preview {
    LoadingAndPreventDoubleClickPreview()
        .inMagicContainer()
}
