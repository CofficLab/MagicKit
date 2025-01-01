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
        case downloading(Double)
        case preparing
        case buffering
    }
    
    public enum PlaybackError: Equatable {
        case noAsset
        case invalidAsset
        case networkError(String)
        case playbackError(String)
    }
}