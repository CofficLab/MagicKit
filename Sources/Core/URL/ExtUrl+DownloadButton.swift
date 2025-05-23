import SwiftUI


struct DownloadButtonView: View, SuperLog {
    nonisolated static let emoji: String = "🐯"
    
    let url: URL
    let size: CGFloat
    let showLabel: Bool
    let shape: MagicButton.Shape
    let destination: URL?
    
    @State var isDownloading: Bool
    @State var progress: Double
    @State var error: Error?
    
    init(
        url: URL,
        size: CGFloat = 28,
        showLabel: Bool = false,
        shape: MagicButton.Shape = .circle,
        destination: URL? = nil,
        isDownloading: Bool = false,
        progress: Double = 0,
        error: Error? = nil
    ) {
        self.url = url
        self.size = size
        self.showLabel = showLabel
        self.shape = shape
        self.destination = destination
        self._isDownloading = State(initialValue: isDownloading)
        self._progress = State(initialValue: progress)
        self._error = State(initialValue: error)
    }
    
    private var buttonIcon: String {
        if url.isDownloaded {
            return .iconCheckmark
        } else if url.isiCloud {
            return .iconICloudDownloadAlt
        } else {
            return .iconDownload
        }
    }
    
    private var buttonStyle: MagicButton.Style {
        if url.isDownloaded {
            return .primary
        } else {
            return .secondary
        }
    }
    
    private var buttonLabel: String {
        if url.isDownloaded {
            return "已下载"
        } else if url.isiCloud {
            return "从 iCloud 下载"
        } else {
            return "下载"
        }
    }
    
    private var buttonDisabled: Bool {
        url.isDownloaded || (error != nil)
    }
    
    var body: some View {
        VStack {
            if isDownloading {
                ProgressView(value: progress, total: 100)
                    .progressViewStyle(.circular)
                    .frame(width: size * 0.8, height: size * 0.8)
                    .frame(width: size, height: size)
            } else {
                MagicButton(
                    icon: buttonIcon,
                    title: showLabel ? buttonLabel : nil,
                    style: buttonStyle,
                    size: size <= 32 ? .small : (size <= 40 ? .regular : .large),
                    shape: shape,
                    disabledReason: buttonDisabled ? buttonLabel : nil,
                    action: handleButtonTap
                )
                .symbolEffect(.bounce, value: url.isDownloaded)
            }
            
            if let error = error {
                Text(error.localizedDescription)
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .frame(maxWidth: 200)
                    .multilineTextAlignment(.center)
            }
        }
        .animation(.smooth, value: isDownloading)
        .animation(.smooth, value: error != nil)
    }
    
    private func handleButtonTap() {
        Task {
            isDownloading = true
            error = nil
            progress = 0
            
            do {
                if let destination = destination {
                    try await url.copyTo(destination, caller: self.className) { newProgress in
                        progress = newProgress
                    }
                } else {
                    try await url.download { newProgress in
                        progress = newProgress
                    }
                }
            } catch {
                self.error = error
            }
            
            isDownloading = false
        }
    }
}

#Preview {
    DownloadButtonPreview()
}
