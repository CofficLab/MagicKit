import SwiftUI
import Foundation

/// Magic消息提供者 - 提供便捷的Toast方法
public class MagicMessageProvider: ObservableObject {
    private let toastManager = MagicToastManager.shared
    
    public init() {}
    
    // MARK: - Toast方法
    
    /// 显示信息提示
    public func showInfo(_ title: String, subtitle: String? = nil, duration: TimeInterval = 3.0) {
        toastManager.info(title, subtitle: subtitle, duration: duration)
    }
    
    /// 显示成功提示
    public func showSuccess(_ title: String, subtitle: String? = nil, duration: TimeInterval = 3.0) {
        toastManager.success(title, subtitle: subtitle, duration: duration)
    }
    
    /// 显示警告提示
    public func showWarning(_ title: String, subtitle: String? = nil, duration: TimeInterval = 4.0) {
        toastManager.warning(title, subtitle: subtitle, duration: duration)
    }
    
    /// 显示错误提示
    public func showError(_ title: String, subtitle: String? = nil, autoDismiss: Bool = false) {
        toastManager.error(title, subtitle: subtitle, autoDismiss: autoDismiss)
    }
    
    /// 显示加载中提示
    public func showLoading(_ title: String, subtitle: String? = nil) {
        toastManager.loading(title, subtitle: subtitle)
    }
    
    /// 隐藏加载中提示
    public func hideLoading() {
        toastManager.dismissLoading()
    }
    
    /// 显示自定义提示
    public func showCustom(
        systemImage: String,
        color: Color,
        title: String,
        subtitle: String? = nil,
        displayMode: MagicToastDisplayMode = .overlay,
        duration: TimeInterval = 3.0
    ) {
        toastManager.custom(
            systemImage: systemImage,
            color: color,
            title: title,
            subtitle: subtitle,
            displayMode: displayMode,
            duration: duration
        )
    }
    
    /// 隐藏所有Toast
    public func dismissAllToasts() {
        toastManager.dismissAll()
    }
    
    // MARK: - 操作结果Toast
    
    /// 显示操作成功
    public func operationSuccess(_ operation: String, details: String? = nil) {
        showSuccess(operation, subtitle: details)
    }
    
    /// 显示操作失败
    public func operationError(_ operation: String, error: Error) {
        showError("\(operation)失败", subtitle: error.localizedDescription, autoDismiss: false)
    }
    
    /// 显示操作开始
    public func operationStart(_ operation: String, details: String? = nil) {
        showLoading(operation, subtitle: details)
    }
    
    /// 结束操作
    public func operationEnd() {
        hideLoading()
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
