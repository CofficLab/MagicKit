import AVKit
import SwiftUI
import MagicUI

// MARK: - View Extension

private extension View {
    func `let`<T>(_ modify: (Self) -> T) -> T {
        modify(self)
    }
}

public extension URL {
    /// 创建一个异步加载的媒体预览视图
    /// - Parameters:
    ///   - size: 预览图大小
    ///   - shape: 预览图形状
    ///   - showTitle: 是否显示标题
    ///   - showType: 是否显示类型图标
    /// - Returns: 预览视图
    ///
    /// 支持以下背景样式设置：
    /// ```swift
    /// // 移除背景
    /// url.makePreviewView().noBackground()
    /// 
    /// // 自定义背景颜色
    /// url.makePreviewView().withBackground(.blue)
    /// ```
    func makePreviewView(
        size: CGSize = CGSize(width: 120, height: 120),
        shape: PreviewShape = .square,
        showTitle: Bool = true,
        showType: Bool = true
    ) -> some View {
        MediaPreviewView(
            url: self,
            size: size,
            shape: shape,
            showTitle: showTitle,
            showType: showType
        )
    }
}

// MARK: - Preview Shape

public enum PreviewShape: Equatable, Hashable {
    case square
    case circle
    case roundedSquare(radius: CGFloat = 8)
    case rectangle

    var shape: AnyShape {
        switch self {
        case .square:
            Rectangle().anyShape
        case .circle:
            Circle().anyShape
        case let .roundedSquare(radius):
            RoundedRectangle(cornerRadius: radius).anyShape
        case .rectangle:
            RoundedRectangle(cornerRadius: 8).anyShape
        }
    }

    var isRectangle: Bool {
        if case .rectangle = self {
            return true
        }
        return false
    }

    func apply<V: View>(to view: V) -> some View {
        view.clipShape(shape)
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .square:
            hasher.combine(0)
        case .circle:
            hasher.combine(1)
        case .roundedSquare(let radius):
            hasher.combine(2)
            hasher.combine(radius)
        case .rectangle:
            hasher.combine(3)
        }
    }
}

private extension Shape {
    var anyShape: AnyShape {
        AnyShape(self)
    }
}

// MARK: - Media Preview View

private struct MediaPreviewView: View {
    let url: URL
    let size: CGSize
    let shape: PreviewShape
    let showTitle: Bool
    let showType: Bool

    @State private var thumbnail: Image?
    @State private var error: Error?
    @State private var isLoading = true
    @State private var fileSize: String = ""
    @State private var downloadProgress: Double = 0
    @State private var isDownloading = false
    @State private var showErrorDetails = false

    var body: some View {
        Group {
            if shape.isRectangle {
                // 长方形布局（文件预览样式）
                HStack(spacing: 12) {
                    // 左侧缩略图
                    ZStack {
                        shape.shape
                            .foregroundStyle(.background)
                            .shadow(radius: 1)
                            .frame(width: size.width * 0.4, height: size.height * 0.4)

                        thumbnailContent
                            .frame(width: size.width * 0.4, height: size.height * 0.4)
                            .let { shape.apply(to: $0) }
                        
                        // 下载进度
                        if isDownloading {
                            ProgressView(value: downloadProgress, total: 100)
                                .progressViewStyle(.circular)
                                .scaleEffect(0.6)
                                .tint(.white)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }

                    // 右侧信息
                    VStack(alignment: .leading, spacing: 4) {
                        Text(url.lastPathComponent)
                            .font(.subheadline)
                            .lineLimit(1)
                            .truncationMode(.middle)

                        if isDownloading {
                            Text("Downloading \(Int(downloadProgress))%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(fileSize)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: size.height * 0.5)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.background.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .modifier(PreviewBackgroundModifier(isEnabled: true, style: nil))
            } else {
                // 原有的方形/圆形布局
                VStack(spacing: 8) {
                    ZStack {
                        shape.shape
                            .foregroundStyle(.background)
                            .shadow(radius: 2)

                        thumbnailContent
                            .frame(width: size.width, height: size.height)
                            .let { shape.apply(to: $0) }

                        if showType {
                            VStack {
                                HStack {
                                    Spacer()
                                    TypeBadge(url: url)
                                }
                                Spacer()
                            }
                            .padding(8)
                        }

                        // 下载进度
                        if isDownloading {
                            ProgressView(value: downloadProgress, total: 100)
                                .progressViewStyle(.circular)
                                .scaleEffect(0.8)
                                .tint(.white)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }

                    if showTitle {
                        Text(url.lastPathComponent)
                            .font(.caption)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                .frame(width: size.width)
            }
        }
        .task {
            await loadPreview()
            if url.isiCloud && url.isNotDownloaded {
                await downloadFile()
            }
        }
    }

    @ViewBuilder
    private var thumbnailContent: some View {
        Group {
            if let thumbnail = thumbnail {
                thumbnail
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if let error = error {
                ErrorIconView(error: error, showDetails: $showErrorDetails)
            } else if isLoading {
                ProgressView()
            }
        }
    }

    private func loadPreview() async {
        isLoading = true
        defer { isLoading = false }

        do {
            thumbnail = try await url.thumbnail(size: size)
        } catch {
            self.error = error
        }

        if shape.isRectangle {
            fileSize = url.getSizeReadable()
        }
    }

    private func downloadFile() async {
        isDownloading = true
        defer { isDownloading = false }
        
        do {
            try await url.download { progress in
                downloadProgress = progress * 100
            }
        } catch {
            self.error = error
        }
    }
}

// MARK: - Type Badge

private struct TypeBadge: View {
    let url: URL

    var body: some View {
        Image(systemName: url.icon)
            .font(.caption)
            .padding(4)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
    }
}

public extension PreviewShape {
    /// 文件预览样式：左侧缩略图，右侧信息
    static var file: PreviewShape { .roundedSquare(radius: 6) }
}

public extension URL {
    /// 创建一个文件预览视图
    /// - Returns: 文件预览视图
    func makeFilePreviewView() -> some View {
        FilePreviewView(url: self)
    }
}

// MARK: - File Preview View

private struct FilePreviewView: View {
    let url: URL

    @State private var thumbnail: Image?
    @State private var error: Error?
    @State private var isLoading = true
    @State private var fileSize: String = ""

    var body: some View {
        HStack(spacing: 12) {
            // 左侧缩略图
            ZStack {
                PreviewShape.file.shape
                    .foregroundStyle(.background)
                    .shadow(radius: 1)

                Group {
                    if let thumbnail = thumbnail {
                        thumbnail
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else if error != nil {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title2)
                            .foregroundStyle(.red)
                    } else if isLoading {
                        ProgressView()
                    }
                }
                .frame(width: 60, height: 60)
                .let { PreviewShape.file.apply(to: $0) }
            }

            // 右侧信息
            VStack(alignment: .leading, spacing: 4) {
                Text(url.lastPathComponent)
                    .font(.subheadline)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Text(fileSize)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.background.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .task {
            await loadPreview()
        }
    }

    private func loadPreview() async {
        isLoading = true
        defer { isLoading = false }

        // 加载缩略图
        do {
            thumbnail = try await url.thumbnail(size: CGSize(width: 120, height: 120))
        } catch {
            self.error = error
        }

        // 获取文件大小
        fileSize = url.getSizeReadable()
    }
}

// MARK: - Error Icon View

private struct ErrorIconView: View {
    let error: Error
    @Binding var showDetails: Bool
    
    var body: some View {
        Button {
            showDetails.toggle()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title2)
                    .foregroundStyle(.red)
            }
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showDetails) {
            ErrorDetailsView(error: error)
        }
    }
}

private struct ErrorDetailsView: View {
    let error: Error
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.red)
                Text("Error Details")
                    .font(.headline)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Group {
                        let nsError = error as NSError
                        Text("Domain: \(nsError.domain)")
                        Text("Code: \(nsError.code)")
                        if let reason = nsError.localizedFailureReason {
                            Text("Reason: \(reason)")
                        }
                        if let suggestion = nsError.localizedRecoverySuggestion {
                            Text("Suggestion: \(suggestion)")
                        }
                        Text("Description: \(error.localizedDescription)")
                    }
                    .textSelection(.enabled)
                }
            }
        }
        .padding()
        .frame(width: 300, height: 200)
    }
}

// MARK: - Background Modifier

private struct PreviewBackgroundModifier: ViewModifier {
    let isEnabled: Bool
    let style: Color?
    
    func body(content: Content) -> some View {
        if isEnabled {
            if let style = style {
                content.background(style.opacity(0.5))
            } else {
                content.background(.background.opacity(0.5))
            }
        } else {
            content
        }
    }
}

public extension View {
    /// 移除预览视图的背景
    func noBackground() -> some View {
        modifier(PreviewBackgroundModifier(isEnabled: false, style: nil))
    }
    
    /// 设置预览视图的背景颜色
    /// - Parameter color: 背景颜色
    func withBackground(_ color: Color) -> some View {
        modifier(PreviewBackgroundModifier(isEnabled: true, style: color))
    }
}

// MARK: - Preview

#Preview("Media Preview") {
    struct PreviewState {
        var showTitle = true
        var showType = true
        var backgroundColor: Color? = nil
        var shape: PreviewShape = .square
    }
    
    struct PreviewContainer: View {
        @State private var state = PreviewState()
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    // 预览形状展示
                    Group {
                        Text("预览形状").font(.headline)
                        HStack(spacing: 20) {
                            ForEach([
                                URL.sample_jpg_earth,
                                URL.sample_jpg_mars,
                                URL.sample_jpg_jupiter
                            ], id: \.self) { url in
                                url.makePreviewView(
                                    shape: state.shape,
                                    showTitle: state.showTitle,
                                    showType: state.showType
                                )
                                .modifier(PreviewBackgroundModifier(
                                    isEnabled: state.backgroundColor != nil,
                                    style: state.backgroundColor
                                ))
                            }
                        }
                    }
                    
                    // 图片预览
                    Group {
                        Text("图片预览").font(.headline)
                        HStack(spacing: 20) {
                            URL.sample_jpg_earth.makePreviewView()
                                .withBackground(.blue.opacity(0.1))
                            URL.sample_jpg_mars.makePreviewView()
                                .withBackground(.red.opacity(0.1))
                            URL.sample_png_transparency.makePreviewView()
                                .withBackground(.green.opacity(0.1))
                        }
                    }
                    
                    // 音频预览
                    Group {
                        Text("音频预览").font(.headline)
                        HStack(spacing: 20) {
                            URL.sample_mp3_kennedy.makePreviewView()
                                .withBackground(.yellow.opacity(0.1))
                            URL.sample_mp3_apollo.makePreviewView()
                                .withBackground(.orange.opacity(0.1))
                            URL.sample_wav_mars.makePreviewView()
                                .withBackground(.purple.opacity(0.1))
                        }
                    }
                    
                    // 视频预览
                    Group {
                        Text("视频预览").font(.headline)
                        HStack(spacing: 20) {
                            URL.sample_mp4_bunny.makePreviewView()
                                .withBackground(.cyan.opacity(0.1))
                            URL.sample_mp4_sintel.makePreviewView()
                                .withBackground(.mint.opacity(0.1))
                            URL.sample_mp4_elephants.makePreviewView()
                                .withBackground(.indigo.opacity(0.1))
                        }
                    }
                    
                    // 文件预览
                    Group {
                        Text("文件预览样式").font(.headline)
                        VStack(spacing: 12) {
                            URL.sample_pdf_swift_guide.makePreviewView(shape: .file)
                                .withBackground(.gray.opacity(0.1))
                            URL.sample_txt_mit.makePreviewView(shape: .file)
                                .withBackground(.brown.opacity(0.1))
                        }
                    }
                    
                    // 临时文件预览
                    Group {
                        Text("临时文件预览").font(.headline)
                        HStack(spacing: 20) {
                            URL.sample_temp_jpg.makePreviewView()
                                .withBackground(.teal.opacity(0.1))
                            URL.sample_temp_mp3.makePreviewView()
                                .withBackground(.pink.opacity(0.1))
                            URL.sample_temp_txt.makePreviewView(shape: .file)
                                .withBackground(.gray.opacity(0.1))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .toolbar {
                #if os(macOS)
                ToolbarItemGroup(placement: .automatic) {
                    toolbarContent
                }
                #else
                ToolbarItemGroup(placement: .bottomBar) {
                    toolbarContent
                }
                #endif
            }
        }
        
        @ViewBuilder
        private var toolbarContent: some View {
            Toggle("显示标题", isOn: $state.showTitle)
            Toggle("显示类型", isOn: $state.showType)
            
            Divider()
            
            Picker("形状", selection: $state.shape) {
                Image(systemName: "square.fill")
                    .tag(PreviewShape.square)
                Image(systemName: "circle.fill")
                    .tag(PreviewShape.circle)
                Image(systemName: "square.fill")
                    .tag(PreviewShape.roundedSquare(radius: 8))
            }
            .pickerStyle(.segmented)
            
            Divider()
            
            Menu {
                Button("无背景") {
                    state.backgroundColor = nil
                }
                Button("蓝色") {
                    state.backgroundColor = .blue.opacity(0.1)
                }
                Button("红色") {
                    state.backgroundColor = .red.opacity(0.1)
                }
                Button("绿色") {
                    state.backgroundColor = .green.opacity(0.1)
                }
            } label: {
                Image(systemName: "paintpalette")
            }
        }
    }
    
    return PreviewContainer()
        .frame(width: 600, height: 800)
        .background(MagicBackground.mint)
}
