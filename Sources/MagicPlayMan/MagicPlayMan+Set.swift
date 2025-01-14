import Foundation
import SwiftUI
import OSLog

extension MagicPlayMan {
    @MainActor
    func setCurrentThumbnail(_ thumbnail: Image?) {
        if verbose {
            os_log("%{public}@🖥️ Setting current thumbnail", log: .default, type: .debug, t)
        }
        currentThumbnail = thumbnail
    }
    
    @MainActor
    func setCurrentTime(_ time: TimeInterval) {
        if verbose {
            os_log("%{public}@⏱️ Setting current time: %{public}f", log: .default, type: .debug, t, time)
        }
        currentTime = time
    }
    
    @MainActor
    func setDuration(_ value: TimeInterval) {
        if verbose {
            os_log("%{public}@⌛️ Setting duration: %{public}f", log: .default, type: .debug, t, value)
        }
        duration = value
    }
    
    @MainActor
    func setBuffering(_ value: Bool) {
        if verbose {
            os_log("%{public}@🔄 Setting buffering: %{public}@", log: .default, type: .debug, t, String(value))
        }
        isBuffering = value
    }
    
    @MainActor
    func setProgress(_ value: Double) {
        if verbose {
            os_log("%{public}@📊 Setting progress: %{public}f", log: .default, type: .debug, t, value)
        }
        progress = value
    }
    
    @MainActor
    func setPlaylistEnabled(_ value: Bool) {
        if verbose {
            os_log("%{public}@📝 Setting playlist enabled: %{public}@", log: .default, type: .debug, t, String(value))
        }
        isPlaylistEnabled = value
    }
    
    @MainActor
    func setLikedAssets(_ assets: Set<URL>) {
        if verbose {
            os_log("%{public}@❤️ Setting liked assets: %{public}d items", log: .default, type: .debug, t, assets.count)
        }
        likedAssets = assets
    }
}

