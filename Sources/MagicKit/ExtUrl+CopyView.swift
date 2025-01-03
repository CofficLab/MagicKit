import SwiftUI
import Foundation

// MARK: - URL Extension
public extension URL {
    /// 创建一个文件复制进度视图
    /// - Parameters:
    ///   - destination: 目标位置（可以是文件夹或具体文件路径）
    ///   - onCompletion: 复制完成后的回调，参数为可选的错误信息
    /// - Returns: 文件复制进度视图
    func copyView(
        destination: URL,
        onCompletion: @escaping (Error?) async -> Void = { _ in }
    ) -> some View {
        FileCopyProgressView(
            source: self,
            destination: destination,
            onCompletion: onCompletion
        )
    }
}

// MARK: - Style Configuration
public enum CopyViewShape {
    case roundedRectangle
    case rectangle
    case capsule
}

fileprivate struct CopyViewStyle {
    var background: Color = .white
    var backgroundOpacity: Double = 0.8
    var shape: CopyViewShape = .roundedRectangle
    var cornerRadius: CGFloat = 12
    var shadowRadius: CGFloat = 2
}

// MARK: - Environment
fileprivate struct CopyViewStyleKey: EnvironmentKey {
    static let defaultValue = CopyViewStyle()
}

extension EnvironmentValues {
    fileprivate var copyViewStyle: CopyViewStyle {
        get { self[CopyViewStyleKey.self] }
        set { self[CopyViewStyleKey.self] = newValue }
    }
}

// MARK: - Style Modifiers
extension View {
    /// 设置复制视图的背景色
    public func withBackground(_ color: Color = .white, opacity: Double = 0.8) -> some View {
        transformEnvironment(\.copyViewStyle) { style in
            style.background = color
            style.backgroundOpacity = opacity
        }
    }
    
    /// 设置复制视图的形状
    public func withShape(_ shape: CopyViewShape, cornerRadius: CGFloat = 12) -> some View {
        transformEnvironment(\.copyViewStyle) { style in
            style.shape = shape
            style.cornerRadius = cornerRadius
        }
    }
    
    /// 设置复制视图的阴影
    public func withShadow(radius: CGFloat = 2) -> some View {
        transformEnvironment(\.copyViewStyle) { style in
            style.shadowRadius = radius
        }
    }
}

// MARK: - Helper Views and Modifiers
private struct ShapeModifier: ViewModifier {
    let style: CopyViewStyle
    
    func body(content: Content) -> some View {
        switch style.shape {
        case .roundedRectangle:
            content.clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
        case .rectangle:
            content.clipShape(Rectangle())
        case .capsule:
            content.clipShape(Capsule())
        }
    }
}

private struct FileInfoView: View {
    let url: URL
    let thumbnail: Image?
    
    var body: some View {
        HStack(spacing: 16) {
            // 缩略图
            Group {
                if let thumbnail = thumbnail {
                    thumbnail
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: url.isDirectory ? "folder" : "doc")
                        .font(.title)
                }
            }
            .frame(width: 40, height: 40)
            
            // 文件信息
            VStack(alignment: .leading, spacing: 4) {
                Text(url.lastPathComponent)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(url.getSizeReadable())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ProgressIndicatorView: View {
    let progress: Double
    let message: String
    
    var body: some View {
        VStack(spacing: 4) {
            ProgressView(value: progress, total: 100)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Main View
private struct FileCopyProgressView: View {
    let source: URL
    let destination: URL
    let onCompletion: (Error?) async -> Void
    
    @State private var downloadProgress: Double = 0
    @State private var copyProgress: Double = 0
    @State private var error: Error?
    @State private var isCompleted = false
    @State private var isCopying = false
    @State private var thumbnail: Image?
    @State private var showCopiedTip = false
    
    @Environment(\.copyViewStyle) private var style
    
    private var finalDestination: URL {
        destination.hasDirectoryPath ? 
            destination.appendingPathComponent(source.lastPathComponent) : 
            destination
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                FileInfoView(url: source, thumbnail: thumbnail)
                
                if source.isiCloud && source.isNotDownloaded {
                    ProgressIndicatorView(
                        progress: downloadProgress,
                        message: "正在从 iCloud 下载..."
                    )
                }
                
                if isCopying {
                    ProgressIndicatorView(
                        progress: copyProgress,
                        message: "正在复制到: \(finalDestination.lastPathComponent)"
                    )
                }
                
                if let error {
                    ErrorView(error: error, showCopiedTip: $showCopiedTip)
                }
                
                if isCompleted {
                    Label("复制完成", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            .padding()
            .background(style.background.opacity(style.backgroundOpacity))
            .modifier(ShapeModifier(style: style))
            .shadow(radius: style.shadowRadius)
            
            if showCopiedTip {
                ToastView(message: "错误信息已复制到剪贴板")
            }
        }
        .task {
            await performCopyOperation()
        }
    }
    
    private func performCopyOperation() async {
        // 加载缩略图
        thumbnail = try? await source.thumbnail(size: CGSize(width: 80, height: 80))
        
        do {
            // 如果是 iCloud 文件，先下载
            if source.isiCloud && source.isNotDownloaded {
                try await source.download { progress in
                    downloadProgress = progress * 100
                }
            }
            
            // 开始复制
            isCopying = true
            try await copyWithProgress()
            isCompleted = true
            await onCompletion(nil)
            
        } catch {
            self.error = error
            await onCompletion(error)
        }
    }
    
    private func copyWithProgress() async throws {
        let sourceSize = source.getSize()
        let fileManager = FileManager.default
        
        // 如果目标是文件夹，确保文件夹存在
        if destination.hasDirectoryPath {
            try? fileManager.createDirectory(at: destination, withIntermediateDirectories: true)
        }
        
        // 如果目标文件已存在，先删除
        if finalDestination.isFileExist {
            try finalDestination.delete()
        }
        
        // 执行复制
        try fileManager.copyItem(at: source, to: finalDestination)
        copyProgress = 100
    }
}

// MARK: - Supporting Views
private struct ErrorView: View {
    let error: Error
    @Binding var showCopiedTip: Bool
    
    var body: some View {
        HStack {
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.red)
            
            Spacer()
            
            Button {
                error.localizedDescription.copy()
                showCopiedTip = true
                
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(2))
                    showCopiedTip = false
                }
            } label: {
                Image(systemName: "doc.on.doc")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
    }
}

private struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.75))
            )
            .shadow(
                color: .black.opacity(0.15),
                radius: 10,
                x: 0,
                y: 4
            )
            .transition(.scale.combined(with: .opacity))
            .zIndex(1)
    }
}

// MARK: - Preview
#Preview("File Copy Styles") {
    VStack(spacing: 20) {
        // 默认样式
        URL.sample_temp_txt
            .copyView(destination: .documentsDirectory.appendingPathComponent("copy"))
            .withBackground()
        
        // 自定义背景色和形状
        URL.sample_jpg_moon
            .copyView(destination: .documentsDirectory.appendingPathComponent("random.jpg"))
            .withBackground(.blue.opacity(0.1))
            .withShape(.capsule)
            .withShadow(radius: 4)
            
        // 矩形样式
        URL.sample_txt_bsd
            .copyView(destination: .documentsDirectory.appendingPathComponent("download.bin"))
            .withBackground(.green.opacity(0.1))
            .withShape(.rectangle)
            .withShadow(radius: 8)
            
        // 圆角矩形 + 深色背景
        URL.sample_jpg_earth
            .copyView(destination: .documentsDirectory)
            .withBackground(.black.opacity(0.1))
            .withShape(.roundedRectangle, cornerRadius: 20)
            .withShadow(radius: 6)
    }
    .padding()
    .frame(maxWidth: 400)
    .frame(height: 800)
}
