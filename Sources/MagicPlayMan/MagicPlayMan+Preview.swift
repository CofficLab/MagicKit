import MagicKit
import MagicUI
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
            // 观察播放完成事件
            playMan.events.onTrackFinished
                .sink { [weak playMan] track in
                    playMan?.log("事件：单曲播放完成 - \(track.title)")
                }
                .store(in: &playMan.cancellables)
            
            // 观察缓冲状态变化
            playMan.events.onBufferingStateChanged
                .sink { [weak playMan] isBuffering in
                    playMan?.log("事件：缓冲状态变化 - \(isBuffering ? "开始缓冲" : "缓冲完成")")
                }
                .store(in: &playMan.cancellables)
            
            // 观察播放状态变化
            playMan.events.onStateChanged
                .sink { [weak playMan] state in
                    playMan?.log("事件：播放状态变化 - \(state)")
                }
                .store(in: &playMan.cancellables)
            
            // 观察播放错误
            playMan.events.onPlaybackFailed
                .sink { [weak playMan] error in
                    playMan?.log("事件：播放失败 - \(error)", level: .error)
                }
                .store(in: &playMan.cancellables)
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
            }
        }
        
        private var trailingToolbarItems: some View {
            HStack {
                playMan.makePlaylistButton()
                playMan.makePlaylistToggleButton()
                playMan.makeSupportedFormatsButton()
                
                MagicButton(
                    icon: "apple.terminal",
                    style: .secondary,
                    size: .regular,
                    shape: .circle,
                    action: { showLogs.toggle() }
                )
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
            Group {
                if let asset = playMan.currentAsset {
                    assetContentView(for: asset)
                } else {
                    playMan.makeEmptyView()
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
                    playMan.makePlayModeButton()
                    
                    Spacer()
                    
                    playbackControls
                    
                    Spacer()
                    
                    // 占位，保持对称
                    placeholderButton
                }
                .padding(.horizontal)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        
        private var playbackControls: some View {
            HStack(spacing: 16) {
                playMan.makePreviousButton()
                playMan.makeRewindButton()
                playMan.makePlayPauseButton()
                playMan.makeForwardButton()
                playMan.makeNextButton()
            }
        }
        
        private var placeholderButton: some View {
            MagicButton(icon: "placeholder", action: {})
                .opacity(0)
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
        
        // MARK: - Asset Content Views
        
        private func assetContentView(for asset: MagicAsset) -> some View {
            ZStack {
                playMan.makeAssetView()
                
                if case let .loading(loadingState) = playMan.state {
                    LoadingOverlay(state: loadingState, assetTitle: asset.title)
                }
                
                if case let .failed(error) = playMan.state {
                    ErrorOverlay(error: error, asset: asset) {
                        playMan.load(asset: asset)
                    }
                }
            }
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
        .frame(width: 650, height: 800)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
}
