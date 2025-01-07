import MagicUI
import SwiftUI
import MagicKit

public extension MagicPlayMan {
    /// 创建播放/暂停按钮
    func makePlayPauseButton() -> some View {
        MagicButton(
            icon: state == .playing ? .iconPauseFill : .iconPlayFill,
            style: state == .playing ? .primary : .secondary,
            shape: .circle,
            disabledReason: !hasAsset ? "No media loaded" :
                state.isLoading ? "Loading..." : nil,
            action: toggle
        )
    }

    /// 创建上一曲按钮
    /// - Returns: 用于播放上一首曲目的按钮
    /// - Note: 按钮的可用性基于以下条件：
    ///   - 当没有加载任何资源时，按钮将被禁用
    ///   - 当播放列表被禁用且没有导航订阅者时，按钮将被禁用
    ///   - 当播放列表启用且当前是第一首时，按钮将被禁用
    ///   - 其他情况下，按钮可用
    /// - Important: 当播放列表被禁用但存在导航订阅者时，按钮始终可用，
    ///             导航逻辑将由订阅者控制
    func makePreviousButton() -> some View {
        let disabledReason: String? = if !hasAsset {
            "No media loaded"
        } else if !isPlaylistEnabled && !events.hasNavigationSubscribers {
            "Playlist is disabled and no handler for previous track"
        } else if isPlaylistEnabled && currentIndex <= 0 {
            "This is the first track"
        } else {
            nil
        }
        
        return MagicButton(
            icon: .iconBackwardEndFill,
            style: .secondary,
            shape: .circle,
            disabledReason: disabledReason,
            action: previous
        )
    }

    /// 创建下一曲按钮
    /// - Returns: 用于播放下一首曲目的按钮
    /// - Note: 按钮的可用性基于以下条件：
    ///   - 当没有加载任何资源时，按钮将被禁用
    ///   - 当播放列表被禁用且没有导航订阅者时，按钮将被禁用
    ///   - 当播放列表启用且当前是最后一首时，按钮将被禁用
    ///   - 其他情况下，按钮可用
    /// - Important: 当播放列表被禁用但存在导航订阅者时，按钮始终可用，
    ///             导航逻辑将由订阅者控制
    /// - SeeAlso: ``previous()``，用于了解具体的导航实现
    func makeNextButton() -> some View {
        let disabledReason: String? = if !hasAsset {
            "No media loaded"
        } else if !isPlaylistEnabled && !events.hasNavigationSubscribers {
            "Playlist is disabled and no handler for next track"
        } else if isPlaylistEnabled && currentIndex >= items.count - 1 {
            "This is the last track"
        } else {
            nil
        }
        
        return MagicButton(
            icon: .iconForwardEndFill,
            style: .secondary,
            shape: .circle,
            disabledReason: disabledReason,
            action: next
        )
    }

    /// 创建快退按钮
    func makeRewindButton() -> some View {
        MagicButton(
            icon: .iconGobackward10,
            style: .secondary,
            shape: .circle,
            disabledReason: !hasAsset ? "No media loaded" :
                state.isLoading ? "Loading..." : nil,
            action: {
                self.skipBackward()
            }
        )
    }

    /// 创建快进按钮
    func makeForwardButton() -> some View {
        MagicButton(
            icon: .iconGoforward10,
            style: .secondary,
            shape: .circle,
            disabledReason: !hasAsset ? "No media loaded" :
                state.isLoading ? "Loading..." : nil,
            action: {
                self.skipForward()
            }
        )
    }

    /// 创建播放模式按钮
    func makePlayModeButton() -> some View {
        MagicButton(
            icon: playMode.iconName,
            style: playMode != .sequence ? .primary : .secondary,
            shape: .circle,
            action: togglePlayMode
        )
    }

    /// 创建喜欢按钮
    /// - Returns: 用于切换当前资源喜欢状态的按钮
    /// - Note: 按钮的外观会根据喜欢状态改变：
    ///   - 喜欢时：使用填充图标和主要样式
    ///   - 未喜欢时：使用轮廓图标和次要样式
    func makeLikeButton() -> some View {
        MagicButton(
            icon: isCurrentAssetLiked ? "heart.fill" : "heart",
            style: isCurrentAssetLiked ? .primary : .secondary,
            shape: .roundedSquare,
            disabledReason: !hasAsset ? "No media loaded" : nil,
            action: toggleLike
        )
        .magicShape(.roundedSquare)
        .magicStyle(.secondary)
        .magicShapeVisibility(.onHover)
        .symbolEffect(.bounce, value: isCurrentAssetLiked)
    }

    /// 创建播放列表按钮
    func makePlaylistButton() -> some View {
        MagicButton(
            icon: .iconList,
            style: .secondary,
            shape: .circle,
            disabledReason: !self.isPlaylistEnabled ? "Playlist is disabled\nEnable playlist to view and manage tracks" : nil,
            popoverContent: self.isPlaylistEnabled ? AnyView(
                ZStack {
                    self.makePlaylistView()
                        .frame(width: 300, height: 400)
                        .padding()
                }
            ) : nil
        )
    }

    /// 创建播放列表启用/禁用按钮
    /// - Returns: 用于切换播放列表启用状态的按钮
    /// - Note: 按钮的外观会根据播放列表的启用状态改变：
    ///   - 启用时：使用填充图标和主要样式
    ///   - 禁用时：使用轮廓图标和次要样式
    /// - Important: 切换播放列表状态时会触发相应的事件通知，
    ///             订阅者可以通过这些事件来响应状态变化
    func makePlaylistToggleButton() -> some View {
        MagicButton(
            icon: self.isPlaylistEnabled ? .iconListCircleFill : .iconListCircle,
            style: self.isPlaylistEnabled ? .primary : .secondary,
            shape: .circle,
            action: { [self] in
                self.setPlaylistEnabled(!self.isPlaylistEnabled)
            }
        )
        .symbolEffect(.bounce, value: self.isPlaylistEnabled)
    }

    /// 创建订阅者列表按钮
    func makeSubscribersButton() -> some View {
        MagicButton(
            icon: .iconPersonGroup,
            style: .secondary,
            shape: .circle,
            popoverContent: AnyView(
                SubscribersView(subscribers: events.subscribers)
                    .frame(width: 300, height: 400)
                    .padding()
            )
        )
    }

    /// 创建支持的格式按钮
    func makeSupportedFormatsButton() -> some View {
        MagicButton(
            icon: .iconMusicNote,
            style: .secondary,
            shape: .circle,
            popoverContent: AnyView(
                self.makeSupportedFormatsView()
            )
        )
    }
    
    /// 创建日志按钮
    /// - Returns: 用于显示日志的按钮
    /// - Note: 点击按钮会显示一个包含日志内容的弹出窗口
    func makeLogButton(shape: MagicButton.Shape = .circle) -> some View {
        MagicButton(
            icon: .iconTerminal,
            popoverContent: AnyView(
                self.makeLogView()
                    .frame(width: 400, height: 400)
                    .padding()
            )
        )
        .magicShape(.roundedSquare)
        .magicStyle(.secondary)
        .magicShapeVisibility(.onHover)
    }
}

// MARK: - Preview

#Preview("MagicPlayMan") {
    MagicThemePreview {
        MagicPlayMan.PreviewView()
    }
}
