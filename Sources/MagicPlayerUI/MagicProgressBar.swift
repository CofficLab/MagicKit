import SwiftUI

public struct MagicProgressBar: View {
    @Binding var progress: Double
    @State private var isDragging = false
    @State private var dragProgress: Double
    @State private var isHovering = false
    @Environment(\.colorScheme) private var colorScheme
    var duration: TimeInterval
    var onSeek: ((Double) -> Void)?
    
    public init(
        progress: Binding<Double>,
        duration: TimeInterval,
        onSeek: ((Double) -> Void)? = nil
    ) {
        self._progress = progress
        self._dragProgress = State(initialValue: progress.wrappedValue)
        self.duration = duration
        self.onSeek = onSeek
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.primary.opacity(isHovering ? 0.15 : 0.1))
                        .frame(height: 4)
                    
                    // Progress track
                    Capsule()
                        .fill(Color.accentColor.opacity(isHovering ? 1 : 0.8))
                        .frame(width: geometry.size.width * CGFloat(isDragging ? dragProgress : progress), height: 4)
                    
                    // Drag handle
                    Circle()
                        .fill(Color.white)
                        .frame(width: isHovering ? 16 : 12, height: isHovering ? 16 : 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                        .shadow(
                            color: Color.black.opacity(isHovering ? 0.25 : 0.15),
                            radius: isHovering ? 6 : 4,
                            y: isHovering ? 3 : 2
                        )
                        .shadow(
                            color: Color.black.opacity(0.1),
                            radius: 1,
                            y: 0
                        )
                        .offset(x: geometry.size.width * CGFloat(isDragging ? dragProgress : progress) - (isHovering ? 8 : 6))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    isDragging = true
                                    let newProgress = min(max(0, value.location.x / geometry.size.width), 1)
                                    withAnimation(.linear(duration: 0.1)) {
                                        dragProgress = Double(newProgress)
                                    }
                                }
                                .onEnded { value in
                                    isDragging = false
                                    let finalProgress = min(max(0, value.location.x / geometry.size.width), 1)
                                    progress = Double(finalProgress)
                                    dragProgress = progress
                                    onSeek?(finalProgress)
                                }
                        )
                }
                .contentShape(Rectangle())
                .onTapGesture { location in
                    let newProgress = min(max(0, location.x / geometry.size.width), 1)
                    progress = Double(newProgress)
                    dragProgress = progress
                    onSeek?(Double(newProgress))
                }
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovering = hovering
                    }
                }
            }
            .frame(height: 20)
            
            // Time labels
            HStack {
                TimeLabel(
                    time: isDragging ? dragProgress * duration : progress * duration,
                    isProgressBarHovering: isHovering
                )
                
                Spacer()
                
                TimeLabel(
                    time: duration,
                    isProgressBarHovering: isHovering
                )
            }
        }
    }
    
    private struct TimeLabel: View {
        let time: TimeInterval
        let isProgressBarHovering: Bool
        @State private var isHovering = false
        
        var body: some View {
            Text(formatTime(time))
                .font(.caption)
                .foregroundStyle(isProgressBarHovering || isHovering ? .primary : .secondary)
                .opacity(isProgressBarHovering || isHovering ? 1 : 0.8)
                .scaleEffect(isHovering ? 1.1 : 1)
                .animation(
                    .spring(response: 0.3, dampingFraction: 0.7),
                    value: isProgressBarHovering || isHovering
                )
                .onHover { hovering in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isHovering = hovering
                    }
                }
        }
        
        private func formatTime(_ time: TimeInterval) -> String {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

#Preview("MagicProgressBar") {
    struct PreviewWrapper: View {
        @State private var progress: Double = 0.3
        
        var body: some View {
            HStack {
                VStack(spacing: 20) {
                    Text("Light Mode")
                        .font(.headline)
                    
                    MagicProgressBar(
                        progress: $progress,
                        duration: 240,
                        onSeek: { newProgress in
                            print("Seeked to: \(newProgress)")
                        }
                    )
                    .frame(width: 300)
                }
                .padding()
                .background(.background)
                .environment(\.colorScheme, .light)
                
                VStack(spacing: 20) {
                    Text("Dark Mode")
                        .font(.headline)
                    
                    MagicProgressBar(
                        progress: $progress,
                        duration: 240,
                        onSeek: { newProgress in
                            print("Seeked to: \(newProgress)")
                        }
                    )
                    .frame(width: 300)
                }
                .padding()
                .background(.background)
                .environment(\.colorScheme, .dark)
            }
            .previewLayout(.sizeThatFits)
        }
    }
    
    return PreviewWrapper()
} 