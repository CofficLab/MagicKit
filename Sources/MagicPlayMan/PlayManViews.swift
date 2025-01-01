import SwiftUI
import MagicUI

public extension MagicPlayMan {
    /// 创建一个预览视图，用于快速展示播放器的功能
    struct PreviewView: View {
        @StateObject private var playMan: MagicPlayMan
        @State private var selectedSampleName: String?
        @State private var showMediaPicker = false
        
        public init(cacheDirectory: URL? = nil) {
            _playMan = StateObject(wrappedValue: MagicPlayMan(cacheDirectory: cacheDirectory))
        }
        
        public var body: some View {
            VStack(spacing: 0) {
                // 顶部工具栏
                HStack {
                    Menu {
                        ForEach(MagicPlayMan.audioSamples, id: \.name) { sample in
                            Button {
                                selectedSampleName = sample.name
                                playMan.load(asset: sample.asset)
                            } label: {
                                Label(sample.name, systemImage: "music.note")
                            }
                        }
                        
                        Divider()
                        
                        ForEach(MagicPlayMan.videoSamples, id: \.name) { sample in
                            Button {
                                selectedSampleName = sample.name
                                playMan.load(asset: sample.asset)
                            } label: {
                                Label(sample.name, systemImage: "film")
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
                    
                    if let asset = playMan.currentAsset {
                        Text(asset.metadata.title)
                            .font(.headline)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(.ultraThinMaterial)
                
                // 主内容区域
                if let asset = playMan.currentAsset {
                    if asset.type == .video {
                        playMan.videoView
                    } else {
                        playMan.audioView
                    }
                } else {
                    playMan.emptyView
                }
                
                // 底部控制栏
                VStack(spacing: 16) {
                    // 进度条
                    MagicProgressBar(
                        progress: .init(
                            get: { playMan.progress },
                            set: { progress in
                                playMan.seek(to: progress)
                            }
                        ),
                        duration: playMan.duration,
                        onSeek: { progress in
                            playMan.seek(to: progress)
                        }
                    )
                    
                    // 控制按钮
                    HStack(spacing: 20) {
                        MagicPlayerButton(
                            icon: "backward.fill",
                            action: { playMan.skipBackward() }
                        )
                        
                        MagicPlayerButton(
                            icon: playMan.state == .playing ? "pause.fill" : "play.fill",
                            size: 50,
                            iconSize: 20,
                            isActive: playMan.state == .playing,
                            action: { 
                                if playMan.state == .playing {
                                    playMan.pause()
                                } else {
                                    playMan.play()
                                }
                            }
                        )
                        
                        MagicPlayerButton(
                            icon: "forward.fill",
                            action: { playMan.skipForward() }
                        )
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                
                // 日志视图
                LogView(
                    logs: playMan.logs,
                    onClear: { playMan.clearLogs() }
                )
                .frame(height: 120)
                .padding()
                .background(.ultraThinMaterial)
            }
        }
        
        private var currentAssetIcon: String {
            guard let asset = playMan.currentAsset else {
                return "play.circle"
            }
            return asset.type == .audio ? "music.note" : "film"
        }
    }
    
    // 日志视图组件
    private struct LogView: View {
        let logs: [PlaybackLog]
        let onClear: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Logs")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    // 使用 MagicButton 替代普通按钮
                    MagicButton(
                        icon: "trash",
                        title: "Clear",
                        style: .secondary,
                        size: .small,
                        shape: .capsule,
                        action: onClear
                    )
                }
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(logs.reversed()) { log in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(logColor(for: log.level))
                                    .frame(width: 8, height: 8)
                                
                                Text(formatTime(log.timestamp))
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.secondary)
                                
                                Text(log.message)
                                    .font(.caption)
                                    .foregroundStyle(log.level == .error ? .red : .primary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
        }
        
        private func logColor(for level: PlaybackLog.Level) -> Color {
            switch level {
            case .info:
                return .green
            case .warning:
                return .orange
            case .error:
                return .red
            }
        }
        
        private func formatTime(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            return formatter.string(from: date)
        }
    }
}

#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
        .frame(width: 650, height: 650)  // 增加高度以适应日志视图
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
} 
