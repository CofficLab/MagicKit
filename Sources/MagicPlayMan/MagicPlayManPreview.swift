import SwiftUI
import AVFoundation

#if DEBUG
struct MagicPlayManPreview: View {
    @StateObject private var playMan = MagicPlayMan()
    @State private var isPlaying = false
    
    // 示例音频URL
    private let sampleURL = URL(string: "https://download.samplelib.com/mp3/sample-15s.mp3")!
    
    var body: some View {
        VStack(spacing: 20) {
            // 当前资源信息
            if let asset = playMan.currentAsset {
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
            
            // 播放状态
            Text("State: \(String(describing: playMan.state))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // 当前时间和总时长
            HStack {
                Text(formatTime(playMan.currentTime))
                Text("/")
                Text(formatTime(playMan.duration))
            }
            .font(.system(.body, design: .monospaced))
            .foregroundStyle(.secondary)
            
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景轨道
                    Capsule()
                        .fill(.secondary.opacity(0.2))
                        .frame(height: 4)
                    
                    // 进度轨道
                    Capsule()
                        .fill(.blue)
                        .frame(
                            width: geometry.size.width * CGFloat(playMan.currentTime / max(playMan.duration, 1)),
                            height: 4
                        )
                }
            }
            .frame(height: 4)
            .padding(.horizontal)
            
            // 控制按钮
            HStack(spacing: 40) {
                Button {
                    playMan.seek(to: 0)
                } label: {
                    Image(systemName: "backward.fill")
                }
                .buttonStyle(.plain)
                
                Button {
                    if isPlaying {
                        playMan.pause()
                    } else {
                        playMan.play()
                    }
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                
                Button {
                    playMan.seek(to: 1)
                } label: {
                    Image(systemName: "forward.fill")
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            // 加载示例资源按钮
            if playMan.currentAsset == nil {
                Button("Load Sample Asset") {
                    let sampleAsset = MagicAsset(
                        url: sampleURL,
                        type: .audio,
                        metadata: AssetMetadata(
                            title: "Sample Audio",
                            artist: "Sample Artist",
                            duration: 15
                        )
                    )
                    playMan.load(asset: sampleAsset)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onReceive(playMan.$state) { state in
            isPlaying = state == .playing
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview("MagicPlayMan") {
    VStack(spacing: 30) {
        Text("Light Mode")
            .font(.headline)
        
        MagicPlayManPreview()
            .frame(width: 400, height: 300)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 5)
        
        Text("Dark Mode")
            .font(.headline)
        
        MagicPlayManPreview()
            .frame(width: 400, height: 300)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 5)
            .environment(\.colorScheme, .dark)
    }
    .padding()
}
#endif 