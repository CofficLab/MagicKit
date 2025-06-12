import SwiftUI
import Foundation

/// Magic Toast管理器 - 统一的Toast系统
/// 提供Toast管理和便捷的显示方法
public class MagicToastManager: ObservableObject {
    /// 共享实例，便于全局访问
    public static let shared = MagicToastManager()
    
    @Published private(set) var toasts: [MagicToastModel] = []
    private var timers: [UUID: Timer] = [:]
    
    private init() {}
    
    // MARK: - 显示Toast
    public func show(_ toast: MagicToastModel) {
        DispatchQueue.main.async {
            // 移除相同类型的已存在toast
            self.toasts.removeAll { existingToast in
                existingToast.type.systemImage == toast.type.systemImage && 
                existingToast.title == toast.title
            }
            
            self.toasts.append(toast)
            
            // 设置自动消失
            if toast.autoDismiss && toast.duration > 0 {
                let timer = Timer.scheduledTimer(withTimeInterval: toast.duration, repeats: false) { _ in
                    self.dismiss(toast.id)
                }
                self.timers[toast.id] = timer
            }
        }
    }
    
    // MARK: - 便捷显示方法
    
    /// 显示信息提示
    public func info(_ title: String, subtitle: String? = nil, duration: TimeInterval = 3.0) {
        let toast = MagicToastModel(type: .info, title: title, subtitle: subtitle, duration: duration)
        show(toast)
    }
    
    /// 显示成功提示
    public func success(_ title: String, subtitle: String? = nil, duration: TimeInterval = 3.0) {
        let toast = MagicToastModel(type: .success, title: title, subtitle: subtitle, duration: duration)
        show(toast)
    }
    
    /// 显示警告提示
    public func warning(_ title: String, subtitle: String? = nil, duration: TimeInterval = 4.0) {
        let toast = MagicToastModel(type: .warning, title: title, subtitle: subtitle, duration: duration)
        show(toast)
    }
    
    /// 显示错误提示
    public func error(_ title: String, subtitle: String? = nil, duration: TimeInterval = 0, autoDismiss: Bool = false) {
        let toast = MagicToastModel(
            type: .error,
            title: title,
            subtitle: subtitle,
            displayMode: .banner,
            duration: duration,
            autoDismiss: autoDismiss,
            tapToDismiss: true
        )
        show(toast)
    }
    
    /// 显示加载中提示
    public func loading(_ title: String, subtitle: String? = nil) {
        let toast = MagicToastModel(
            type: .loading,
            title: title,
            subtitle: subtitle,
            duration: 0,
            autoDismiss: false,
            tapToDismiss: false
        )
        show(toast)
    }
    
    /// 显示自定义提示
    public func custom(
        systemImage: String,
        color: Color,
        title: String,
        subtitle: String? = nil,
        displayMode: MagicToastDisplayMode = .overlay,
        duration: TimeInterval = 3.0
    ) {
        let toast = MagicToastModel(
            type: .custom(systemImage: systemImage, color: color),
            title: title,
            subtitle: subtitle,
            displayMode: displayMode,
            duration: duration
        )
        show(toast)
    }
    
    // MARK: - 消失Toast
    
    /// 消失指定Toast
    public func dismiss(_ id: UUID) {
        DispatchQueue.main.async {
            if let index = self.toasts.firstIndex(where: { $0.id == id }) {
                let toast = self.toasts[index]
                self.toasts.remove(at: index)
                
                // 清理定时器
                self.timers[id]?.invalidate()
                self.timers.removeValue(forKey: id)
                
                // 调用回调
                toast.onDismiss?()
            }
        }
    }
    
    /// 隐藏所有Toast
    public func dismissAll() {
        DispatchQueue.main.async {
            self.toasts.removeAll()
            self.timers.values.forEach { $0.invalidate() }
            self.timers.removeAll()
        }
    }
    
    /// 隐藏加载中提示
    public func dismissLoading() {
        let loadingToasts = toasts.filter { 
            if case .loading = $0.type { return true }
            return false
        }
        loadingToasts.forEach { dismiss($0.id) }
    }
    
    /// 隐藏加载中提示（别名方法，保持兼容性）
    public func hideLoading() {
        dismissLoading()
    }
    
    // MARK: - 操作结果Toast
    
    /// 显示操作成功
    public func operationSuccess(_ operation: String, details: String? = nil) {
        success(operation, subtitle: details)
    }
    
    /// 显示操作失败
    public func operationError(_ operation: String, error: Error) {
        self.error("\(operation)失败", subtitle: error.localizedDescription, autoDismiss: false)
    }
    
    /// 显示操作开始
    public func operationStart(_ operation: String, details: String? = nil) {
        loading(operation, subtitle: details)
    }
    
    /// 结束操作
    public func operationEnd() {
        dismissLoading()
    }
}

// MARK: - 便捷访问别名
public typealias MagicMessageProvider = MagicToastManager

#if DEBUG
#Preview {
    MagicRootView {
        MagicToastExampleView()
    }
    .frame(width: 400, height: 600)
}
#endif
