import MagicCore
import SwiftUI

// MARK: - PreviewView

public extension MagicPlayMan {
    struct PreviewView: View {
        // MARK: - Properties

        @StateObject private var playMan: MagicPlayMan
        @State private var selectedSampleName: String?
        @State private var showPlaylist = false
        @State var showLogs: Bool
        @State private var toast: (message: String, icon: String, style: MagicToast.Style)?

        // MARK: - Initialization

        public init(
            cacheDirectory: URL? = nil,
            showLogs: Bool = true
        ) {
            _playMan = StateObject(wrappedValue: MagicPlayMan(cacheDirectory: cacheDirectory))
            self.showLogs = showLogs
        }

        // MARK: - Event Observation

        private func setupEventObservation() {
            playMan.subscribe(
                name: "PreviewView",
                onTrackFinished: { [weak playMan] track in
                    playMan?.log("观察到事件：单曲播放完成 - \(track.title)")
                },
                onPlaybackFailed: { [weak playMan] error in
                    playMan?.log("观察到事件：播放失败 - \(error)", level: .error)
                },
                onBufferingStateChanged: { [weak playMan] isBuffering in
                    playMan?.log("观察到事件：缓冲状态变化 - \(isBuffering ? "开始缓冲" : "缓冲完成")")
                },
                onStateChanged: { [weak playMan] state in
                    playMan?.log("观察到事件：播放状态变化 - \(state)")
                },
                onLikeStatusChanged: { [weak playMan] asset, isLiked in
                    playMan?.log("观察到事件：喜欢状态变化 - \(asset.title) \(isLiked ? "被喜欢" : "取消喜欢")")
                },
                onPlayModeChanged: { [weak playMan] newMode in
                    playMan?.log("观察到事件：播放模式变化 - \(playMan?.playMode.rawValue ?? "未知") -> \(newMode.rawValue)")
                }
            )
        }

        // MARK: - Body

        public var body: some View {
            VStack(spacing: 0) {
                toolbarView

                mainContentArea
                    .overlay(alignment: .top) {
                        if let toast = toast {
                            toastView(toast)
                        }
                    }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showPlaylist)
            .onAppear {
                setupEventObservation()
            }
            .frame(width: 750, height: 850)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 5)
            .padding()
        }

        // MARK: - Main Layout Components

        /// 顶部工具栏
        private var toolbarView: some View {
            HStack {
                leadingToolbarItems
                Spacer()
                trailingToolbarItems
            }
            .padding()
            .background(.ultraThinMaterial)
        }

        /// 主内容区域
        private var mainContentArea: some View {
            ZStack {
                VStack(spacing: 0) {
                    contentWithSidebar
                    controlsSection
                    bottomSection
                }
            }
        }

        // MARK: - Toolbar Components

        private var leadingToolbarItems: some View {
            HStack {
                playMan.makeMediaPickerButton()
            }
        }

        private var trailingToolbarItems: some View {
            HStack {
                playMan.makePlayPauseButton()
                playMan.makePlayModeButton()
                playMan.makePlaylistButton()
                playMan.makePlaylistToggleButton()
                playMan.makeSubscribersButton()
                playMan.makeSupportedFormatsButton()
                playMan.makeLogButton()
                playMan.makeLikeButton()
            }
        }

        // MARK: - Content Area Components

        private var contentWithSidebar: some View {
            HStack(spacing: 0) {
                mainContent
                    .frame(maxWidth: .infinity)

                if showPlaylist {
                    playlistSidebar
                }
            }
        }

        private var mainContent: some View {
            ZStack {
                playMan.makeMediaView()

                if case let .loading(loadingState) = playMan.state, let asset = playMan.currentAsset {
                    LoadingOverlay(state: loadingState, assetTitle: asset.title)
                }

                if case let .failed(error) = playMan.state, let asset = playMan.currentAsset {
                    ErrorOverlay(error: error, asset: asset) {
                        Task {
                            await playMan.loadFromURL(asset)
                        }
                    }
                }
            }
        }

        private var playlistSidebar: some View {
            playMan.makePlaylistView()
                .frame(width: 300)
                .background(.ultraThinMaterial)
                .transition(.move(edge: .trailing))
        }

        // MARK: - Control Components

        private var controlsSection: some View {
            GroupBox {
                controlsView
            }
            .padding()
        }

        private var controlsView: some View {
            VStack(spacing: 16) {
                playMan.makeProgressView()

                HStack(spacing: 16) {
                    Spacer()

                    playbackControls

                    Spacer()
                }
                .padding(.horizontal)
            }
            .padding()
            .background(.ultraThinMaterial)
        }

        private var playbackControls: some View {
            HStack(spacing: 16) {
                playMan.makePlayModeButton()
                playMan.makePreviousButton()
                playMan.makeRewindButton()
                playMan.makePlayPauseButton()
                playMan.makeForwardButton()
                playMan.makeNextButton()
            }.frame(height: 40)
        }

        // MARK: - Bottom Section

        private var bottomSection: some View {
            GroupBox {
                if showLogs {
                    playMan.makeLogView()
                        .frame(height: 200)
                        .padding()
                        .background(.ultraThinMaterial)
                }
            }
            .padding()
        }

        // MARK: - Overlay Components

        private func LoadingOverlay(state: PlaybackState.LoadingState, assetTitle: String) -> some View {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)

                switch state {
                case let .downloading(progress):
                    downloadingProgress(progress, title: assetTitle)
                case .buffering:
                    loadingIndicator("Buffering...")
                case .preparing:
                    loadingIndicator("Preparing...")
                case .connecting:
                    loadingIndicator("Connecting...")
                }
            }
        }

        private func ErrorOverlay(error: PlaybackState.PlaybackError, asset: URL, onRetry: @escaping () -> Void) -> some View {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)

                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.red)

                    Text("Failed to Load Media")
                        .font(.headline)

                    Text(errorMessage(for: error))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    MagicButton(
                        icon: "arrow.clockwise",
                        title: "Try Again",
                        style: .primary,
                        shape: .capsule,
                        action: onRetry
                    )
                }
                .padding()
            }
        }

        private func toastView(_ toast: (message: String, icon: String, style: MagicToast.Style)) -> some View {
            MagicToast(
                message: toast.message,
                icon: toast.icon,
                style: toast.style
            )
            .padding(.top, 20)
        }

        // MARK: - Helper Views

        private func downloadingProgress(_ progress: Double, title: String) -> some View {
            VStack(spacing: 16) {
                ProgressView(
                    "Downloading \(title)",
                    value: progress,
                    total: 1.0
                )
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }

        private func loadingIndicator(_ message: String) -> some View {
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(.circular)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }

        // MARK: - Helper Methods

        private func errorMessage(for error: PlaybackState.PlaybackError) -> String {
            switch error {
            case .noAsset:
                return "No media selected"
            case .invalidAsset:
                return "The media file is invalid or corrupted"
            case let .networkError(message):
                return "Network error: \(message)"
            case let .playbackError(message):
                return "Playback error: \(message)"
            }
        }

        private func showToast(
            _ message: String,
            icon: String,
            style: MagicToast.Style = .info
        ) {
            withAnimation {
                toast = (message, icon, style)
            }

            // 2秒后自动隐藏
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    toast = nil
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
        .inMagicContainer()
}
