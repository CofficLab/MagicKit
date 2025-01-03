import AVKit
import SwiftUI
import MagicUI

// MARK: - Media View Style
/// 媒体视图的背景样式
public enum MediaViewStyle {
    /// 无背景
    case none
    /// 自定义背景视图
    case background(AnyView)
}

// MARK: - Media View Shape
/// 媒体视图左侧缩略图的形状
public enum MediaViewShape {
    /// 圆形
    case circle
    /// 圆角矩形，可指定圆角半径
    case roundedRectangle(cornerRadius: CGFloat = 8)
    /// 矩形
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

// MARK: - Media File View
/// 用于显示文件信息的视图组件
/// 
/// 这个视图组件可以显示文件的缩略图、名称、大小等信息，并提供文件操作功能。
/// 支持以下特性：
/// - 自动生成文件缩略图
/// - 显示文件大小
/// - 错误状态展示
/// - 悬停时显示操作按钮
/// - 可自定义背景样式
/// - 可自定义缩略图形状
/// - 可调整垂直内边距
///
/// 基本用法：
/// ```swift
/// let url = URL(fileURLWithPath: "path/to/file")
/// url.makeMediaView()
/// ```
///
/// 自定义样式：
/// ```swift
/// url.makeMediaView()
///     .withBackground(MagicBackground.mint)
///     .thumbnailShape(.roundedRectangle(cornerRadius: 8))
///     .verticalPadding(16)
/// ```
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
    
    /// 创建媒体文件视图
    /// - Parameters:
    ///   - url: 文件的 URL
    ///   - size: 文件大小的字符串表示
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
    
    /// 移除背景样式
    /// - Returns: 无背景样式的视图
    public func noBackground() -> MediaFileView {
        var view = self
        view.style = .none
        return view
    }
    
    /// 添加自定义背景
    /// - Parameter background: 背景视图
    /// - Returns: 带有指定背景的视图
    public func withBackground<Background: View>(_ background: Background) -> MediaFileView {
        var view = self
        view.style = .background(AnyView(background))
        return view
    }
    
    /// 隐藏操作按钮
    /// - Returns: 不显示操作按钮的视图
    public func hideActions() -> MediaFileView {
        var view = self
        view.showActions = false
        return view
    }
    
    /// 设置缩略图形状
    /// - Parameter shape: 要应用的形状
    /// - Returns: 使用指定形状的视图
    public func thumbnailShape(_ shape: MediaViewShape) -> MediaFileView {
        var view = self
        view.shape = shape
        return view
    }
    
    /// 设置垂直内边距
    /// - Parameter padding: 内边距大小（点）
    /// - Returns: 使用指定内边距的视图
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

// MARK: - URL Extension
public extension URL {
    /// 为 URL 创建媒体文件视图
    /// - Returns: 展示该 URL 对应文件信息的视图
    ///
    /// 这个方法会自动：
    /// - 获取文件大小
    /// - 生成缩略图（如果是媒体文件）
    /// - 处理错误状态
    ///
    /// 示例：
    /// ```swift
    /// // 基本使用
    /// url.makeMediaView()
    ///
    /// // 带背景
    /// url.makeMediaView()
    ///     .withBackground(MagicBackground.mint)
    ///
    /// // 自定义形状和内边距
    /// url.makeMediaView()
    ///     .thumbnailShape(.roundedRectangle(cornerRadius: 8))
    ///     .verticalPadding(16)
    /// ```
    func makeMediaView() -> MediaFileView {
        MediaFileView(url: self, size: self.getSizeReadable())
    }
}

#Preview("Media View") {
    MediaViewPreviewContainer()
}
