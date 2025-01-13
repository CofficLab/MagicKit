import SwiftUI

struct AvatarSection: View {
    let url: URL
    let verbose: Bool
    let avatarShape: AvatarViewShape
    let avatarSize: CGSize
    let avatarBackgroundColor: Color
    let monitorDownload: Bool
    let avatarProgressBinding: Binding<Double>?
    let showBorder: Bool
    let viewModel: MediaFileViewModel
    
    var body: some View {
        let avatarView = url.makeAvatarView(verbose: verbose)
            .magicSize(avatarSize)
            .magicAvatarShape(avatarShape)
            .magicBackground(avatarBackgroundColor)
            .magicDownloadMonitor(monitorDownload)
            .magicContextMenu(false)
            .onLog { message, level in
                MagicLogger.log(message, level: level)
            }
        
        let finalAvatarView = if let progress = avatarProgressBinding {
            avatarView.magicDownloadProgress(progress)
        } else {
            avatarView
        }
        
        finalAvatarView
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                    .foregroundColor(showBorder ? .blue : .clear)
            )
    }
}

#Preview {
    AvatarSection(
        url: URL(string: "https://example.com")!,
        verbose: true,
        avatarShape: .circle,
        avatarSize: CGSize(width: 40, height: 40),
        avatarBackgroundColor: .blue.opacity(0.1),
        monitorDownload: true,
        avatarProgressBinding: .constant(0.5),
        showBorder: true,
        viewModel: MediaFileViewModel(url: URL(string: "https://example.com")!, verbose: true)
    )
}
