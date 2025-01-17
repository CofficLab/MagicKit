import SwiftUI

extension View {
    /// 为视图添加虚线边框
    /// - Parameters:
    ///   - color: 虚线颜色，默认为灰色
    ///   - lineWidth: 线宽，默认为1
    ///   - dash: 虚线样式，默认为[5,5]表示线段长5点，间隔5点
    public func dashedBorder(
        color: Color = .gray,
        lineWidth: CGFloat = 1,
        dash: [CGFloat] = [5, 5]
    ) -> some View {
        self.overlay(
            Rectangle()
                .strokeBorder(style: StrokeStyle(
                    lineWidth: lineWidth,
                    dash: dash
                ))
                .foregroundColor(color)
        )
    }

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
    func onNotification(_ name: Notification.Name, perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: name), perform: action)
    }
    
    func onNotification(_ name: Notification.Name, _ action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: name), perform: action)
    }
}

#Preview {
    VStack(spacing: 20) {
        // 默认样式
        Text("Default Style")
            .padding()
            .dashedBorder()
        
        // 自定义颜色
        Text("Custom Color")
            .padding()
            .dashedBorder(color: .blue)
        
        // 自定义线宽
        Text("Thick Border")
            .padding()
            .dashedBorder(color: .red, lineWidth: 3)
        
        // 自定义虚线样式
        Text("Custom Dash Pattern")
            .padding()
            .dashedBorder(color: .green, dash: [10, 5])
        
        // 应用于图片
        Image(systemName: "star.fill")
            .font(.largeTitle)
            .padding()
            .dashedBorder(color: .orange, lineWidth: 2, dash: [8, 4])
        
        // 添加 onlyDebug 预览示例
        Text("Debug Only View")
            .padding()
            .background(Color.yellow)
            .onlyDebug()
    }
    .padding()
    .inMagicContainer()
}
