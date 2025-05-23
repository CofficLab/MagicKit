import SwiftUI

import Core

/// 音频播放模式枚举
///
/// 定义了应用中可用的不同播放模式，包括顺序播放、单曲循环、随机播放和全部循环。
/// 每种模式都有其独特的行为和视觉表示。
///
/// ## 使用示例:
/// ```swift
/// // 创建播放器并设置初始播放模式
/// var player = AudioPlayer()
/// player.playMode = .sequence
///
/// // 切换到下一个播放模式
/// player.playMode = player.playMode.next
/// ```
public enum MagicPlayMode: String, CaseIterable {
    /// 顺序播放模式 - 按顺序播放所有曲目，播放完毕后停止
    case sequence
    /// 单曲循环模式 - 重复播放当前曲目
    case loop
    /// 随机播放模式 - 随机顺序播放所有曲目
    case shuffle
    /// 全部循环模式 - 按顺序播放所有曲目，播放完毕后从头开始
    
    // MARK: - Display Properties
    
    /// 播放模式的完整显示名称
    ///
    /// 返回播放模式的完整名称，适用于UI显示、菜单项和提示信息。
    ///
    /// ## 返回值示例:
    /// - .sequence: "Sequential Play"
    /// - .loop: "Single Track Loop"
    /// - .shuffle: "Shuffle Play"
    /// - .repeatAll: "Repeat All"
    public var displayName: String {
        switch self {
        case .sequence: return "Sequential Play"
        case .loop: return "Single Track Loop"
        case .shuffle: return "Shuffle Play"
        case .repeatAll: return "Repeat All"
        }
    }
    
    /// 播放模式的简短名称
    ///
    /// 返回播放模式的简短名称，适用于空间有限的UI元素，如指示器和状态栏。
    ///
    /// ## 返回值示例:
    /// - .sequence: "Sequential"
    /// - .loop: "Loop One"
    /// - .shuffle: "Shuffle"
    /// - .repeatAll: "Repeat All"
    public var shortName: String {
        switch self {
        case .sequence: return "Sequential"
        case .loop: return "Loop One"
        case .shuffle: return "Shuffle"
        case .repeatAll: return "Repeat All"
        }
    }
    
    /// 播放模式的图标名称
    ///
    /// 返回与播放模式相关联的系统图标名称，用于在UI中视觉表示该模式。
    ///
    /// ## 返回值示例:
    /// - .sequence: ".iconMusicNoteList"
    /// - .loop: ".iconRepeat1"
    /// - .shuffle: ".iconShuffle"
    /// - .repeatAll: ".iconRepeatAll"
    public var iconName: String {
        switch self {
        case .sequence: return .iconMusicNoteList
        case .loop: return .iconRepeat1
        case .shuffle: return .iconShuffle
        case .repeatAll: return .iconRepeatAll
        }
    }
    
    /// 播放模式的图标快捷访问属性
    ///
    /// 提供对iconName的便捷访问，功能与iconName相同。
    public var icon: String { iconName }
    
    /// 获取下一个播放模式
    ///
    /// 按照预定义的顺序返回下一个播放模式，用于循环切换播放模式。
    /// 顺序为: sequence -> loop -> shuffle -> repeatAll -> sequence
    ///
    /// ## 使用示例:
    /// ```swift
    /// // 当前模式为.sequence
    /// let currentMode = MagicPlayMode.sequence
    /// let nextMode = currentMode.next // 结果为.loop
    /// ```
    public var next: MagicPlayMode {
        switch self {
        case .sequence: return .loop
        case .loop: return .shuffle
        case .shuffle: return .repeatAll
        case .repeatAll: return .sequence
        }
    }
    
    // MARK: - UI Components
    
    /// 创建播放模式按钮视图
    ///
    /// 返回一个表示当前播放模式的按钮视图，点击时执行提供的操作。
    ///
    /// - Parameter action: 按钮点击时执行的闭包
    /// - Returns: 一个可以直接在SwiftUI视图层次结构中使用的按钮视图
    ///
    /// ## 使用示例:
    /// ```swift
    /// struct PlayerControls: View {
    ///     @State private var playMode: MagicPlayMode = .sequence
    ///     
    ///     var body: some View {
    ///         playMode.button {
    ///             playMode = playMode.next
    ///         }
    ///     }
    /// }
    /// ```
    public func button(action: @escaping () -> Void) -> some View {
        MagicPlayModeButton(mode: self, action: action)
    }
    
    /// 创建播放模式指示器视图
    ///
    /// 返回一个表示当前播放模式的指示器视图，显示模式名称和图标。
    ///
    /// - Returns: 一个可以直接在SwiftUI视图层次结构中使用的指示器视图
    ///
    /// ## 使用示例:
    /// ```swift
    /// struct PlayerStatusBar: View {
    ///     let playMode: MagicPlayMode
    ///     
    ///     var body: some View {
    ///         HStack {
    ///             Text("Now Playing")
    ///             Spacer()
    ///             playMode.indicator
    ///         }
    ///     }
    /// }
    /// ```
    public var indicator: some View {
        PlayModeIndicator(mode: self)
    }
    
    /// 创建播放模式标签视图
    ///
    /// 返回一个标准的SwiftUI Label视图，显示模式的简短名称和图标。
    ///
    /// - Returns: 一个包含图标和文本的Label视图
    ///
    /// ## 使用示例:
    /// ```swift
    /// struct PlayModeSelector: View {
    ///     @Binding var selectedMode: MagicPlayMode
    ///     
    ///     var body: some View {
    ///         Menu {
    ///             ForEach(MagicPlayMode.allCases, id: \.self) { mode in
    ///                 Button {
    ///                     selectedMode = mode
    ///                 } label: {
    ///                     mode.label
    ///                 }
    ///             }
    ///         } label: {
    ///             selectedMode.label
    ///         }
    ///     }
    /// }
    /// ```
    public var label: some View {
        Label(shortName, systemImage: iconName)
    }
    
    /// 获取播放模式的Toast消息
    ///
    /// 返回一个包含显示名称和图标的元组，适用于在切换模式时显示临时通知。
    ///
    /// - Returns: 包含消息文本和图标名称的元组
    ///
    /// ## 使用示例:
    /// ```swift
    /// func showPlayModeToast() {
    ///     let (message, icon) = currentPlayMode.toastMessage
    ///     showToast(message: message, icon: icon)
    /// }
    /// ```
    public var toastMessage: (message: String, icon: String) {
        (displayName, iconName)
    }
}

// MARK: - Helper Views

/// 播放模式指示器组件
///
/// 一个轻量级的视图组件，用于显示当前播放模式的状态。
/// 它以胶囊形状的背景显示播放模式的简短名称和图标。
///
/// ## 使用示例:
/// ```swift
/// struct PlayerView: View {
///     let currentMode: MagicPlayMode = .shuffle
///     
///     var body: some View {
///         VStack {
///             // 其他播放器控件
///             PlayModeIndicator(mode: currentMode)
///         }
///     }
/// }
/// ```
public struct PlayModeIndicator: View {
    let mode: MagicPlayMode
    
    public var body: some View {
        mode.label
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.primary.opacity(0.05))
            .clipShape(Capsule())
    }
}

/// 播放模式按钮组件
///
/// 一个圆形按钮组件，用于显示和切换播放模式。
/// 它使用半透明材质背景和系统图标来表示不同的播放模式。
///
/// ## 使用示例:
/// ```swift
/// struct PlayerControls: View {
///     @State private var playMode: MagicPlayMode = .sequence
///     
///     var body: some View {
///         HStack {
///             // 其他控件
///             PlayModeButton(mode: playMode) {
///                 playMode = playMode.next
///             }
///         }
///     }
/// }
/// ```
public struct PlayModeButton: View {
    let mode: MagicPlayMode
    let action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: mode.iconName)
                .font(.system(size: 20))
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
    }
}

// MARK: - Preview

#Preview("PlayMode Components") {
    VStack(spacing: 30) {
        // 指示器预览
        HStack(spacing: 20) {
            ForEach(MagicPlayMode.allCases, id: \.self) { mode in
                mode.indicator
            }
        }
        
        // 按钮预览
        HStack(spacing: 20) {
            ForEach(MagicPlayMode.allCases, id: \.self) { mode in
                mode.button {}
            }
        }
        
        // 标签预览
        VStack(alignment: .leading, spacing: 10) {
            ForEach(MagicPlayMode.allCases, id: \.self) { mode in
                mode.label
            }
        }
    }
    .padding()
    .background(.ultraThinMaterial)
}
