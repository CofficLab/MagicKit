import Foundation
import SwiftUI

public extension MagicPlayMan {
    // MARK: - Playlist Management
    
    /// 添加资源到播放列表并播放
    func play(asset: MagicAsset) {
        if playlist.play(asset) {
            load(asset: asset)
        } else {
            playlist.append(asset)
            _ = playlist.play(asset)
            load(asset: asset)
        }
    }
    
    /// 添加资源到播放列表
    func append(_ asset: MagicAsset) {
        playlist.append(asset)
    }
    
    /// 清空播放列表
    func clearPlaylist() {
        playlist.clear()
    }
    
    /// 播放下一曲
    func next() {
        if let nextAsset = playlist.playNext(mode: playMode) {
            load(asset: nextAsset)
        }
    }
    
    /// 播放上一曲
    func previous() {
        if let prevAsset = playlist.playPrevious(mode: playMode) {
            load(asset: prevAsset)
        }
    }
    
    /// 从播放列表中移除指定索引的资源
    func removeFromPlaylist(at index: Int) {
        playlist.remove(at: index)
    }
    
    /// 移动播放列表中的资源
    func moveInPlaylist(from: Int, to: Int) {
        playlist.move(from: from, to: to)
    }
}

// MARK: - Preview
#Preview("Playlist Management") {
    PlaylistPreview()
}

private struct PlaylistPreview: View {
    @StateObject private var playMan = MagicPlayMan()
    
    // 将示例资源移到单独的计算属性中
    private var audioSample: MagicAsset {
        MagicAsset(
            url: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/fd/37/41/fd374113-bf05-692f-e157-5c364af08d9d/mzaf_15384825730917775750.plus.aac.p.m4a")!,
            type: .audio,
            metadata: .init(
                title: "Sample Audio 1",
                artist: "Artist 1",
                album: "Album 1"
            )
        )
    }
    
    private var videoSample: MagicAsset {
        MagicAsset(
            url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
            type: .video,
            metadata: .init(
                title: "Sample Video 1",
                artist: "Artist 2",
                album: "Album 2"
            )
        )
    }
    
    private var sampleAssets: [MagicAsset] {
        [audioSample, videoSample]
    }
    
    var body: some View {
        List {
            playbackControlSection
            playlistSection
            addSamplesSection
        }
        .navigationTitle("播放列表管理")
    }
    
    // MARK: - Sections
    private var playbackControlSection: some View {
        Section("播放控制") {
            HStack {
                Button("上一曲") {
                    playMan.previous()
                }
                
                Button("播放/暂停") {
                    if playMan.playing {
                        playMan.pause()
                    } else {
                        playMan.play()
                    }
                }
                
                Button("下一曲") {
                    playMan.next()
                }
            }
        }
    }
    
    private var playlistSection: some View {
        Section("播放列表") {
            ForEach(playMan.items) { asset in
                PlaylistItemRow(asset: asset)
            }
            .onMove { from, to in
                if let firstIndex = from.first {
                    playMan.moveInPlaylist(from: firstIndex, to: to)
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    playMan.removeFromPlaylist(at: index)
                }
            }
        }
    }
    
    private var addSamplesSection: some View {
        Section("添加测试资源") {
            ForEach(sampleAssets) { asset in
                Button("添加 \(asset.metadata.title)") {
                    playMan.append(asset)
                }
            }
            
            Button("清空播放列表", role: .destructive) {
                playMan.clearPlaylist()
            }
        }
    }
}

// MARK: - Supporting Views
private struct PlaylistItemRow: View {
    let asset: MagicAsset
    
    var body: some View {
        HStack {
            Image(systemName: asset.type == .audio ? "music.note" : "film")
            VStack(alignment: .leading) {
                Text(asset.metadata.title)
                    .font(.headline)
                Text(asset.metadata.artist ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
} 
