import Foundation

public enum PlayMode {
    case sequence   // 顺序播放
    case single    // 单曲循环
    case random    // 随机播放
    
    var icon: String {
        switch self {
        case .sequence:
            return "repeat"
        case .single:
            return "repeat.1"
        case .random:
            return "shuffle"
        }
    }
    
    mutating func toggle() {
        switch self {
        case .sequence:
            self = .single
        case .single:
            self = .random
        case .random:
            self = .sequence
        }
    }
} 