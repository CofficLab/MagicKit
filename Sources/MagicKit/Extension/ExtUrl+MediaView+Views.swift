import Combine
import SwiftUI
import OSLog

// MARK: - Media View Style
public enum MediaViewStyle {
    case none
    case background(AnyView)
}

// MARK: - Log View Style
public enum LogViewStyle {
    case sheet
    case popover
}

// MARK: - View Model
final class MediaFileViewModel: ObservableObject {
    @Published var isHovering = false
    
    let url: URL
    let verbose: Bool
    let size: String
    
    init(url: URL, verbose: Bool) {
        self.url = url
        self.verbose = verbose
        self.size = url.getSizeReadable()
    }
}

// MARK: - Background Modifier
struct MediaViewBackground: ViewModifier {
    let style: MediaViewStyle

    func body(content: Content) -> some View {
        Group {
            switch style {
            case .none:
                content
            case let .background(background):
                content
                    .background(background)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - Media File View
public struct MediaFileView: View, SuperLog {
    public static var emoji = "🖥️"
    
    @StateObject private var viewModel: MediaFileViewModel
    @State private var showLogSheet = false
    
    let url: URL
    var verbose: Bool
    var style: MediaViewStyle = .none
    var logStyle: LogViewStyle = .sheet
    var showActions: Bool = true
    var shape: AvatarViewShape = .circle
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
        self._viewModel = StateObject(wrappedValue: MediaFileViewModel(url: url, verbose: verbose))
    }

    public var body: some View {
        mainContent
            .modifier(FolderContentModifier(url: url, isVisible: folderContentVisible))
            .modifier(MediaViewBackground(style: style))
            .overlay(borderOverlay)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.isHovering = hovering
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
                        viewModel: viewModel
                    )
                }
                
                FileInfoSection(
                    url: url,
                    size: viewModel.size,
                    showFileSize: showFileSize,
                    showFileStatus: showFileStatus,
                    showBorder: showBorder
                )
                
                Spacer()
            }
            
            if showActions {
                ActionButtonsSection(
                    viewModel: viewModel,
                    url: url,
                    showDownloadButton: showDownloadButton,
                    showLogSheet: $showLogSheet,
                    horizontalPadding: horizontalPadding,
                    showBorder: showBorder
                )
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
    }
    
    var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 0)
            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
            .foregroundColor(showBorder ? .red : .clear)
    }
}

// MARK: - File Info Section
private struct FileInfoSection: View {
    let url: URL
    let size: String
    let showFileSize: Bool
    let showFileStatus: Bool
    let showBorder: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(url.lastPathComponent)
                .font(.headline)
                .lineLimit(1)
                .overlay(borderOverlay(.green))
            
            HStack {
                if showFileSize {
                    Text(size)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .overlay(borderOverlay(.green))
                }
                
                if showFileStatus, let status = url.magicFileStatus {
                    Text(status)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .overlay(borderOverlay(.green))
                }
            }
        }
        .overlay(borderOverlay(.purple))
    }
    
    private func borderOverlay(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 0)
            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
            .foregroundColor(showBorder ? color : .clear)
    }
}

// MARK: - Action Buttons Section
private struct ActionButtonsSection: View {
    @ObservedObject var viewModel: MediaFileViewModel
    let url: URL
    let showDownloadButton: Bool
    let showLogSheet: Binding<Bool>
    let horizontalPadding: CGFloat
    let showBorder: Bool
    
    var body: some View {
        ActionButtonsView(
            url: url,
            showDownloadButton: showDownloadButton,
            showLogSheet: showLogSheet
        )
        .opacity(viewModel.isHovering ? 1 : 0)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                .foregroundColor(showBorder ? .orange : .clear)
        )
        .padding(.trailing, horizontalPadding)
    }
}

// MARK: - Error Message View
struct ErrorMessageView: View {
    let error: Error
    @State private var isHovering = false

    var body: some View {
        Text(error.localizedDescription)
            .font(.caption)
            .foregroundStyle(.red)
            .lineLimit(1)
            .opacity(isHovering ? 0 : 1)
            .overlay {
                if isHovering {
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovering = hovering
                }
            }
    }
}

// MARK: - Log View Presentation Modifier
private struct LogViewPresentation<LogContent: View>: ViewModifier {
    let isPresented: Binding<Bool>
    let style: LogViewStyle
    let logContent: () -> LogContent
    
    init(isPresented: Binding<Bool>, style: LogViewStyle, content: @escaping () -> LogContent) {
        self.isPresented = isPresented
        self.style = style
        self.logContent = content
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: isPresented, content: {
                if style == .sheet {
                    logContent()
                }
            })
            .popover(isPresented: isPresented, content: {
                if style == .popover {
                    logContent()
                        .frame(width: 600, height: 400)
                }
            })
    }
}

#Preview("Media View") {
    MediaViewPreviewContainer().inMagicContainer()
}
