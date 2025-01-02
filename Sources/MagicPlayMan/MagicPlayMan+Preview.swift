import MagicKit
import MagicUI
import SwiftUI

public extension MagicPlayMan {
    // MARK: - PreviewView

    struct PreviewView: View {
        // MARK: - Properties

        @StateObject private var playMan: MagicPlayMan
        @State private var selectedSampleName: String?
        @State private var showPlaylist = false
        @State private var showFormats = false
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

        // MARK: - Body

        public var body: some View {
            VStack(spacing: 0) {
                toolbarView

                ZStack {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            mainContentView
                                .frame(maxWidth: .infinity)

                            if showPlaylist {
                                playlistSidebarView
                            }
                        }

                        controlsView

                        // MARK: Bottom

                        GroupBox {
                            bottomView
                        }.padding()
                    }

                    if showFormats {
                        FormatInfoView(
                            formats: SupportedFormat.allFormats,
                            onDismiss: { showFormats = false }
                        )
                    }
                }
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
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showPlaylist)
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

                HStack {
                    playMan.makePlaylistButton(isPresented: $showPlaylist)
                        .popover(isPresented: $showPlaylist) {
                            playMan.makePlaylistView()
                                .frame(width: 300, height: 400)
                                .padding()
                        }

                    MagicButton(
                        icon: "info.circle",
                        style: .secondary,
                        size: .small,
                        shape: .circle,
                        action: { showFormats = true }
                    )

                    MagicButton(
                        icon: "list.bullet",
                        style: .secondary,
                        size: .small,
                        shape: .circle,
                        action: { showLogs.toggle() }
                    )
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }

        private var mainContentView: some View {
            Group {
                if let asset = playMan.currentAsset {
                    ZStack {
                        playMan.makeAssetView()

                        if case let .loading(loadingState) = playMan.state {
                            LoadingOverlay(
                                state: loadingState,
                                assetTitle: asset.title
                            )
                        }

                        if case let .failed(error) = playMan.state {
                            ErrorOverlay(
                                error: error,
                                asset: asset,
                                onRetry: { playMan.load(asset: asset) }
                            )
                        }
                    }
                } else {
                    playMan.makeEmptyView()
                }
            }
        }

        private var playlistSidebarView: some View {
            playMan.makePlaylistView()
                .frame(width: 300)
                .background(.ultraThinMaterial)
                .transition(.move(edge: .trailing))
        }

        private var controlsView: some View {
            VStack(spacing: 16) {
                playMan.makeProgressView()
                PlaybackControls(playMan: playMan)
            }
            .padding()
            .background(.ultraThinMaterial)
        }

        private var bottomView: some View {
            VStack {
                if showLogs {
                    playMan.makeLogView()
                        .frame(height: 120)
                        .padding()
                        .background(.ultraThinMaterial)
                }
            }
        }

        // MARK: - Helper Views

        private func LoadingOverlay(state: PlaybackState.LoadingState, assetTitle: String) -> some View {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)

                switch state {
                case let .downloading(progress):
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

        // MARK: - Helper Methods

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
