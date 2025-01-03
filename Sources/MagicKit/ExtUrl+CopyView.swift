import SwiftUI
import Foundation

// MARK: - URL Extension
public extension URL {
    /// 创建一个文件复制进度视图
    /// - Parameters:
    ///   - destination: 目标位置（可以是文件夹或具体文件路径）
    ///   - onCompletion: 复制完成后的回调，参数为可选的错误信息
    /// - Returns: 文件复制进度视图
    ///
    /// 这个视图会显示：
    /// - 文件缩略图（如果可用）
    /// - 文件名和大小
    /// - iCloud 下载进度（如果是 iCloud 文件）
    /// - 复制进度
    /// - 错误信息（如果发生错误）
    ///
    /// 基本用法：
    /// ```swift
    /// // 复制到文件夹
    /// url.copyView(destination: .documentsDirectory)
    ///
    /// // 复制到指定文件
    /// url.copyView(destination: .documentsDirectory.appendingPathComponent("copy.txt"))
    /// ```
    ///
    /// 自定义样式：
    /// ```swift
    /// url.copyView(destination: destination)
    ///     .withBackground(.mint.opacity(0.1))
    ///     .withShape(.capsule)
    ///     .withShadow(radius: 4)
    /// ```
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
/// 复制视图的形状样式
public enum CopyViewShape {
    /// 圆角矩形（默认）
    case roundedRectangle
    /// 矩形
    case rectangle
    /// 胶囊形状
    case capsule
}

/// 复制视图的样式配置
fileprivate struct CopyViewStyle {
    /// 背景颜色
    var background: Color = .white
    /// 背景不透明度
    var backgroundOpacity: Double = 0.8
    /// 形状样式
    var shape: CopyViewShape = .roundedRectangle
    /// 圆角半径（仅用于圆角矩形）
    var cornerRadius: CGFloat = 12
    /// 阴影半径
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
    /// - Parameters:
    ///   - color: 背景颜色
    ///   - opacity: 不透明度
    /// - Returns: 修改后的视图
    public func withBackground(_ color: Color = .white, opacity: Double = 0.8) -> some View {
        transformEnvironment(\.copyViewStyle) { style in
            style.background = color
            style.backgroundOpacity = opacity
        }
    }
    
    /// 设置复制视图的形状
    /// - Parameters:
    ///   - shape: 形状样式
    ///   - cornerRadius: 圆角半径（仅用于圆角矩形）
    /// - Returns: 修改后的视图
    public func withShape(_ shape: CopyViewShape, cornerRadius: CGFloat = 12) -> some View {
        transformEnvironment(\.copyViewStyle) { style in
            style.shape = shape
            style.cornerRadius = cornerRadius
        }
    }
    
    /// 设置复制视图的阴影
    /// - Parameter radius: 阴影半径
    /// - Returns: 修改后的视图
    public func withShadow(radius: CGFloat = 2) -> some View {
        transformEnvironment(\.copyViewStyle) { style in
            style.shadowRadius = radius
        }
    }
}

// MARK: - Helper Views and Modifiers
/// 形状修改器
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

/// 文件信息视图
private struct FileInfoView: View {
    /// 文件 URL
    let url: URL
    /// 文件缩略图（如果可用）
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

/// 进度指示器视图
private struct ProgressIndicatorView: View {
    /// 当前进度（0-100）
    let progress: Double
    /// 进度说明文本
    let message: String
    
    var body: some View {
        VStack(spacing: 4) {
            ProgressView(value: progress, total: 100)
            HStack {
                Text(message)
                Spacer()
                Text(String(format: "%.1f%%", progress))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Main View
/// 文件复制进度视图
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
/// 错误信息视图
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

/// 提示信息视图
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

#Preview("Copy View") {
    CopyViewPreviewContainer()
}
