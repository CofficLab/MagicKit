import SwiftUI
import MagicUI
import MagicKit

public extension MagicPlayMan {
    /// 创建一个预览视图，用于快速展示播放器的功能
    struct PreviewView: View {
        @StateObject private var playMan: MagicPlayMan
        @State private var selectedSampleName: String?
        @State private var showPlaylist = false
        @State private var showFormats = false
        let showLogs: Bool
        
        @State private var toast: (message: String, icon: String, style: MagicToast.Style)?
        
        public init(
            cacheDirectory: URL? = nil,
            showLogs: Bool = true
        ) {
            _playMan = StateObject(wrappedValue: MagicPlayMan(cacheDirectory: cacheDirectory))
            self.showLogs = showLogs
        }
        
        public var body: some View {
            VStack(spacing: 0) {
                toolbarView
                
                if showFormats {
                    FormatInfoView(
                        formats: playMan.supportedFormats,
                        onDismiss: { showFormats = false }
                    )
                }
                
                HStack(spacing: 0) {
                    mainContentView
                        .frame(maxWidth: .infinity)
                    
                    if showPlaylist {
                        playlistSidebarView
                    }
                }
                
                controlsView
                
                if showLogs {
                    logsView
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showPlaylist)
            .overlay(alignment: .top) {
                if let toast = toast {
                    MagicToast(
                        message: toast.message,
                        icon: toast.icon,
                        style: toast.style
                    )
                    .padding(.top, 20)
                }
            }
        }
        
        // MARK: - Subviews
        
        private var toolbarView: some View {
            HStack {
                MediaPickerButton(
                    formats: playMan.supportedFormats,
                    selectedName: selectedSampleName,
                    onSelect: { asset in
                        selectedSampleName = asset.metadata.title
                        playMan.load(asset: asset)
                    }
                )
                
                if let asset = playMan.currentAsset {
                    Text(asset.title)
                        .font(.headline)
                }
                
                Spacer()
                
                playMan.playMode.indicator
                    .foregroundStyle(.secondary)
                
                toolbarButtons
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        
        private var toolbarButtons: some View {
            HStack {
                MagicButton(
                    icon: "list.bullet",
                    style: .secondary,
                    size: .small,
                    shape: .circle,
                    action: { showPlaylist.toggle() }
                )
                
                MagicButton(
                    icon: "info.circle",
                    style: .secondary,
                    size: .small,
                    shape: .circle,
                    action: { showFormats = true }
                )
            }
        }
        
        private var mainContentView: some View {
            Group {
                if let asset = playMan.currentAsset {
                    ZStack {
                        if asset.type == .video {
                            playMan.videoView
                        } else {
                            AudioContentView(
                                asset: asset,
                                artwork: playMan.currentThumbnail
                            )
                        }
                        
                        if case .loading(let loadingState) = playMan.state {
                            LoadingOverlay(
                                state: loadingState,
                                assetTitle: asset.title
                            )
                        }
                        
                        if case .failed(let error) = playMan.state {
                            ErrorOverlay(
                                error: error,
                                asset: asset,
                                onRetry: { playMan.load(asset: asset) }
                            )
                        }
                    }
                } else {
                    playMan.emptyView
                }
            }
        }
        
        private var playlistSidebarView: some View {
            PlaylistView(
                playlist: playMan.playlist,
                currentIndex: playMan.currentIndex,
                onSelect: { asset in
                    playMan.play(asset: asset)
                    showToast(
                        "Playing: \(asset.title)",
                        icon: "play.circle",
                        style: .info
                    )
                },
                onRemove: { index in
                    let asset = playMan.playlist[index]
                    playMan.removeFromPlaylist(at: index)
                    showToast(
                        "Removed: \(asset.metadata.title)",
                        icon: "minus.circle",
                        style: .warning
                    )
                },
                onMove: { from, to in
                    playMan.moveInPlaylist(from: from, to: to)
                    showToast(
                        "Playlist reordered",
                        icon: "arrow.up.arrow.down",
                        style: .info
                    )
                }
            )
            .frame(width: 300)
            .background(.ultraThinMaterial)
            .transition(.move(edge: .trailing))
        }
        
        private var controlsView: some View {
            VStack(spacing: 16) {
                progressBar
                PlaybackControls(
                    isPlaying: playMan.state == .playing,
                    hasAsset: playMan.hasAsset,
                    isLoading: playMan.state.isLoading,
                    canSeek: playMan.hasAsset && !playMan.state.isLoading,
                    playMode: playMan.playMode,
                    onPlayPause: playMan.toggle,
                    onSkipForward: { playMan.skipForward() },
                    onSkipBackward: { playMan.skipBackward() },
                    onNext: playMan.next,
                    onPrevious: playMan.previous,
                    onTogglePlayMode: {
                        playMan.togglePlayMode()
                        showToast(
                            playMan.playMode.displayName,
                            icon: playMan.playMode.iconName,
                            style: .info
                        )
                    }
                )
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        
        private var progressBar: some View {
            MagicProgressBar(
                progress: .init(
                    get: { playMan.progress },
                    set: { playMan.seek(to: $0) }
                ),
                duration: playMan.duration,
                onSeek: { playMan.seek(to: $0) }
            )
        }
        
        private var logsView: some View {
            LogView(
                logs: playMan.logs,
                onClear: { playMan.clearLogs() }
            )
            .frame(height: 120)
            .padding()
            .background(.ultraThinMaterial)
        }
        
        // MARK: - Helper Views
        
        private func LoadingOverlay(state: PlaybackState.LoadingState, assetTitle: String) -> some View {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                
                switch state {
                case .downloading(let progress):
                    downloadingProgress(progress)
                case .buffering:
                    loadingIndicator("Buffering...")
                case .preparing:
                    loadingIndicator("Preparing...")
                case .connecting:
                    loadingIndicator("Connecting...")
                }
            }
        }
        
        private func downloadingProgress(_ progress: Double) -> some View {
            VStack(spacing: 16) {
                ProgressView(
                    "Downloading \(playMan.currentAsset?.metadata.title ?? "")",
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
        
        private func ErrorOverlay(error: PlaybackState.PlaybackError, asset: MagicAsset, onRetry: @escaping () -> Void) -> some View {
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
        
        // MARK: - Helper Methods
        
        private var currentAssetIcon: String {
            if let asset = playMan.currentAsset {
                return asset.type == .audio ? "music.note" : "film"
            }
            return "play.circle"
        }
        
        private func errorMessage(for error: PlaybackState.PlaybackError) -> String {
            switch error {
            case .noAsset:
                return "No media selected"
            case .invalidAsset:
                return "The media file is invalid or corrupted"
            case .networkError(let message):
                return "Network error: \(message)"
            case .playbackError(let message):
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
        
        // 辅助计算属性
        private var canSeek: Bool {
            guard let _ = playMan.currentAsset else { return false }
            
            switch playMan.state {
            case .idle, .loading, .failed:
                return false
            case .playing, .paused, .stopped:
                return true
            }
        }
        
        private var isLoading: Bool {
            if case .loading = playMan.state {
                return true
            }
            return false
        }
    }
}

#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
        .frame(width: 650, height: 500)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
}
