import AVKit
import SwiftUI
import MagicUI

// MARK: - Media View Style
public enum MediaViewStyle {
    case none
    case background(AnyView)
}

// MARK: - Media View Shape
public enum MediaViewShape {
    case circle
    case roundedRectangle(cornerRadius: CGFloat = 8)
    case rectangle
    
    @ViewBuilder
    func apply<V: View>(to view: V) -> some View {
        switch self {
        case .circle:
            view.clipShape(Circle())
        case .roundedRectangle(let radius):
            view.clipShape(RoundedRectangle(cornerRadius: radius))
        case .rectangle:
            view
        }
    }
    
    @ViewBuilder
    func strokeShape() -> some View {
        switch self {
        case .circle:
            Circle().stroke(Color.red, lineWidth: 2)
        case .roundedRectangle(let radius):
            RoundedRectangle(cornerRadius: radius).stroke(Color.red, lineWidth: 2)
        case .rectangle:
            Rectangle().stroke(Color.red, lineWidth: 2)
        }
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
            case .background(let background):
                content
                    .background(background)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - Error Message View
private struct ErrorMessageView: View {
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

// MARK: - Action Buttons View
private struct ActionButtonsView: View {
    let url: URL
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            url.makeOpenButton()
        }
        .padding(.trailing, 8)
    }
}

public struct MediaFileView: View {
    let url: URL
    let size: String
    fileprivate var style: MediaViewStyle = .none
    fileprivate var showActions: Bool = true
    fileprivate var shape: MediaViewShape = .circle
    fileprivate var verticalPadding: CGFloat = 12
    @State private var thumbnail: Image?
    @State private var error: Error?
    @State private var isLoading = false
    @State private var isHovering = false
    
    public init(url: URL, size: String) {
        self.url = url
        self.size = size
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // 左侧图片
            Group {
                if let thumbnail = thumbnail {
                    thumbnail
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else if error != nil {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 24))
                        .foregroundStyle(.red)
                } else {
                    Image(systemName: "doc")
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 40, height: 40)
            .background(.ultraThinMaterial)
            .apply(shape: shape)
            .overlay {
                if error != nil {
                    shape.strokeShape()
                }
            }
            
            // 右侧文件信息
            VStack(alignment: .leading, spacing: 4) {
                Text(url.lastPathComponent)
                    .font(.headline)
                    .lineLimit(1)
                
                if let error = error {
                    ErrorMessageView(error: error)
                } else {
                    Text(size)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // 操作按钮
            if showActions {
                ActionButtonsView(url: url)
                    .opacity(isHovering ? 1 : 0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, verticalPadding)
        .modifier(MediaViewBackground(style: style))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .task {
            // 异步加载缩略图
            if thumbnail == nil && !isLoading {
                isLoading = true
                do {
                    thumbnail = try await url.thumbnail(size: CGSize(width: 80, height: 80))
                    error = nil
                } catch {
                    self.error = error
                }
                isLoading = false
            }
        }
    }
    
    public func noBackground() -> MediaFileView {
        var view = self
        view.style = .none
        return view
    }
    
    public func withBackground<Background: View>(_ background: Background) -> MediaFileView {
        var view = self
        view.style = .background(AnyView(background))
        return view
    }
    
    public func hideActions() -> MediaFileView {
        var view = self
        view.showActions = false
        return view
    }
    
    public func thumbnailShape(_ shape: MediaViewShape) -> MediaFileView {
        var view = self
        view.shape = shape
        return view
    }
    
    public func verticalPadding(_ padding: CGFloat) -> MediaFileView {
        var view = self
        view.verticalPadding = padding
        return view
    }
}

// MARK: - View Extension
private extension View {
    func apply(shape: MediaViewShape) -> some View {
        shape.apply(to: self)
    }
}

public extension URL {
    func makeMediaView() -> MediaFileView {
        MediaFileView(url: self, size: self.getSizeReadable())
    }
}

#Preview("Media View") {
    MediaViewPreviewContainer()
}
