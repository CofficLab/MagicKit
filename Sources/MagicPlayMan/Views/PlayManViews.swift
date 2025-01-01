import SwiftUI
import AVFoundation

// MARK: - 预览视图
public extension MagicPlayMan {
    /// 创建一个预览视图，用于快速展示播放器的功能
    struct PreviewView: View {
        @StateObject private var playMan: MagicPlayMan
        @State private var selectedSampleName: String?
        @State private var isDarkMode = false
        @State private var isInspectorExpanded = true
        
        public init(cacheDirectory: URL? = nil) {
            _playMan = StateObject(wrappedValue: MagicPlayMan(cacheDirectory: cacheDirectory))
        }
        
        private var allSamples: [(name: String, asset: MagicAsset)] {
            MagicPlayMan.audioSamples + MagicPlayMan.videoSamples
        }
        
        public var body: some View {
            HStack(spacing: 0) {
                // 主内容
                VStack(spacing: 20) {
                    // 格式选择器
                    Menu {
                        ForEach(allSamples, id: \.name) { sample in
                            Button(sample.name) {
                                selectedSampleName = sample.name
                                playMan.load(asset: sample.asset)
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
                    
                    // 资源信息
                    AssetInfoView(asset: playMan.currentAsset)
                    
                    // 视频视图（仅在播放视频时显示）
                    if let asset = playMan.currentAsset, asset.type == .video {
                        VideoPlayerView(player: playMan.player)
                            .frame(maxWidth: .infinity)
                            .frame(height: 225)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else if playMan.currentAsset == nil {
                        EmptyVideoView()
                    }
                    
                    // 播放控制
                    PlaybackControlsView(
                        isPlaying: playMan.state == .playing,
                        progress: playMan.progress,
                        currentTime: playMan.currentTime,
                        duration: playMan.duration,
                        state: playMan.state,
                        onPlay: { playMan.play() },
                        onPause: { playMan.pause() },
                        onSeek: { playMan.seek(to: $0) },
                        onSkipForward: { playMan.skipForward() },
                        onSkipBackward: { playMan.skipBackward() }
                    )
                    
                    // 日志视图
                    LogView(logs: playMan.logs)
                }
                .padding()
                .frame(width: 400)
                
                // 状态检查器
                StateInspectorView(
                    playMan: playMan,
                    isExpanded: $isInspectorExpanded
                )
                .frame(width: isInspectorExpanded ? 250 : 150)
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    isDarkMode.toggle()
                } label: {
                    Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                        .font(.title3)
                        .foregroundStyle(isDarkMode ? .yellow : .primary)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding()
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        
        private var currentAssetIcon: String {
            guard let asset = playMan.currentAsset else {
                return "play.circle"
            }
            return asset.type == .audio ? "music.note" : "film"
        }
    }
}

// MARK: - 组件视图
struct AssetInfoView: View {
    let asset: MagicAsset?
    
    var body: some View {
        if let asset = asset {
            VStack(spacing: 4) {
                Text(asset.metadata.title)
                    .font(.headline)
                if let artist = asset.metadata.artist {
                    Text(artist)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct PlaybackControlsView: View {
    let isPlaying: Bool
    let progress: Double
    let currentTime: TimeInterval
    let duration: TimeInterval
    let state: PlaybackState
    let onPlay: () -> Void
    let onPause: () -> Void
    let onSeek: (Double) -> Void
    let onSkipForward: () -> Void
    let onSkipBackward: () -> Void
    
    private var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }
    
    private var isError: Bool {
        if case .failed = state { return true }
        return false
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // 进度条
            ProgressView(value: progress)
                .padding(.horizontal)
                .disabled(isLoading || isError)
            
            // 时间显示
            HStack {
                Text(formatTime(currentTime))
                Spacer()
                Text(formatTime(duration))
            }
            .font(.caption.monospaced())
            .foregroundStyle(.secondary)
            
            // 控制按钮
            HStack(spacing: 40) {
                Button(action: onSkipBackward) {
                    Image(systemName: "gobackward.10")
                }
                .disabled(isLoading || isError)
                
                Button(action: isPlaying ? onPause : onPlay) {
                    if isLoading {
                        ProgressView()
                            .controlSize(.regular)
                    } else {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                    }
                }
                .disabled(isLoading || isError)
                
                Button(action: onSkipForward) {
                    Image(systemName: "goforward.10")
                }
                .disabled(isLoading || isError)
            }
            .buttonStyle(.plain)
            
            // 状态显示
            if case .loading(let phase) = state {
                HStack {
                    ProgressView()
                        .controlSize(.small)
                    Text(phase.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else if case .failed(let error) = state {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text(error.message)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(.red.opacity(0.1))
                .clipShape(Capsule())
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct VideoPlayerView: View {
    let player: AVPlayer
    
    var body: some View {
        VideoPlayerViewRepresentable(player: player)
    }
}

private extension VideoPlayerView {
    struct VideoPlayerViewRepresentable: View {
        let player: AVPlayer
        
        var body: some View {
            #if os(macOS)
            MacVideoPlayerView(player: player)
            #else
            iOSVideoPlayerView(player: player)
            #endif
        }
    }
    
    #if os(macOS)
    struct MacVideoPlayerView: NSViewRepresentable {
        let player: AVPlayer
        
        func makeNSView(context: Context) -> NSView {
            let view = NSView()
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspect
            view.layer = playerLayer
            view.wantsLayer = true
            return view
        }
        
        func updateNSView(_ nsView: NSView, context: Context) {
            guard let playerLayer = nsView.layer as? AVPlayerLayer else { return }
            playerLayer.player = player
            playerLayer.frame = nsView.bounds
        }
    }
    #else
    struct iOSVideoPlayerView: UIViewRepresentable {
        let player: AVPlayer
        
        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspect
            view.layer.addSublayer(playerLayer)
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
            guard let playerLayer = uiView.layer.sublayers?.first as? AVPlayerLayer else { return }
            playerLayer.frame = uiView.bounds
        }
    }
    #endif
}

struct EmptyVideoView: View {
    var body: some View {
        Rectangle()
            .fill(.secondary.opacity(0.1))
            .frame(maxWidth: .infinity)
            .frame(height: 225)
            .overlay {
                Image(systemName: "film")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct LogView: View {
    let logs: [PlaybackLog]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(logs) { log in
                    Text(log.formattedMessage)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(foregroundColor(for: log.level))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 100)
        .padding(8)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func foregroundColor(for level: PlaybackLog.Level) -> Color {
        switch level {
        case .info: return .primary
        case .warning: return .orange
        case .error: return .red
        }
    }
}

struct StateInspectorView: View {
    let playMan: MagicPlayMan
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题栏
            HStack {
                Text("State Inspector")
                    .font(.headline)
                Spacer()
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .buttonStyle(.plain)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    // 播放状态
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Playback State")
                            .font(.subheadline.bold())
                        Text(stateDescription)
                            .font(.caption.monospaced())
                            .foregroundStyle(stateColor)
                    }
                    
                    // 播放进度
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Progress")
                            .font(.subheadline.bold())
                        Text(String(format: "%.2f%%", playMan.progress * 100))
                            .font(.caption.monospaced())
                    }
                    
                    // 当前资源
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Asset")
                            .font(.subheadline.bold())
                        if let asset = playMan.currentAsset {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Title: \(asset.metadata.title)")
                                if let artist = asset.metadata.artist {
                                    Text("Artist: \(artist)")
                                }
                                Text("Type: \(asset.type == .audio ? "Audio" : "Video")")
                                Text("Duration: \(Int(asset.metadata.duration))s")
                                Text("URL: \(asset.url.lastPathComponent)")
                            }
                            .font(.caption.monospaced())
                        } else {
                            Text("No asset loaded")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // 缓冲状态
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Buffering")
                            .font(.subheadline.bold())
                        Text(playMan.isBuffering ? "Yes" : "No")
                            .font(.caption.monospaced())
                            .foregroundStyle(playMan.isBuffering ? .orange : .green)
                    }
                }
                .padding(.leading, 8)
            }
        }
        .padding()
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var stateDescription: String {
        switch playMan.state {
        case .idle:
            return "IDLE"
        case .loading(let phase):
            return "LOADING (\(phase))"
        case .playing:
            return "PLAYING"
        case .paused:
            return "PAUSED"
        case .stopped:
            return "STOPPED"
        case .failed(let error):
            return "FAILED: \(error.localizedDescription)"
        }
    }
    
    private var stateColor: Color {
        switch playMan.state {
        case .idle:
            return .secondary
        case .loading:
            return .orange
        case .playing:
            return .green
        case .paused, .stopped:
            return .primary
        case .failed:
            return .red
        }
    }
}

#if DEBUG
struct MagicPlayMan_Previews: PreviewProvider {
    static var previews: some View {
        MagicPlayMan.PreviewView()
            .frame(width: 650, height: 500)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 5)
            .padding()
    }
}
#endif 