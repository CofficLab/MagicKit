import MagicCore
import SwiftUI

struct ErrorOverlay: View {
    let error: PlaybackState.PlaybackError
    let asset: MagicAsset
    let onRetry: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.red)

                Text("Failed to Load Media")
                    .font(.headline)

                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                MagicButton.simple(
                    icon: "arrow.clockwise",
                    title: "Try Again",
                    shape: .capsule,
                    action: onRetry
                )
            }
            .padding()
        }
    }

    private var errorMessage: String {
        switch error {
        case .noAsset:
            return "No media selected"
        case .invalidAsset:
            return "The media file is invalid or corrupted"
        case let .networkError(message):
            return "Network error: \(message)"
        case let .playbackError(message):
            return "Playback error: \(message)"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ErrorOverlay(
            error: .invalidAsset,
            asset: .init(url: .documentsDirectory, metadata: .init(title: "Test")),
            onRetry: {}
        )
        .frame(height: 200)

        ErrorOverlay(
            error: .networkError("Connection timeout"),
            asset: .init(url: .documentsDirectory, metadata: .init(title: "Test")),
            onRetry: {}
        )
        .frame(height: 200)
    }
    .padding()
}
