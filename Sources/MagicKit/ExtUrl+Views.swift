import AVKit
import SwiftUI

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

public enum PreviewShape {
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
                            .frame(width: 60, height: 60)

                        thumbnailContent
                            .frame(width: 60, height: 60)
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
                VStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                    if !shape.isRectangle {
                        Text(error.localizedDescription)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                    }
                }
                .foregroundStyle(.red)
                .padding(8)
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

// MARK: - Preview

#Preview("URL Views") {
    ScrollView {
        VStack(spacing: 20) {
            // iCloud 文件预览
            URL(string: "file:///iCloud/test.mp3")!
                .makePreviewView(shape: .rectangle)
            
            URL(string: "https://storage.googleapis.com/media-session/sintel/snow-fight.mp3")!.makePreviewView(shape: .rectangle)
            
            // 长方形预览（文件样式）
            URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/fd/37/41/fd374113-bf05-692f-e157-5c364af08d9d/mzaf_15384825730917775750.plus.aac.p.m4a")!
                .makePreviewView(shape: .rectangle)

            // 方形预览
            URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
                .makePreviewView(shape: .square)

            // 圆形预览
            URL(string: "https://picsum.photos/200")!
                .makePreviewView(shape: .circle)

            // 圆角方形预览
            URL.documentsDirectory
                .makePreviewView(shape: .roundedSquare())
        }
        .padding()
    }
    .frame(width: 600)
    .frame(height: 800)
}
