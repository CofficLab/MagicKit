import Foundation

extension AvatarView {
    /// 头像视图相关错误
    enum ViewError: LocalizedError {
        case invalidURL
        case fileNotFound
        case thumbnailGenerationFailed
        case downloadFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "无效的URL"
            case .fileNotFound:
                return "文件不存在"
            case .thumbnailGenerationFailed:
                return "无法生成缩略图"
            case .downloadFailed:
                return "下载失败"
            }
        }
    }
} 
