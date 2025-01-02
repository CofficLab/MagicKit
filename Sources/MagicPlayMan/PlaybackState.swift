import Foundation

public enum PlaybackState: Equatable {
    case idle
    case loading(LoadingState)
    case playing
    case paused
    case stopped
    case failed(PlaybackError)
    
    public enum LoadingState: Equatable {
        case connecting
        case preparing
        case buffering
        case downloading(Double)
    }
    
    public enum PlaybackError: Equatable {
        case noAsset
        case invalidAsset
        case networkError(String)
        case playbackError(String)
    }
    
    public var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    public var canSeek: Bool {
        switch self {
        case .idle, .loading, .failed:
            return false
        case .playing, .paused, .stopped:
            return true
        }
    }
}
