import SwiftUI

import Core

public enum MagicPlayMode: String, CaseIterable {
    case sequence
    case loop
    case shuffle
    case repeatAll
    
    // MARK: - Display Properties
    
    /// 播放模式的显示名称
    public var displayName: String {
        switch self {
        case .sequence: return "Sequential Play"
        case .loop: return "Single Track Loop"
        case .shuffle: return "Shuffle Play"
        case .repeatAll: return "Repeat All"
        }
    }
    
    /// 播放模式的简短名称（用于指示器）
    public var shortName: String {
        switch self {
        case .sequence: return "Sequential"
        case .loop: return "Loop One"
        case .shuffle: return "Shuffle"
        case .repeatAll: return "Repeat All"
        }
    }
    
    /// 播放模式的图标名称
    public var iconName: String {
        switch self {
        case .sequence: return .iconMusicNoteList
        case .loop: return .iconRepeat1
        case .shuffle: return .iconShuffle
        case .repeatAll: return .iconRepeatAll
        }
    }
    
    public var icon: String { iconName }
    
    /// 切换到下一个模式
    public var next: MagicPlayMode {
        switch self {
        case .sequence: return .loop
        case .loop: return .shuffle
        case .shuffle: return .repeatAll
        case .repeatAll: return .sequence
        }
    }
    
    // MARK: - UI Components
    
    /// 播放模式按钮
    public func button(action: @escaping () -> Void) -> some View {
        MagicPlayModeButton(mode: self, action: action)
    }
    
    /// 播放模式指示器
    public var indicator: some View {
        PlayModeIndicator(mode: self)
    }
    
    /// 播放模式标签
    public var label: some View {
        Label(shortName, systemImage: iconName)
    }
    
    /// 播放模式 Toast 消息
    public var toastMessage: (message: String, icon: String) {
        (displayName, iconName)
    }
}

// MARK: - Helper Views

/// 播放模式指示器组件
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
