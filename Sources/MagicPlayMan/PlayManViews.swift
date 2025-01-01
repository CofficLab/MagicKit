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
                        MagicVideoPlayer(player: playMan.player)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        MagicAudioView(
                            title: asset.metadata.title,
                            artist: asset.metadata.artist
                        )
                    }
                } else {
                    MagicAudioView(
                        title: "No Media Selected",
                        artist: "Select a media file to play"
                    )
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
            }
        }
        
        private var currentAssetIcon: String {
            guard let asset = playMan.currentAsset else {
                return "play.circle"
            }
            return asset.type == .audio ? "music.note" : "film"
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
