import SwiftUI
import OSLog

// MARK: - Media File View
public struct MediaFileView: View, SuperLog {
    public static var emoji = "🖥️"
    
    @State private var isHovering = false
    @State private var showLogSheet = false
    
    let url: URL
    var verbose: Bool
    var style: MediaViewStyle = .none
    var logStyle: LogViewStyle = .sheet
    var showActions: Bool = true
    var avatarShape: AvatarViewShape = .circle
    var avatarBackgroundColor: Color = .blue.opacity(0.1)
    var avatarSize: CGSize = CGSize(width: 40, height: 40)
    var verticalPadding: CGFloat = 12
    var horizontalPadding: CGFloat = 16
    var monitorDownload: Bool = true
    var folderContentVisible: Bool = false
    var avatarProgressBinding: Binding<Double>? = nil
    var showBorder: Bool = false
    var showDownloadButton: Bool = true
    var showFileInfo: Bool = true
    var showFileStatus: Bool = true
    var showFileSize: Bool = true
    var showAvatar: Bool = true
    var showLogButton: Bool = true

    public init(url: URL, verbose: Bool) {
        self.url = url
        self.verbose = verbose
    }

    public var body: some View {
        mainContent
            .modifier(FolderContentModifier(url: url, isVisible: folderContentVisible))
            .modifier(MediaViewBackground(style: style))
            .overlay(borderOverlay)
            .conditionalHover(isEnabled: showActions) { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovering = hovering
                    if verbose {
                        os_log("\(self.t)悬停状态变更: \(hovering)")
                    }
                }
            }
    }
}

// MARK: - MediaFileView Extensions
private extension MediaFileView {
    var mainContent: some View {
        VStack(spacing: 0) {
            contentStack
        }
        .modifier(LogViewPresentation(
            isPresented: $showLogSheet,
            style: logStyle,
            content: {
                MagicLogger.logView(
                    title: "MediaFileView Logs",
                    onClose: { showLogSheet = false }
                )
            }
        ))
    }
    
    var contentStack: some View {
        ZStack(alignment: .trailing) {
            HStack(alignment: .center, spacing: 12) {
                if showAvatar {
                    AvatarSection(
                        url: url,
                        verbose: verbose,
                        avatarShape: avatarShape,
                        avatarSize: avatarSize,
                        avatarBackgroundColor: avatarBackgroundColor,
                        monitorDownload: monitorDownload,
                        avatarProgressBinding: avatarProgressBinding,
                        showBorder: showBorder,
                        isHovering: isHovering
                    )
                }
                
                FileInfoSection(
                    url: url,
                    showFileSize: showFileSize,
                    showFileStatus: showFileStatus,
                    showBorder: showBorder
                )
                
                Spacer()
            }
            
            if showActions {
                ActionButtonsSection(
                    url: url,
                    showDownloadButton: showDownloadButton,
                    showLogSheet: $showLogSheet,
                    horizontalPadding: horizontalPadding,
                    showBorder: showBorder,
                    isHovering: isHovering
                )
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .onChange(of: showLogSheet) { newValue in
            if verbose {
                os_log("\(self.t)日志表单显示状态: \(newValue)")
            }
        }
    }
    
    var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 0)
            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
            .foregroundColor(showBorder ? .red : .clear)
    }
}

#Preview("Media View") {
    MediaViewPreviewContainer().inMagicContainer()
}
