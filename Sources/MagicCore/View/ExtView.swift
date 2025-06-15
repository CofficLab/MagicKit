import SwiftUI

extension View {
    /// 让视图仅在 Debug 模式下显示
    /// - Returns: 在 Debug 模式下返回原视图，在 Release 模式下返回空视图
    public func onlyDebug() -> some View {
        #if DEBUG
        return self
        #else
        return EmptyView()
        #endif
    }

    /// 条件性地添加 hover 监听
    /// - Parameters:
    ///   - isEnabled: 是否启用 hover 监听
    ///   - onHover: hover 状态改变时的回调闭包
    /// - Returns: 修改后的视图
    public func conditionalHover(
        isEnabled: Bool,
        perform onHover: @escaping (Bool) -> Void
    ) -> some View {
        modifier(HoverModifier(isEnabled: isEnabled, onHover: onHover))
    }

public func onNotification(_ name: Notification.Name, perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: name), perform: action)
    }
    
    public func onNotification(_ name: Notification.Name, _ action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: name), perform: action)
    }
}

/// 用于条件性地添加 hover 监听的修饰器
struct HoverModifier: ViewModifier {
    let isEnabled: Bool
    let onHover: (Bool) -> Void
    
    func body(content: Content) -> some View {
        if isEnabled {
            content.onHover(perform: onHover)
        } else {
            content
        }
    }
}

// MARK: - View Extension
extension View {
    /// 添加错误提示功能
    /// - Parameter error: 错误信息的绑定，当错误不为空时显示错误视图
    /// - Returns: 修改后的视图
    public func error(_ error: Binding<Error?>) -> some View {
        self.overlay(
            Group {
                if let err = error.wrappedValue {
                    MagicErrorView(error: err)
                        .frame(minWidth: 300)
                        .onTapGesture {
                            error.wrappedValue = nil
                        }
                }
            },
            alignment: .center
        )
        .animation(.easeInOut, value: error.wrappedValue != nil)
    }
    
    /// 添加Toast提示功能
    /// - Parameter message: 提示消息的绑定，当消息不为空时显示Toast
    /// - Returns: 修改后的视图
    public func toast(_ message: Binding<String?>) -> some View {
        self.overlay(
            Group {
                if let msg = message.wrappedValue {
                    MagicToast(message: msg, icon: .iconMessage)
                        .frame(minWidth: 300)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                message.wrappedValue = nil
                            }
                        }
                }
            },
            alignment: .center
        )
        .animation(.easeInOut, value: message.wrappedValue)
    }
}

#Preview("Toast") {
    ToastPreviewView()
}

#Preview("Error") {
    ErrorPreviewView()
}

struct ErrorPreviewView: View {
    @State private var basicError: Error? = nil
    @State private var networkError: Error? = nil
    @State private var customError: Error? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Button("显示基本错误") {
                basicError = NSError(domain: "com.magickit.demo", code: 1001, userInfo: [NSLocalizedDescriptionKey: "这是一个基本错误示例"])
            }
            .error($basicError)
            
            Button("显示网络错误") {
                networkError = NSError(domain: "com.magickit.network", code: 404, userInfo: [NSLocalizedDescriptionKey: "网络连接失败"])
            }
            .error($networkError)
            
            Button("显示自定义错误") {
                struct CustomError: LocalizedError {
                    var errorDescription: String? { "这是一个自定义错误类型" }
                }
                customError = CustomError()
            }
            .error($customError)
        }
        .padding()
        .inMagicContainer()
    }
}

struct ToastPreviewView: View {
    @State private var infoMessage: String? = nil
    @State private var warningMessage: String? = nil
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Button("显示信息提示") {
                infoMessage = "这是一条信息提示"
            }
            .toast($infoMessage)
            
            Button("显示警告提示") {
                warningMessage = "这是一条警告提示"
            }
            .toast($warningMessage)
            
            Button("显示错误提示") {
                errorMessage = "这是一条错误提示"
            }
            .toast($errorMessage)
        }
        .padding()
        .inMagicContainer()
    }
}
