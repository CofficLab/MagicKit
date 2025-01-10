import Foundation

public class Playlist: ObservableObject {
    @Published public private(set) var items: [URL] = []
    @Published public private(set) var currentIndex: Int = -1
    private var shuffledIndices: [Int] = []
    
    // MARK: - Public Properties
    
    public var currentItem: URL? {
        guard currentIndex >= 0, currentIndex < items.count else { return nil }
        return items[currentIndex]
    }
    
    public var isEmpty: Bool { items.isEmpty }
    public var count: Int { items.count }
    
    // MARK: - Public Methods
    
    public func append(_ asset: URL) {
        items.append(asset)
        updateShuffleIndices()
    }
    
    public func remove(at index: Int) {
        guard index >= 0, index < items.count else { return }
        items.remove(at: index)
        updateShuffleIndices()
        
        // 更新当前索引
        if index == currentIndex {
            currentIndex = min(currentIndex, items.count - 1)
        } else if index < currentIndex {
            currentIndex -= 1
        }
    }
    
    public func move(from source: Int, to destination: Int) {
        items.move(fromOffsets: IndexSet(integer: source), toOffset: destination)
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
    
    public func clear() {
        items.removeAll()
        currentIndex = -1
        shuffledIndices.removeAll()
    }
    
    // MARK: - Navigation Methods
    
    public func play(_ asset: URL) -> Bool {
        if let index = items.firstIndex(of: asset) {
            currentIndex = index
            return true
        }
        return false
    }
    
    public func playNext(mode: MagicPlayMode) -> URL? {
        guard !items.isEmpty else { return nil }
        
        switch mode {
        case .sequence:
            return nextItem()
        case .loop:
            return currentItem
        case .shuffle:
            return nextShuffledItem()
        case .repeatAll:
            return nextWithRepeat()
        }
    }
    
    public func playPrevious(mode: MagicPlayMode) -> URL? {
        guard !items.isEmpty else { return nil }
        
        switch mode {
        case .sequence:
            return previousItem()
        case .loop:
            return currentItem
        case .shuffle:
            return previousShuffledItem()
        case .repeatAll:
            return previousWithRepeat()
        }
    }
    
    // MARK: - Private Methods
    
    private func nextItem() -> URL? {
        let nextIndex = currentIndex + 1
        guard nextIndex < items.count else { return nil }
        currentIndex = nextIndex
        return items[nextIndex]
    }
    
    private func nextWithRepeat() -> URL? {
        var nextIndex = currentIndex + 1
        if nextIndex >= items.count {
            nextIndex = 0
        }
        currentIndex = nextIndex
        return items[nextIndex]
    }
    
    private func nextShuffledItem() -> URL? {
        guard let nextIndex = shuffledIndices.first(where: { $0 > currentIndex }) else {
            updateShuffleIndices()
            if let firstIndex = shuffledIndices.first {
                currentIndex = firstIndex
                return items[firstIndex]
            }
            return nil
        }
        currentIndex = nextIndex
        return items[nextIndex]
    }
    
    private func previousItem() -> URL? {
        let prevIndex = currentIndex - 1
        guard prevIndex >= 0 else { return nil }
        currentIndex = prevIndex
        return items[prevIndex]
    }
    
    private func previousWithRepeat() -> URL? {
        var prevIndex = currentIndex - 1
        if prevIndex < 0 {
            prevIndex = items.count - 1
        }
        currentIndex = prevIndex
        return items[prevIndex]
    }
    
    private func previousShuffledItem() -> URL? {
        guard let prevIndex = shuffledIndices.last(where: { $0 < currentIndex }) else {
            if let lastIndex = shuffledIndices.last {
                currentIndex = lastIndex
                return items[lastIndex]
            }
            return nil
        }
        currentIndex = prevIndex
        return items[prevIndex]
    }
    
    private func updateShuffleIndices() {
        shuffledIndices = Array(0..<items.count).shuffled()
    }
}
