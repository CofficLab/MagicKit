import SwiftUI

public struct MagicProgressBar: View {
    @Binding var currentTime: TimeInterval
    @State private var isDragging = false
    @State private var dragTime: TimeInterval
    @State private var isHovering = false
    @Environment(\.colorScheme) private var colorScheme
    
    let duration: TimeInterval
    let onSeek: ((TimeInterval) -> Void)?
    
    public init(
        currentTime: Binding<TimeInterval>,
        duration: TimeInterval,
        onSeek: ((TimeInterval) -> Void)? = nil
    ) {
        self._currentTime = currentTime
        self._dragTime = State(initialValue: currentTime.wrappedValue)
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
                        .frame(width: geometry.size.width * progress, height: 4)
                    
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
                        .offset(x: geometry.size.width * progress - (isHovering ? 8 : 6))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    isDragging = true
                                    let newTime = min(max(0, value.location.x / geometry.size.width), 1) * duration
                                    withAnimation(.linear(duration: 0.1)) {
                                        dragTime = newTime
                                    }
                                }
                                .onEnded { value in
                                    isDragging = false
                                    let finalTime = min(max(0, value.location.x / geometry.size.width), 1) * duration
                                    currentTime = finalTime
                                    dragTime = currentTime
                                    onSeek?(finalTime)
                                }
                        )
                }
                .contentShape(Rectangle())
                .onTapGesture { location in
                    let newTime = min(max(0, location.x / geometry.size.width), 1) * duration
                    currentTime = newTime
                    dragTime = currentTime
                    onSeek?(newTime)
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
                    time: isDragging ? dragTime : currentTime,
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
    
    private var progress: CGFloat {
        let time = isDragging ? dragTime : currentTime
        return duration > 0 ? CGFloat(time / duration) : 0
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

#Preview("MagicProgressBar") {
    struct PreviewWrapper: View {
        @State private var currentTime: TimeInterval = 72
        let duration: TimeInterval = 240
        
        var body: some View {
            HStack {
                VStack(spacing: 20) {
                    Text("Light Mode")
                        .font(.headline)
                    
                    MagicProgressBar(
                        currentTime: $currentTime,
                        duration: duration,
                        onSeek: { newTime in
                            print("Seeked to: \(newTime)")
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
                        currentTime: $currentTime,
                        duration: duration,
                        onSeek: { newTime in
                            print("Seeked to: \(newTime)")
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