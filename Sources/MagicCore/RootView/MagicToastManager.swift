import SwiftUI
import Foundation

/// Toast管理器
public class MagicToastManager: ObservableObject {
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
    
    // MARK: - 便捷方法
    public func info(_ title: String, subtitle: String? = nil, duration: TimeInterval = 3.0) {
        let toast = MagicToastModel(type: .info, title: title, subtitle: subtitle, duration: duration)
        show(toast)
    }
    
    public func success(_ title: String, subtitle: String? = nil, duration: TimeInterval = 3.0) {
        let toast = MagicToastModel(type: .success, title: title, subtitle: subtitle, duration: duration)
        show(toast)
    }
    
    public func warning(_ title: String, subtitle: String? = nil, duration: TimeInterval = 4.0) {
        let toast = MagicToastModel(type: .warning, title: title, subtitle: subtitle, duration: duration)
        show(toast)
    }
    
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
    
    public func dismissAll() {
        DispatchQueue.main.async {
            self.toasts.removeAll()
            self.timers.values.forEach { $0.invalidate() }
            self.timers.removeAll()
        }
    }
    
    public func dismissLoading() {
        let loadingToasts = toasts.filter { 
            if case .loading = $0.type { return true }
            return false
        }
        loadingToasts.forEach { dismiss($0.id) }
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
