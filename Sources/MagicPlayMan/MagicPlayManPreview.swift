import SwiftUI

#if DEBUG
struct MagicPlayManPreview: View {
    @StateObject private var playMan = MagicPlayMan()
    @State private var selectedSampleName: String?
    @State private var isDarkMode = false
    @State private var isInspectorExpanded = true
    
    private var allSamples: [(name: String, asset: MagicAsset)] {
        MagicPlayMan.audioSamples + MagicPlayMan.videoSamples
    }
    
    var body: some View {
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

private struct AudioPlayerPreview: View {
    @ObservedObject var playMan: MagicPlayMan
    @State private var selectedSampleName: String?
    
    var body: some View {
        VStack(spacing: 20) {
            // 格式选择器
            Menu {
                ForEach(MagicPlayMan.audioSamples, id: \.name) { sample in
                    Button(sample.name) {
                        selectedSampleName = sample.name
                        playMan.load(asset: sample.asset)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "music.note.list")
                    Text(selectedSampleName ?? "Select Audio Sample")
                    Image(systemName: "chevron.down")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
            
            // 资源信息
            AssetInfoView(asset: playMan.currentAsset)
            
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
    }
}

private struct VideoPlayerPreview: View {
    @ObservedObject var playMan: MagicPlayMan
    @State private var selectedSampleName: String?
    
    var body: some View {
        VStack(spacing: 20) {
            // 格式选择器
            Menu {
                ForEach(MagicPlayMan.videoSamples, id: \.name) { sample in
                    Button(sample.name) {
                        selectedSampleName = sample.name
                        playMan.load(asset: sample.asset)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "film.stack")
                    Text(selectedSampleName ?? "Select Video Sample")
                    Image(systemName: "chevron.down")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
            
            // 视频视图
            if playMan.currentAsset != nil {
                VideoPlayerView(player: playMan.player)
                    .frame(maxWidth: .infinity)
                    .frame(height: 225)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
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
    }
}

// 辅助视图组件
private struct AssetInfoView: View {
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

private struct PlaybackControlsView: View {
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

private struct LoadAssetButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(title, action: action)
            .buttonStyle(.borderedProminent)
    }
}

private struct EmptyVideoView: View {
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

extension PlaybackState.LoadingPhase {
    var description: String {
        switch self {
        case .connecting:
            return "Connecting..."
        case .buffering:
            return "Buffering..."
        case .preparing:
            return "Preparing..."
        }
    }
}

private struct LogView: View {
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

// 首先添加状态检查器视图
private struct StateInspectorView: View {
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

// 更新预览尺寸
#Preview("MagicPlayMan") {
    MagicPlayManPreview()
        .frame(width: 650, height: 500)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
}
#endif 
