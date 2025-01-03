import SwiftUI
import Foundation

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

// MARK: - File Copy Progress View

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
    
    private var finalDestination: URL {
        destination.hasDirectoryPath ? 
            destination.appendingPathComponent(source.lastPathComponent) : 
            destination
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                // 文件信息
                HStack(spacing: 16) {
                    // 缩略图
                    Group {
                        if let thumbnail = thumbnail {
                            thumbnail
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Image(systemName: source.isDirectory ? "folder" : "doc")
                                .font(.title)
                        }
                    }
                    .frame(width: 40, height: 40)
                    
                    // 文件信息
                    VStack(alignment: .leading, spacing: 4) {
                        Text(source.lastPathComponent)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Text(source.getSizeReadable())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // iCloud 下载进度
                if source.isiCloud && source.isNotDownloaded {
                    VStack(spacing: 4) {
                        ProgressView(value: downloadProgress, total: 100)
                        Text("正在从 iCloud 下载...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // 复制进度
                if isCopying {
                    VStack(spacing: 4) {
                        ProgressView(value: copyProgress, total: 100)
                        Text("正在复制到: \(finalDestination.lastPathComponent)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // 错误信息
                if let error {
                    HStack {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundStyle(.red)
                        
                        Spacer()
                        
                        Button {
                            #if os(macOS)
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(error.localizedDescription, forType: .string)
                            #else
                            UIPasteboard.general.string = error.localizedDescription
                            #endif
                            
                            showCopiedTip = true
                            
                            // 2秒后自动隐藏提示
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
                
                // 完成状态
                if isCompleted {
                    Label("复制完成", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            .padding()
            .background(.background.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 2)
            
            // Toast 提示
            if showCopiedTip {
                Text("错误信息已复制到剪贴板")
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .task {
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

// MARK: - Preview

#Preview("File Copy") {
    VStack {
        // 测试本地文件复制
        URL.documentsDirectory
            .appendingPathComponent("test.txt")
            .copyView(destination: .documentsDirectory.appendingPathComponent("copy"))
        
        // 测试 iCloud 文件复制
        URL(string: "file:///iCloud/test.pdf")!
            .copyView(destination: .documentsDirectory)
            
        // 测试网络文件复制
        URL(string: "https://speed.hetzner.de/100MB.bin")!
            .copyView(destination: .documentsDirectory.appendingPathComponent("download.bin"))
            
        // 测试网络图片复制
        URL(string: "https://picsum.photos/200")!
            .copyView(destination: .documentsDirectory.appendingPathComponent("random.jpg"))
    }
    .padding()
    .frame(height: 800)
}
