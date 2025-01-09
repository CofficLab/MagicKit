import Foundation
import OSLog
import AudioToolbox
import AVFoundation

/// WAV 文件的元数据处理
extension URL {
    /// 写入封面到 WAV 文件
    func writeCoverToWAVFile(
        imageData: Data,
        verbose: Bool = false
    ) async throws {
        if verbose {
            os_log("使用 AVAsset 处理 WAV 文件：\(self.path)")
        }
        
        // 1. 创建临时文件
        let temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("wav")
        
        // 2. 复制原始文件到临时文件
        try FileManager.default.copyItem(at: self, to: temporaryURL)
        
        // 3. 创建导出会话
        let asset = AVAsset(url: temporaryURL)
        let exporter = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetPassthrough
        )
        
        guard let exporter = exporter else {
            throw CoverWriteError.wavProcessingFailed(NSError(
                domain: "MagicKit",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "无法创建导出会话"]
            ))
        }
        
        // 4. 设置元数据
        let artwork = AVMutableMetadataItem()
        artwork.identifier = .commonIdentifierArtwork
        artwork.value = imageData as NSData
        artwork.dataType = kCMMetadataBaseDataType_JPEG as String
        
        exporter.metadata = [artwork]
        exporter.outputURL = self
        exporter.outputFileType = .wav
        exporter.shouldOptimizeForNetworkUse = false
        
        // 5. 执行导出
        await exporter.export()
        
        // 6. 检查结果
        if let error = exporter.error {
            if verbose {
                os_log("WAV 封面写入失败：\(error.localizedDescription)")
            }
            throw CoverWriteError.wavProcessingFailed(error)
        }
        
        // 7. 清理临时文件
        try? FileManager.default.removeItem(at: temporaryURL)
        
        if verbose {
            os_log("成功写入 WAV 封面")
        }
    }
}

private extension AudioFilePropertyID {
    var string: String {
        let chars = [
            Int8(self >> 24 & 0xFF),
            Int8(self >> 16 & 0xFF),
            Int8(self >> 8 & 0xFF),
            Int8(self & 0xFF)
        ]
        return String(cString: chars)
    }
} 