import Foundation
import OSLog

extension String {
    public var isNotEmpty: Bool {
        !isEmpty
    }
    
    public func noSpaces() -> String {
        self.trimmingCharacters(in: .whitespaces)
    }
    
    public func removingLeadingSlashes() -> String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
    
    public func mini() -> String {
        self.count <= 30 ? self : String(self.prefix(30)) + "..."
    }
    
    public func max(_ max: Int) -> String {
        self.count <= max ? self : String(self.prefix(max)) + "..."
    }
    
    public func toURL() -> URL {
        URL(string: self)!
    }
    
    public func toData() -> Data? {
        self.data(using: .utf8)
    }
    
    public func saveToFile(_ url: URL) {
        let verbose = false
        
        if verbose {
            os_log("保存到 -> \(url.relativePath)")
        }
        
        let f = FileManager.default
        let folder = url.deletingLastPathComponent()
        
        if !f.fileExists(atPath: folder.path) {
            do {
                try f.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("创建文件夹时发生错误: \(error)")
            }
        }

        do {
            try self.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            os_log(.error, "保存失败 -> \(error)")
        }
    }
}
