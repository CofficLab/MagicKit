import Foundation
import OSLog

extension Data {
    func save(_ url: URL) {
        // 获取目录路径
        let directoryURL = url.deletingLastPathComponent()
        
        // 检查目录是否存在，如果不存在则创建
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                //os_log("创建目录: \(directoryURL.path)")
            } catch {
                os_log(.error, "创建目录时出错: \(error)")
                return
            }
        }
        
        // 保存到文件
        do {
            try self.write(to: url)
            //os_log("保存Data到: \(url.relativePath)")
        } catch {
            os_log(.error, "保存Data时出错: \(error)")
        }
    }
}

