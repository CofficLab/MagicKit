import SwiftUI
import MagicUI

public extension MagicPlayMan {
    /// 创建一个预览视图，用于快速展示播放器的功能
    struct PreviewView: View {
        @StateObject private var playMan: MagicPlayMan
        @State private var selectedSampleName: String?
        @State private var showMediaPicker = false
        @State private var showPlaylist = false
        @State private var showFormats = false
        let showLogs: Bool
        
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
        }
        
        // MARK: - Subviews
        
        private var toolbarView: some View {
            HStack {
                mediaPickerButton
                
                if let asset = playMan.currentAsset {
                    Text(asset.metadata.title)
                        .font(.headline)
                }
                
                Spacer()
                
                toolbarButtons
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        
        private var mediaPickerButton: some View {
            Menu {
                ForEach(playMan.supportedFormats.filter { !$0.samples.isEmpty }, id: \.name) { format in
                    Section(format.name) {
                        ForEach(format.samples, id: \.name) { sample in
                            Button {
                                selectedSampleName = sample.name
                                playMan.load(asset: sample.asset)
                            } label: {
                                Label(
                                    sample.name,
                                    systemImage: format.type == .audio ? "music.note" : "film"
                                )
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: currentAssetIcon)
                    Text(selectedSampleName ?? "Select Media")
                    Image(systemName: "chevron.down")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
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
                            playMan.audioView
                        }
                        
                        if case .loading(let loadingState) = playMan.state {
                            loadingOverlay(loadingState)
                        }
                        
                        if case .failed(let error) = playMan.state {
                            errorOverlay(error, asset: asset)
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
                },
                onRemove: { index in
                    playMan.removeFromPlaylist(at: index)
                },
                onMove: { from, to in
                    playMan.moveInPlaylist(from: from, to: to)
                }
            )
            .frame(width: 300)
            .background(.ultraThinMaterial)
            .transition(.move(edge: .trailing))
        }
        
        private var controlsView: some View {
            VStack(spacing: 16) {
                progressBar
                playbackControls
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
        
        private var playbackControls: some View {
            HStack(spacing: 20) {
                MagicPlayModeButton(mode: playMan.playMode) {
                    playMan.togglePlayMode()
                }
                
                MagicPlayerButton(
                    icon: "backward.end.fill",
                    action: { playMan.previous() }
                )
                
                MagicPlayerButton(
                    icon: "backward.fill",
                    action: { playMan.skipBackward() }
                )
                
                MagicPlayerButton(
                    icon: playMan.state == .playing ? "pause.fill" : "play.fill",
                    size: 50,
                    iconSize: 20,
                    isActive: playMan.state == .playing,
                    action: playMan.toggle
                )
                
                MagicPlayerButton(
                    icon: "forward.fill",
                    action: { playMan.skipForward() }
                )
                
                MagicPlayerButton(
                    icon: "forward.end.fill",
                    action: { playMan.next() }
                )
            }
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
        
        private func loadingOverlay(_ state: PlaybackState.LoadingState) -> some View {
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
        
        private func errorOverlay(_ error: PlaybackState.PlaybackError, asset: MagicAsset) -> some View {
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
                        action: {
                            playMan.load(asset: asset)
                        }
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
    }
} 