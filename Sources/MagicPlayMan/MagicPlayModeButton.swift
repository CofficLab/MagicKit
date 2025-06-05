import SwiftUI

/// 播放模式按钮视图组件
///
/// 一个圆形按钮组件，用于显示当前播放模式并允许用户切换到不同的播放模式。
/// 按钮在悬停时会有视觉反馈，并显示相应的提示文本。
///
/// ## 使用示例:
/// ```swift
/// struct PlayerControls: View {
///     @State private var playMode: MagicPlayMode = .sequence
///     
///     var body: some View {
///         MagicPlayModeButton(mode: playMode) {
///             playMode = playMode.next
///         }
///     }
/// }
/// ```
struct MagicPlayModeButton: View {
    /// 当前显示的播放模式
    let mode: MagicPlayMode
    /// 按钮点击时执行的操作
    let action: () -> Void
    
    /// 跟踪按钮是否处于悬停状态
    @State private var isHovering = false
    /// 当前的颜色方案（深色/浅色模式）
    @Environment(\.colorScheme) private var colorScheme
    
    /// 创建一个播放模式按钮
    ///
    /// - Parameters:
    ///   - mode: 要显示的播放模式
    ///   - action: 按钮点击时执行的闭包
    init(mode: MagicPlayMode, action: @escaping () -> Void) {
        self.mode = mode
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: 16))
                .foregroundStyle(isHovering ? .primary : .secondary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.primary.opacity(isHovering ? 0.1 : 0.05))
                )
                .overlay(
                    Circle()
                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .help(modeDescription)
    }
    
    /// 根据当前播放模式获取对应的系统图标名称
    ///
    /// - Returns: 表示当前播放模式的系统图标名称
    private var iconName: String {
        switch mode {
        case .sequence:
            return "arrow.right"
        case .loop:
            return "repeat.1"
        case .shuffle:
            return "shuffle"
        case .repeatAll:
            return "repeat"
        }
    }
    
    /// 获取当前播放模式的描述文本，用于按钮的提示信息
    ///
    /// - Returns: 描述当前播放模式的文本
    private var modeDescription: String {
        switch mode {
        case .sequence:
            return "Sequential Play"
        case .loop:
            return "Single Track Loop"
        case .shuffle:
            return "Shuffle Play"
        case .repeatAll:
            return "Repeat All"
        }
    }
}

#Preview("MagicPlayModeButton") {
    struct PreviewWrapper: View {
        @State private var mode: MagicPlayMode = .sequence
        
        var body: some View {
            HStack(spacing: 20) {
                VStack(spacing: 20) {
                    Text("Light Mode")
                        .font(.headline)
                    
                    ForEach([
                        MagicPlayMode.sequence,
                        .loop,
                        .shuffle,
                        .repeatAll
                    ], id: \.self) { mode in
                        MagicPlayModeButton(mode: mode) {
                            print("Toggle mode: \(mode)")
                        }
                    }
                }
                .padding()
                .background(.background)
                .environment(\.colorScheme, .light)
                
                VStack(spacing: 20) {
                    Text("Dark Mode")
                        .font(.headline)
                    
                    ForEach([
                        MagicPlayMode.sequence,
                        .loop,
                        .shuffle,
                        .repeatAll
                    ], id: \.self) { mode in
                        MagicPlayModeButton(mode: mode) {
                            print("Toggle mode: \(mode)")
                        }
                    }
                }
                .padding()
                .background(.background)
                .environment(\.colorScheme, .dark)
            }
        }
    }
    
    return PreviewWrapper()
}
