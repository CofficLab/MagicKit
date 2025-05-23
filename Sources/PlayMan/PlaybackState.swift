import Foundation
import SwiftUI

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
    
    public enum PlaybackError: LocalizedError, Equatable {
        case noAsset
        case invalidAsset
        case networkError(String)
        case playbackError(String)
        
        public var errorDescription: String? {
            switch self {
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
        
        public var failureReason: String? {
            switch self {
            case .noAsset:
                return "Please select a media file to play"
            case .invalidAsset:
                return "The file format is not supported or the file is corrupted"
            case .networkError:
                return "There was a problem with the network connection"
            case .playbackError:
                return "There was a problem during playback"
            }
        }
        
        public var recoverySuggestion: String? {
            switch self {
            case .noAsset:
                return "Select a media file from your library"
            case .invalidAsset:
                return "Try with a different media file"
            case .networkError:
                return "Check your internet connection and try again"
            case .playbackError:
                return "Try reloading the media file"
            }
        }
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
    
    public var iconName: String {
        switch self {
        case .idle:
            return "circle.dashed"
        case .loading:
            return "arrow.clockwise"
        case .playing:
            return "play.circle.fill"
        case .paused:
            return "pause.circle.fill"
        case .stopped:
            return "stop.circle.fill"
        case .failed:
            return "exclamationmark.circle.fill"
        }
    }
    
    public var iconColor: Color {
        switch self {
        case .idle:
            return .secondary
        case .loading:
            return .blue
        case .playing:
            return .green
        case .paused, .stopped:
            return .primary
        case .failed:
            return .red
        }
    }
    
    public var stateText: String {
        switch self {
        case .idle:
            return "Ready"
        case .loading(let loadingState):
            switch loadingState {
            case .connecting:
                return "Connecting..."
            case .preparing:
                return "Preparing..."
            case .buffering:
                return "Buffering..."
            case .downloading(let progress):
                return "Downloading... \(Int(progress * 100))%"
            }
        case .playing:
            return "Playing"
        case .paused:
            return "Paused"
        case .stopped:
            return "Stopped"
        case .failed:
            return "Failed"
        }
    }
    
    // MARK: - View Builder
    
    /// 创建状态视图
    public func makeStateView(assetTitle: String? = nil) -> some View {
        StateView(state: self, assetTitle: assetTitle)
    }
}

// MARK: - State View
public struct StateView: View {
    let state: PlaybackState
    let assetTitle: String?
    
    public var body: some View {
        HStack(spacing: 12) {
            // 状态图标
            Image(systemName: state.iconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(state.iconColor)
                .symbolEffect(.pulse, options: .repeating, value: isAnimated)
            
            VStack(alignment: .leading, spacing: 4) {
                // 状态文本
                Text(state.stateText)
                    .font(.subheadline)
                    .foregroundStyle(state.iconColor)
                
                // 如果有资源标题，显示在下方
                if let title = assetTitle {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // 如果是加载状态，显示进度
                if case .loading(let loadingState) = state {
                    if case .downloading(let progress) = loadingState {
                        ProgressView(value: progress, total: 1.0)
                            .progressViewStyle(.linear)
                    } else {
                        ProgressView()
                            .progressViewStyle(.linear)
                            .opacity(0.5)
                    }
                }
                
                // 如果是错误状态，显示错误信息
                if case .failed(let error) = state {
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Helper Properties
    
    private var isAnimated: Bool {
        if case .loading = state {
            return true
        }
        return false
    }
}

// MARK: - Preview
#Preview("PlaybackState Views") {
    VStack(spacing: 20) {
        PlaybackState.idle.makeStateView()
        PlaybackState.loading(.connecting).makeStateView(assetTitle: "Test Media")
        PlaybackState.loading(.downloading(0.45)).makeStateView(assetTitle: "Downloading...")
        PlaybackState.playing.makeStateView(assetTitle: "Now Playing")
        PlaybackState.paused.makeStateView(assetTitle: "Paused Media")
        PlaybackState.stopped.makeStateView()
        PlaybackState.failed(.networkError("Connection timeout")).makeStateView()
    }
    .padding()
    .frame(height: 700)
}
