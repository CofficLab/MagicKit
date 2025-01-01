import Foundation

public enum PlaybackState: Equatable {
    case idle
    case loading(LoadingPhase)
    case playing
    case paused
    case stopped
    case failed(PlaybackError)
    
    public enum LoadingPhase {
        case connecting
        case buffering
        case preparing
        
        public var description: String {
            switch self {
            case .connecting:
                return "Connecting..."
            case .buffering:
                return "Buffering..."
            case .preparing:
                return "Preparing..."
            }
        }
    }
    
    public enum PlaybackError: Error, Equatable {
        case noAsset
        case invalidAsset
        case networkError(String)
        case playbackError(String)
        
        public var message: String {
            switch self {
            case .noAsset:
                return "No media loaded"
            case .invalidAsset:
                return "Invalid media file"
            case .networkError(let details):
                return "Network error: \(details)"
            case .playbackError(let details):
                return "Playback error: \(details)"
            }
        }
        
        public static func == (lhs: PlaybackError, rhs: PlaybackError) -> Bool {
            lhs.message == rhs.message
        }
    }
    
    public static func == (lhs: PlaybackState, rhs: PlaybackState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.playing, .playing),
             (.paused, .paused),
             (.stopped, .stopped):
            return true
        case (.loading(let lPhase), .loading(let rPhase)):
            return lPhase == rPhase
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}