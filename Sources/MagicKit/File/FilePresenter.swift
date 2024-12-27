import Foundation
import OSLog

public class FilePresenter: NSObject, NSFilePresenter {
    public let fileURL: URL
    public var presentedItemOperationQueue: OperationQueue = .main
    public var onDidChange: () -> Void = { os_log("🍋 FilePresenter::changed") }

    public init(fileURL: URL) {
        self.fileURL = fileURL
        super.init()
        // 注册，监视指定 URL
        NSFileCoordinator.addFilePresenter(self)
    }

    deinit {
        // 注销监视
        NSFileCoordinator.removeFilePresenter(self)
    }

    public var presentedItemURL: URL? {
        return fileURL
    }

    public func presentedItemDidChange() {
        // 当文件发生变化时，执行相关操作
        // 例如，重新加载文件或通知其他组件
        self.onDidChange()
    }
    
    public func getFiles() -> [URL] {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: self.fileURL.path())
            
            return files.filter({
                $0.hasSuffix(".DS_Store") == false
            }).map {
                URL(fileURLWithPath: self.fileURL.path()).appendingPathComponent($0)
            }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            
            return []
        }
    }
}
