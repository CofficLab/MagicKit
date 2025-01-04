import Foundation

public extension URL {
    // MARK: - 音频示例 (MP3/WAV)
    /// NASA 太空音效 - 肯尼迪演讲
    static let sample_web_mp3_kennedy = URL(string: "https://www.nasa.gov/wp-content/uploads/2016/11/jfk_rice_university_speech_1962.mp3")!
    /// NASA 太空音效 - 水星计划通讯
    static let sample_web_mp3_mercury = URL(string: "https://www.nasa.gov/wp-content/uploads/2016/11/mercury_program.mp3")!
    /// NASA 太空音效 - 阿波罗登月
    static let sample_web_mp3_apollo = URL(string: "https://www.nasa.gov/wp-content/uploads/2016/11/apollo11_highlight.mp3")!
    /// NASA 太空音效 - 挑战者号事故
    static let sample_web_mp3_challenger = URL(string: "https://www.nasa.gov/wp-content/uploads/2016/11/challenger.mp3")!
    /// NASA 太空音效 - 发现号任务
    static let sample_web_mp3_discovery = URL(string: "https://www.nasa.gov/wp-content/uploads/2016/11/discovery_mission.mp3")!
    
    /// NASA 火箭发射音效
    static let sample_web_wav_launch = URL(string: "https://www.nasa.gov/wp-content/uploads/2021/07/Launch_Aboard.wav")!
    /// NASA 太空站音效
    static let sample_web_wav_iss = URL(string: "https://www.nasa.gov/wp-content/uploads/2021/07/ISS-Sounds.wav")!
    /// NASA 火星音效
    static let sample_web_wav_mars = URL(string: "https://www.nasa.gov/wp-content/uploads/2021/07/Mars-Sounds.wav")!
    /// NASA 木星音效
    static let sample_web_wav_jupiter = URL(string: "https://www.nasa.gov/wp-content/uploads/2021/07/Jupiter-Sounds.wav")!
    /// NASA 土星音效
    static let sample_web_wav_saturn = URL(string: "https://www.nasa.gov/wp-content/uploads/2021/07/Saturn-Sounds.wav")!
    
    // MARK: - 视频示例 (MP4)
    /// Big Buck Bunny 开源动画
    static let sample_web_mp4_bunny = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    /// Sintel 开源动画预告片
    static let sample_web_mp4_sintel = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")!
    /// Elephants Dream 开源动画
    static let sample_web_mp4_elephants = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!
    /// Tears of Steel 开源科幻短片
    static let sample_web_mp4_tears = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4")!
    /// For Bigger Blazes 示例视频
    static let sample_web_mp4_blazes = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!
    
    // MARK: - 图片示例 (JPG/PNG)
    /// NASA 地球照片 - 蓝色弹珠
    static let sample_web_jpg_earth = URL(string: "https://www.nasa.gov/wp-content/uploads/2023/03/feb-2023-blue-marble.jpg")!
    /// NASA 火星照片 - 好奇号
    static let sample_web_jpg_mars = URL(string: "https://www.nasa.gov/wp-content/uploads/2023/07/mars-curiosity-rover.jpg")!
    /// NASA 月球照片 - 表面
    static let sample_web_jpg_moon = URL(string: "https://www.nasa.gov/wp-content/uploads/2023/05/moon-surface.jpg")!
    /// NASA 木星照片 - 大红斑
    static let sample_web_jpg_jupiter = URL(string: "https://www.nasa.gov/wp-content/uploads/2023/06/jupiter-great-red-spot.jpg")!
    /// NASA 土星照片 - 光环
    static let sample_web_jpg_saturn = URL(string: "https://www.nasa.gov/wp-content/uploads/2023/04/saturn-rings.jpg")!
    
    /// Wikipedia PNG 示例 - 透明度演示
    static let sample_web_png_transparency = URL(string: "https://upload.wikimedia.org/wikipedia/commons/4/47/PNG_transparency_demonstration_1.png")!
    /// Wikipedia PNG 示例 - 色彩渐变
    static let sample_web_png_gradient = URL(string: "https://upload.wikimedia.org/wikipedia/commons/a/a4/RGB_color_gradient.png")!
    /// Wikipedia PNG 示例 - 图表
    static let sample_web_png_circles = URL(string: "https://upload.wikimedia.org/wikipedia/commons/8/8a/PNG_demonstration_circles.png")!
    /// Wikipedia PNG 示例 - 调色板
    static let sample_web_png_palette = URL(string: "https://upload.wikimedia.org/wikipedia/commons/c/c4/PNG_palette_demonstration.png")!
    /// Wikipedia PNG 示例 - 像素艺术
    static let sample_web_png_pixel = URL(string: "https://upload.wikimedia.org/wikipedia/commons/7/7d/PNG_pixel_art_demonstration.png")!
    
    // MARK: - 流媒体示例 (HLS)
    /// Apple 示例 HLS 流 - 基础
    static let sample_web_stream_basic = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
    /// Apple 示例 HLS 流 - 高级
    static let sample_web_stream_advanced = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!
    /// Apple 示例 HLS 流 - 4K
    static let sample_web_stream_4k = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/4k_hevc/master.m3u8")!
    /// Apple 示例 HLS 流 - HDR
    static let sample_web_stream_hdr = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/hdr10_hevc/master.m3u8")!
    /// Apple 示例 HLS 流 - 杜比视界
    static let sample_web_stream_dolby = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/dolby_vision/master.m3u8")!
    
    // MARK: - 其他示例 (PDF/TXT)
    /// Swift 文档 PDF - 入门指南
    static let sample_web_pdf_swift_guide = URL(string: "https://docs.swift.org/swift-book/documentation/the-swift-programming-language/guidedtour.pdf")!
    /// SwiftUI 文档 PDF - 视图和控件
    static let sample_web_pdf_swiftui = URL(string: "https://docs.swift.org/swift-book/documentation/swiftui/views-and-controls.pdf")!
    /// Swift 文档 PDF - 并发编程
    static let sample_web_pdf_concurrency = URL(string: "https://docs.swift.org/swift-book/documentation/swift/concurrency.pdf")!
    /// Swift 文档 PDF - 内存安全
    static let sample_web_pdf_memory = URL(string: "https://docs.swift.org/swift-book/documentation/swift/memory-safety.pdf")!
    /// Swift 文档 PDF - 泛型编程
    static let sample_web_pdf_generics = URL(string: "https://docs.swift.org/swift-book/documentation/swift/generics.pdf")!
    
    /// MIT 开源协议
    static let sample_web_txt_mit = URL(string: "https://opensource.org/licenses/MIT")!
    /// Apache 开源协议
    static let sample_web_txt_apache = URL(string: "https://www.apache.org/licenses/LICENSE-2.0.txt")!
    /// GPL 开源协议
    static let sample_web_txt_gpl = URL(string: "https://www.gnu.org/licenses/gpl-3.0.txt")!
    /// BSD 开源协议
    static let sample_web_txt_bsd = URL(string: "https://opensource.org/licenses/BSD-3-Clause")!
    /// Mozilla 开源协议
    static let sample_web_txt_mozilla = URL(string: "https://www.mozilla.org/media/MPL/2.0/index.txt")!
    
    // MARK: - 临时文件示例
    /// 临时目录中的文本文件
    static var sample_temp_txt: URL {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("magic_kit_test.txt")
        
        if !FileManager.default.fileExists(atPath: tempFile.path) {
            let content = """
            This is a test file created by MagicKit.
            创建时间: \(Date())
            
            用途：
            1. 测试文件操作
            2. 测试缩略图生成
            3. 测试文件属性读取
            """
            try? content.write(to: tempFile, atomically: true, encoding: .utf8)
        }
        
        return tempFile
    }
    
    /// 临时目录中的音频文件（从 sample_mp3_kennedy 复制）
    static var sample_temp_mp3: URL {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("magic_kit_test.mp3")
        
        if !FileManager.default.fileExists(atPath: tempFile.path) {
            try? FileManager.default.copyRemoteFile(from: sample_web_mp3_kennedy, to: tempFile)
        }
        
        return tempFile
    }
    
    /// 临时目录中的视频文件（从 sample_mp4_bunny 复制）
    static var sample_temp_mp4: URL {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("magic_kit_test.mp4")
        
        if !FileManager.default.fileExists(atPath: tempFile.path) {
            try? FileManager.default.copyRemoteFile(from: sample_web_mp4_bunny, to: tempFile)
        }
        
        return tempFile
    }
    
    /// 临时目录中的图片文件（从 sample_jpg_earth 复制）
    static var sample_temp_jpg: URL {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("magic_kit_test.jpg")
        
        if !FileManager.default.fileExists(atPath: tempFile.path) {
            try? FileManager.default.copyRemoteFile(from: sample_web_jpg_earth, to: tempFile)
        }
        
        return tempFile
    }
    
    /// 临时目录中的 PDF 文件（从 sample_pdf_swift_guide 复制）
    static var sample_temp_pdf: URL {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("magic_kit_test.pdf")
        
        if !FileManager.default.fileExists(atPath: tempFile.path) {
            try? FileManager.default.copyRemoteFile(from: sample_web_pdf_swift_guide, to: tempFile)
        }
        
        return tempFile
    }
    
    /// 临时目录中的测试文件夹
    static var sample_temp_folder: URL {
        let tempFolder = FileManager.default.temporaryDirectory
            .appendingPathComponent("magic_kit_test_folder")
        
        if !FileManager.default.fileExists(atPath: tempFolder.path) {
            try? FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true)
            
            // 创建一些测试文件
            let testFiles = [
                ("test1.txt", "这是测试文件1"),
                ("test2.txt", "这是测试文件2"),
                ("subfolder", nil)
            ]
            
            for (name, content) in testFiles {
                let fileURL = tempFolder.appendingPathComponent(name)
                if let content = content {
                    try? content.write(to: fileURL, atomically: true, encoding: .utf8)
                } else {
                    try? FileManager.default.createDirectory(at: fileURL, withIntermediateDirectories: true)
                }
            }
        }
        
        return tempFolder
    }
    
    // MARK: - iCloud 示例
    /// 获取 iCloud 文档目录中的示例文件
    /// - Parameter filename: 文件名
    /// - Returns: iCloud 文件的 URL
    static func sample_icloud_document(_ filename: String) -> URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
            .appendingPathComponent(filename)
    }
    
    /// 获取 iCloud 容器中的示例文件
    /// - Parameters:
    ///   - filename: 文件名
    ///   - container: 容器标识符，例如 "iCloud.com.example.app"
    /// - Returns: iCloud 文件的 URL
    static func sample_icloud_container(_ filename: String, container: String) -> URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: container)?
            .appendingPathComponent(filename)
    }
    
    /// iCloud 文档中的示例文本文件
    static var sample_icloud_text: URL? {
        sample_icloud_document("magic_kit_test.txt")
    }
    
    /// iCloud 文档中的示例图片文件
    static var sample_icloud_image: URL? {
        sample_icloud_document("magic_kit_test.jpg")
    }
    
    /// iCloud 文档中的示例视频文件
    static var sample_icloud_video: URL? {
        sample_icloud_document("magic_kit_test.mp4")
    }
    
    /// 创建 iCloud 示例文件
    /// - Parameters:
    ///   - completion: 完成回调，返回创建的文件 URL 数组和可能的错误
    static func createICloudSamples(completion: @escaping ([URL], Error?) -> Void) {
        // 检查 iCloud 是否可用
        guard let documentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents") else {
            let error = NSError(
                domain: "MagicKit",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "iCloud 不可用，请检查：\n1. 是否已登录 iCloud\n2. 是否已启用 iCloud Drive\n3. 应用是否有 iCloud 权限"]
            )
            completion([], error)
            return
        }
        
        // 确保目录存在
        do {
            try FileManager.default.createDirectory(
                at: documentsURL,
                withIntermediateDirectories: true
            )
        } catch {
            completion([], error)
            return
        }
        
        // 创建示例文件
        let samples: [(URL, URL)] = [
            (sample_web_jpg_earth, documentsURL.appendingPathComponent("magic_kit_test.jpg")),
            (sample_web_mp4_bunny, documentsURL.appendingPathComponent("magic_kit_test.mp4")),
            (sample_web_mp3_kennedy, documentsURL.appendingPathComponent("magic_kit_test.mp3"))
        ]
        
        var createdFiles: [URL] = []
        var lastError: Error?
        let group = DispatchGroup()
        
        for (source, destination) in samples {
            group.enter()
            
            // 下载并保存到 iCloud
            URLSession.shared.downloadTask(with: source) { tempURL, response, error in
                defer { group.leave() }
                
                if let error = error {
                    lastError = error
                    return
                }
                
                guard let tempURL = tempURL,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    lastError = NSError(
                        domain: "MagicKit",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "下载文件失败"]
                    )
                    return
                }
                
                do {
                    // 如果目标文件已存在，先删除
                    if FileManager.default.fileExists(atPath: destination.path) {
                        try FileManager.default.removeItem(at: destination)
                    }
                    
                    // 移动文件到 iCloud
                    try FileManager.default.copyItem(at: tempURL, to: destination)
                    createdFiles.append(destination)
                } catch {
                    lastError = error
                }
            }.resume()
        }
        
        // 所有文件创建完成后回调
        group.notify(queue: .main) {
            completion(createdFiles, lastError)
        }
    }
    
    // MARK: - 错误示例
    /// 无效的 URL 示例
    static let sample_invalid_url = URL(string: "invalid://url.example")!
    
    /// 不存在的文件示例
    static let sample_nonexistent_file = FileManager.default.temporaryDirectory
        .appendingPathComponent("nonexistent_file.jpg")
}

// MARK: - FileManager Extension
private extension FileManager {
    func copyRemoteFile(from sourceURL: URL, to destinationURL: URL) throws {
        // 创建一个 URLSession 数据任务来下载文件
        let semaphore = DispatchSemaphore(value: 0)
        var downloadError: Error?
        
        let task = URLSession.shared.downloadTask(with: sourceURL) { tempURL, _, error in
            if let error = error {
                downloadError = error
                semaphore.signal()
                return
            }
            
            guard let tempURL = tempURL else {
                downloadError = NSError(domain: "MagicKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Download failed"])
                semaphore.signal()
                return
            }
            
            do {
                // 如果目标文件已存在，先删除
                if self.fileExists(atPath: destinationURL.path) {
                    try self.removeItem(at: destinationURL)
                }
                // 将下载的临时文件移动到目标位置
                try self.moveItem(at: tempURL, to: destinationURL)
            } catch {
                downloadError = error
            }
            
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: .now() + 30) // 30秒超时
        
        if let error = downloadError {
            throw error
        }
    }
} 
