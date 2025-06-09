import SwiftUI

/// 一个可自定义的加载状态视图组件
///
/// `MagicLoading` 提供了一个灵活的加载状态展示视图，支持显示进度指示器、自定义图标、文本标题或自定义视图。
/// 可以通过初始化参数或修改器方法来自定义视图的各个方面。
///
/// 基本使用示例：
/// ```swift
/// // 使用默认样式
/// MagicLoading()
///
/// // 使用自定义视图
/// MagicLoading {
///     Circle()
///         .fill(.blue)
///         .frame(width: 50, height: 50)
/// }
///
/// // 使用修改器
/// MagicLoading()
///     .magicTitle("同步中")
///     .magicCustomView {
///         ProgressView()
///             .scaleEffect(1.5)
///     }
/// ```
public struct MagicLoading<CustomContent: View>: View {
    // MARK: - Properties
    
    private var title: String
    private var image: String
    private var imageSize: CGFloat
    private var titleFont: Font
    private var spacing: CGFloat
    private var showProgress: Bool
    private var customContent: (() -> CustomContent)?
    
    // MARK: - Initialization
    
    /// 创建一个带有自定义内容的加载状态视图
    /// - Parameters:
    ///   - title: 显示的文本标题，默认为"加载中..."
    ///   - spacing: 各元素之间的间距，默认为 12 点
    ///   - showProgress: 是否显示进度指示器，默认为 true
    ///   - content: 自定义视图内容
    public init(
        title: String = "加载中...",
        spacing: CGFloat = 12,
        showProgress: Bool = true,
        @ViewBuilder content: @escaping () -> CustomContent
    ) {
        self.title = title
        self.image = ""
        self.imageSize = 0
        self.titleFont = .body
        self.spacing = spacing
        self.showProgress = showProgress
        self.customContent = content
    }
    
    /// 创建一个标准的加载状态视图
    /// - Parameters:
    ///   - title: 显示的文本标题，默认为"加载中..."
    ///   - image: SF Symbols 图标名称，默认为"arrow.2.circlepath"
    ///   - imageSize: 图标的大小，默认为 40 点
    ///   - titleFont: 标题文本的字体样式，默认为 .body
    ///   - spacing: 各元素之间的间距，默认为 12 点
    ///   - showProgress: 是否显示进度指示器，默认为 true
    public init(
        title: String = "加载中...",
        image: String = "arrow.2.circlepath",
        imageSize: CGFloat = 40,
        titleFont: Font = .body,
        spacing: CGFloat = 12,
        showProgress: Bool = true
    ) where CustomContent == EmptyView {
        self.title = title
        self.image = image
        self.imageSize = imageSize
        self.titleFont = titleFont
        self.spacing = spacing
        self.showProgress = showProgress
        self.customContent = nil
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: spacing) {
            if showProgress {
                ProgressView()
                    .controlSize(.regular)
            }
            
            if let customContent {
                customContent()
            } else if !image.isEmpty {
                Image(systemName: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize, height: imageSize)
            }
            
            Text(title)
                .font(titleFont)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Modifiers

public extension MagicLoading {
    /// 设置加载视图的标题文本
    /// - Parameter title: 要显示的标题文本
    /// - Returns: 更新后的加载视图
    func magicTitle(_ title: String) -> Self {
        var view = self
        view.title = title
        return view
    }
    
    /// 设置加载视图的图标
    /// - Parameter name: SF Symbols 图标名称
    /// - Returns: 更新后的加载视图
    func magicImage(_ name: String) -> Self {
        var view = self
        view.image = name
        return view
    }
    
    /// 设置图标的大小
    /// - Parameter size: 图标的宽度和高度（点）
    /// - Returns: 更新后的加载视图
    func magicImageSize(_ size: CGFloat) -> Self {
        var view = self
        view.imageSize = size
        return view
    }
    
    /// 设置标题文本的字体
    /// - Parameter font: 字体样式
    /// - Returns: 更新后的加载视图
    func magicTitleFont(_ font: Font) -> Self {
        var view = self
        view.titleFont = font
        return view
    }
    
    /// 设置视图元素之间的间距
    /// - Parameter spacing: 间距大小（点）
    /// - Returns: 更新后的加载视图
    func magicSpacing(_ spacing: CGFloat) -> Self {
        var view = self
        view.spacing = spacing
        return view
    }
    
    /// 控制是否显示进度指示器
    /// - Parameter show: 是否显示进度指示器
    /// - Returns: 更新后的加载视图
    func magicShowProgress(_ show: Bool) -> Self {
        var view = self
        view.showProgress = show
        return view
    }
    
    /// 设置自定义视图内容
    /// - Parameter content: 自定义视图构建器
    /// - Returns: 更新后的加载视图
    func magicCustomView<V: View>(@ViewBuilder _ content: @escaping () -> V) -> MagicLoading<V> {
        MagicLoading<V>(
            title: title,
            spacing: spacing,
            showProgress: showProgress,
            content: content
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        // 默认样式
        MagicLoading()
        
        // 自定义视图样式
        MagicLoading {
            Circle()
                .fill(.blue.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay {
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(.blue, lineWidth: 3)
                        .rotationEffect(.degrees(-90))
                }
        }
        
        // 使用修改器
        MagicLoading()
            .magicTitle("同步中")
            .magicCustomView {
                HStack {
                    Circle()
                        .fill(.green)
                        .frame(width: 12, height: 12)
                    Circle()
                        .fill(.yellow)
                        .frame(width: 12, height: 12)
                    Circle()
                        .fill(.red)
                        .frame(width: 12, height: 12)
                }
            }
        
        // 下载样式
        MagicLoading(
            title: "下载中...",
            image: "arrow.down.circle",
            imageSize: 45,
            titleFont: .callout
        )
        
        // 上传样式
        MagicLoading(
            title: "正在上传",
            image: "arrow.up.circle",
            imageSize: 45,
            titleFont: .callout,
            spacing: 16
        )
        
        // 刷新样式
        MagicLoading()
            .magicTitle("刷新中")
            .magicImage("arrow.clockwise.circle")
            .magicTitleFont(.subheadline)
            .magicSpacing(8)
    }
    .padding()
    .inMagicContainer()
}
