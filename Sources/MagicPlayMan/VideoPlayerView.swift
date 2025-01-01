import SwiftUI
import AVFoundation

#if os(macOS)
struct VideoPlayerView: NSViewRepresentable {
    let player: AVPlayer
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        view.layer = playerLayer
        view.wantsLayer = true
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        guard let playerLayer = nsView.layer as? AVPlayerLayer else { return }
        playerLayer.player = player
        playerLayer.frame = nsView.bounds
    }
}
#else
struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let playerLayer = uiView.layer.sublayers?.first as? AVPlayerLayer else { return }
        playerLayer.frame = uiView.bounds
    }
}
#endif 