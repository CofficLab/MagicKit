import Foundation
import OSLog
import SwiftUI
import MagicUI

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
    
    /// 创建下载按钮
    /// - Parameters:
    ///   - size: 按钮大小，默认为 28x28
    ///   - showLabel: 是否显示文字标签，默认为 false
    ///   - shape: 按钮形状，默认为圆形
    ///   - destination: 下载目标位置，如果为 nil 则只下载到 iCloud 本地
    /// - Returns: 下载按钮视图
    func makeDownloadButton(
        size: CGFloat = 28,
        showLabel: Bool = false,
        shape: MagicButton.Shape = .circle,
        destination: URL? = nil
    ) -> some View {
        DownloadButtonView(
            url: self,
            size: size,
            showLabel: showLabel,
            shape: shape,
            destination: destination
        )
    }
} 
