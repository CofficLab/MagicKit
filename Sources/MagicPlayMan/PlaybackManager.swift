import Foundation
import SwiftUI

public class PlaybackManager {
    private weak var playMan: MagicPlayMan?
    private var shuffledIndices: [Int] = []
    
    @Published public internal(set) var mode: PlayMode = .sequence
    @Published var playlist: [MagicAsset] = []
    @Published var currentIndex: Int = -1
    
    init(playMan: MagicPlayMan) {
        self.playMan = playMan
    }
    
    // MARK: - 播放列表管理
    
    func append(_ asset: MagicAsset) {
        playlist.append(asset)
        updateShuffleIndices()
    }
    
    func remove(at index: Int) {
        guard index >= 0, index < playlist.count else { return }
        playlist.remove(at: index)
        updateShuffleIndices()
        
        // 如果删除的是当前播放项，自动播放下一首
        if index == currentIndex {
            next()
        } else if index < currentIndex {
            currentIndex -= 1
        }
    }
    
    func move(from source: Int, to destination: Int) {
        playlist.move(fromOffsets: IndexSet(integer: source), toOffset: destination)
        updateShuffleIndices()
        
        // 更新当前索引
        if currentIndex == source {
            currentIndex = destination
        } else if source < currentIndex && destination >= currentIndex {
            currentIndex -= 1
        } else if source > currentIndex && destination <= currentIndex {
            currentIndex += 1
        }
    }
    
    func clear() {
        playlist.removeAll()
        currentIndex = -1
        shuffledIndices.removeAll()
    }
    
    // MARK: - 播放控制
    
    func play(asset: MagicAsset) {
        if let index = playlist.firstIndex(of: asset) {
            currentIndex = index
            playMan?.load(asset: asset)
        } else {
            playlist.append(asset)
            currentIndex = playlist.count - 1
            playMan?.load(asset: asset)
        }
    }
    
    func next() {
        guard !playlist.isEmpty else { return }
        
        switch mode {
        case .sequence:
            playNext()
        case .loop:
            // 单曲循环，重新播放当前歌曲
            if let current = currentAsset {
                playMan?.load(asset: current)
            }
        case .shuffle:
            playNextShuffled()
        case .repeatAll:
            playNextWithRepeat()
        }
    }
    
    func previous() {
        guard !playlist.isEmpty else { return }
        
        switch mode {
        case .sequence:
            playPrevious()
        case .loop:
            // 单曲循环，重新播放当前歌曲
            if let current = currentAsset {
                playMan?.load(asset: current)
            }
        case .shuffle:
            playPreviousShuffled()
        case .repeatAll:
            playPreviousWithRepeat()
        }
    }
    
    // MARK: - 播放模式
    
    func toggleMode() {
        mode = mode.next
        if mode == .shuffle {
            updateShuffleIndices()
        }
    }
    
    // MARK: - 私有辅助方法
    
    private var currentAsset: MagicAsset? {
        guard currentIndex >= 0, currentIndex < playlist.count else { return nil }
        return playlist[currentIndex]
    }
    
    private func playNext() {
        let nextIndex = currentIndex + 1
        guard nextIndex < playlist.count else { return }
        currentIndex = nextIndex
        playMan?.load(asset: playlist[nextIndex])
    }
    
    private func playNextWithRepeat() {
        var nextIndex = currentIndex + 1
        if nextIndex >= playlist.count {
            nextIndex = 0
        }
        currentIndex = nextIndex
        playMan?.load(asset: playlist[nextIndex])
    }
    
    private func playNextShuffled() {
        guard let nextIndex = shuffledIndices.first(where: { $0 > currentIndex }) else {
            // 如果没有更多随机索引，重新生成并播放第一个
            updateShuffleIndices()
            if let firstIndex = shuffledIndices.first {
                currentIndex = firstIndex
                playMan?.load(asset: playlist[firstIndex])
            }
            return
        }
        currentIndex = nextIndex
        playMan?.load(asset: playlist[nextIndex])
    }
    
    private func playPrevious() {
        let prevIndex = currentIndex - 1
        guard prevIndex >= 0 else { return }
        currentIndex = prevIndex
        playMan?.load(asset: playlist[prevIndex])
    }
    
    private func playPreviousWithRepeat() {
        var prevIndex = currentIndex - 1
        if prevIndex < 0 {
            prevIndex = playlist.count - 1
        }
        currentIndex = prevIndex
        playMan?.load(asset: playlist[prevIndex])
    }
    
    private func playPreviousShuffled() {
        guard let prevIndex = shuffledIndices.last(where: { $0 < currentIndex }) else {
            // 如果没有更多随机索引，跳到最后一个
            if let lastIndex = shuffledIndices.last {
                currentIndex = lastIndex
                playMan?.load(asset: playlist[lastIndex])
            }
            return
        }
        currentIndex = prevIndex
        playMan?.load(asset: playlist[prevIndex])
    }
    
    private func updateShuffleIndices() {
        shuffledIndices = Array(0..<playlist.count).shuffled()
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
