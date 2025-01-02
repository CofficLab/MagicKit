import Foundation
import OSLog
import SwiftUI

public extension URL {
    /// 复制文件到目标位置，支持 iCloud 文件的自动下载
    /// - Parameters:
    ///   - destination: 目标位置
    ///   - downloadProgress: 下载进度回调
    func copyTo(_ destination: URL, downloadProgress: ((Double) -> Void)? = nil) async throws {
        if self.isiCloud && self.isNotDownloaded {
            try await download(onProgress: downloadProgress)
        }
        
        try FileManager.default.copyItem(at: self, to: destination)
    }
    
    /// 下载 iCloud 文件
    /// - Parameter onProgress: 下载进度回调
    func download(onProgress: ((Double) -> Void)? = nil) async throws {
        let fm = FileManager.default
        
        if self.isDownloaded {
            onProgress?(100)
            return
        }
        
        try fm.startDownloadingUbiquitousItem(at: self)
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let itemQuery = ItemQuery(queue: queue)
        
        let result = itemQuery.searchMetadataItems(predicates: [
            NSPredicate(format: "%K == %@", NSMetadataItemURLKey, self as NSURL),
        ])
        
        for try await collection in result {
            if let item = collection.first {
                let progress = item.downloadProgress
                onProgress?(progress)
                
                if item.isDownloaded {
                    onProgress?(100)
                    itemQuery.stop()
                    break
                }
            }
        }
    }
    
    /// 下载状态相关属性
    var isDownloaded: Bool {
        isFolder || iCloudHelper.isDownloaded(self)
    }
    
    var isDownloading: Bool {
        iCloudHelper.isDownloading(self)
    }
    
    var isNotDownloaded: Bool {
        !isDownloaded
    }
    
    var isiCloud: Bool {
        iCloudHelper.isCloudPath(url: self)
    }
    
    var isNotiCloud: Bool {
        !isiCloud
    }
    
    var isLocal: Bool {
        isNotiCloud
    }
}

// MARK: - Preview
#Preview("Download Tests") {
    DownloadTestView()
}

private struct DownloadTestView: View {
    @State private var downloadProgress: Double = 0
    @State private var isDownloading = false
    @State private var error: Error?
    
    let testFiles = [
        // iCloud 文件
        (
            name: "iCloud Document",
            url: URL(string: "file:///iCloud/test.pdf")!
        ),
        // 本地文件
        (
            name: "Local File",
            url: URL.documentsDirectory.appendingPathComponent("test.txt")
        )
    ]
    
    var body: some View {
        List {
            Section("文件状态") {
                ForEach(testFiles, id: \.name) { file in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(file.name)
                            .font(.headline)
                        
                        Group {
                            Text("iCloud: \(file.url.isiCloud ? "是" : "否")")
                            Text("已下载: \(file.url.isDownloaded ? "是" : "否")")
                            Text("下载中: \(file.url.isDownloading ? "是" : "否")")
                            Text("本地文件: \(file.url.isLocal ? "是" : "否")")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Section("下载测试") {
                VStack(spacing: 12) {
                    if isDownloading {
                        ProgressView(value: downloadProgress, total: 100) {
                            Text("下载进度: \(Int(downloadProgress))%")
                        }
                    }
                    
                    if let error = error {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    
                    Button(isDownloading ? "下载中..." : "开始下载") {
                        Task {
                            isDownloading = true
                            error = nil
                            
                            do {
                                try await testFiles[0].url.download { progress in
                                    downloadProgress = progress * 100
                                }
                            } catch {
                                self.error = error
                            }
                            
                            isDownloading = false
                        }
                    }
                    .disabled(isDownloading)
                }
                .padding(.vertical)
            }
            
            Section("复制测试") {
                Button("复制到本地") {
                    Task {
                        let source = testFiles[0].url
                        let destination = URL.documentsDirectory.appendingPathComponent("copy.pdf")
                        
                        do {
                            try await source.copyTo(destination) { progress in
                                downloadProgress = progress * 100
                            }
                        } catch {
                            self.error = error
                        }
                    }
                }
            }
        }
    }
} 
