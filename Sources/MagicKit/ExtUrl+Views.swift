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

public enum PreviewShape: Equatable {
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
        Image(systemName: icon)
            .font(.caption)
            .padding(4)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
    }

    private var icon: String {
        if url.isAudio {
            return "music.note"
        } else if url.isVideo {
            return "film"
        } else if url.isImage {
            return "photo"
        } else if url.isDirectory {
            return "folder"
        } else {
            return "doc"
        }
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

// MARK: - Preview

#Preview("URL Views") {
    PreviewDemoView()
}

private struct PreviewDemoView: View {
    @State private var selectedShape: PreviewShape = .rectangle
    @State private var selectedSize: CGSize = .init(width: 120, height: 120)
    
    private let previewURLs: [(String, URL)] = [
        // 音频文件
        ("iCloud Audio", URL(string: "file:///iCloud/test.mp3")!),
        ("Remote Audio", URL(string: "https://storage.googleapis.com/media-session/sintel/snow-fight.mp3")!),
        ("Local Audio", URL(string: "file:///music.mp3")!),
        
        // 视频文件
        ("Remote Video", URL(string: "https://media.w3.org/2010/05/sintel/trailer.mp4")!),
        ("Sample Video", URL(string: "https://download.samplelib.com/mp4/sample-5s.mp4")!),
        ("Local Video", URL(string: "file:///movie.mp4")!),
        
        // 图片文件
        ("Sample Image", URL(string: "https://picsum.photos/200")!),
        ("Nature Image", URL(string: "https://source.unsplash.com/random/200x200/?nature")!),
        ("Local Image", URL(string: "file:///photo.jpg")!),
        
        // 文档和文件夹
        ("Local Folder", URL.documentsDirectory),
        ("PDF Document", URL(string: "file:///document.pdf")!),
        ("Text File", URL(string: "file:///notes.txt")!)
    ]
    
    private let shapes: [(String, PreviewShape)] = [
        ("Rectangle", .rectangle),
        ("Square", .square),
        ("Circle", .circle),
        ("Rounded", .roundedSquare())
    ]
    
    private let sizes: [(String, CGSize)] = [
        ("Small", CGSize(width: 80, height: 80)),
        ("Medium", CGSize(width: 120, height: 120)),
        ("Large", CGSize(width: 160, height: 160))
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                shapeSelector
                sizeSelector
                previewList
            }
            .padding()
        }
        .frame(width: 600, height: 800)
    }
    
    // 样式选择器
    private var shapeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(shapes, id: \.0) { name, shape in
                    shapeButton(name: name, shape: shape)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // 样式按钮
    private func shapeButton(name: String, shape: PreviewShape) -> some View {
        MagicButton(
            icon: iconForShape(shape),
            title: name,
            style: selectedShape == shape ? .primary : .secondary,
            size: .small,
            shape: .capsule,
            action: { selectedShape = shape }
        )
    }
    
    // 为每种形状选择合适的图标
    private func iconForShape(_ shape: PreviewShape) -> String {
        switch shape {
        case .rectangle:
            return "rectangle"
        case .square:
            return "square"
        case .circle:
            return "circle"
        case .roundedSquare:
            return "square.fill.on.square"
        }
    }
    
    // 新增尺寸选择器
    private var sizeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(sizes, id: \.0) { name, size in
                    sizeButton(name: name, size: size)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // 新增尺寸按钮
    private func sizeButton(name: String, size: CGSize) -> some View {
        MagicButton(
            icon: "rectangle.compress.vertical",
            title: name,
            style: selectedSize == size ? .primary : .secondary,
            size: .small,
            shape: .capsule,
            action: { selectedSize = size }
        )
    }
    
    // 预览列表
    private var previewList: some View {
        ForEach(previewURLs, id: \.0) { name, url in
            previewItem(name: name, url: url)
        }
    }
    
    // 预览项
    private func previewItem(name: String, url: URL) -> some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.caption)
                .foregroundStyle(.secondary)
            url.makePreviewView(size: selectedSize, shape: selectedShape)
        }
    }
}
