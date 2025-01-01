import SwiftUI
import MagicUI

public extension MagicPlayMan {
    /// 创建一个预览视图，用于快速展示播放器的功能
    struct PreviewView: View {
        @StateObject private var playMan: MagicPlayMan
        @State private var selectedSampleName: String?
        @State private var showMediaPicker = false
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
                // 顶部工具栏
                HStack {
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
                    
                    if let asset = playMan.currentAsset {
                        Text(asset.metadata.title)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    MagicButton(
                        icon: "info.circle",
                        style: .secondary,
                        size: .small,
                        shape: .circle,
                        action: { showFormats = true }
                    )
                }
                .padding()
                .background(.ultraThinMaterial)
                
                // 格式信息视图
                if showFormats {
                    FormatInfoView(
                        formats: playMan.supportedFormats,
                        onDismiss: { showFormats = false }
                    )
                }
                
                // 主内容区域
                if let asset = playMan.currentAsset {
                    ZStack {
                        if asset.type == .video {
                            playMan.videoView
                        } else {
                            playMan.audioView
                        }
                        
                        // 加载状态覆盖层
                        if case .loading(let loadingState) = playMan.state {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                            
                            switch loadingState {
                            case .downloading(let progress):
                                VStack(spacing: 16) {
                                    ProgressView("Downloading \(asset.metadata.title)", value: progress, total: 1.0)
                                    Text("\(Int(progress * 100))%")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                            case .buffering:
                                VStack(spacing: 16) {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                    Text("Buffering...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                            case .preparing:
                                VStack(spacing: 16) {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                    Text("Preparing...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                            case .connecting:
                                VStack(spacing: 16) {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                    Text("Connecting...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        // 失败状态覆盖层
                        if case .failed(let error) = playMan.state {
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
                            action: playMan.toggle
                        )
                        
                        MagicPlayerButton(
                            icon: "forward.fill",
                            action: { playMan.skipForward() }
                        )
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                
                // 日志视图（可选）
                if showLogs {
                    LogView(
                        logs: playMan.logs,
                        onClear: { playMan.clearLogs() }
                    )
                    .frame(height: 120)
                    .padding()
                    .background(.ultraThinMaterial)
                }
            }
        }
        
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

#Preview("With Logs") {
    MagicPlayMan.PreviewView(showLogs: true)
        .frame(width: 650, height: 650)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
}

#Preview("Without Logs") {
    MagicPlayMan.PreviewView(showLogs: false)
        .frame(width: 650, height: 500)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
} 
