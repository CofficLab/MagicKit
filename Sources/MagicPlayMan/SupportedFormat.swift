import Foundation

public extension MagicPlayMan {
    /// 支持的音频格式
    struct AudioFormat: RawRepresentable, Hashable {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        /// MP3 格式
        public static let mp3 = AudioFormat(rawValue: "mp3")
        /// AAC 格式
        public static let aac = AudioFormat(rawValue: "m4a")
        /// WAV 格式
        public static let wav = AudioFormat(rawValue: "wav")
        /// FLAC 格式
        public static let flac = AudioFormat(rawValue: "flac")
        
        /// 所有支持的音频格式
        public static let allCases: [AudioFormat] = [.mp3, .aac, .wav, .flac]
        
        /// 文件扩展名
        public var fileExtension: String { rawValue }
        
        /// MIME 类型
        public var mimeType: String {
            switch self {
            case .mp3: return "audio/mpeg"
            case .aac: return "audio/mp4"
            case .wav: return "audio/wav"
            case .flac: return "audio/flac"
            default: return "audio/*"
            }
        }
    }
    
    /// 支持的视频格式
    struct VideoFormat: RawRepresentable, Hashable {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        /// MP4 格式
        public static let mp4 = VideoFormat(rawValue: "mp4")
        /// MOV 格式
        public static let mov = VideoFormat(rawValue: "mov")
        /// M4V 格式
        public static let m4v = VideoFormat(rawValue: "m4v")
        /// AVI 格式
        public static let avi = VideoFormat(rawValue: "avi")
        
        /// 所有支持的视频格式
        public static let allCases: [VideoFormat] = [.mp4, .mov, .m4v, .avi]
        
        /// 文件扩展名
        public var fileExtension: String { rawValue }
        
        /// MIME 类型
        public var mimeType: String {
            switch self {
            case .mp4: return "video/mp4"
            case .mov: return "video/quicktime"
            case .m4v: return "video/x-m4v"
            case .avi: return "video/x-msvideo"
            default: return "video/*"
            }
        }
    }
    
    /// 检查 URL 是否为支持的音频格式
    static func isAudioSupported(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return AudioFormat.allCases.contains { $0.fileExtension == ext }
    }
    
    /// 检查 URL 是否为支持的视频格式
    static func isVideoSupported(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return VideoFormat.allCases.contains { $0.fileExtension == ext }
    }
    
    /// 获取 URL 对应的资源类型
    static func getAssetType(_ url: URL) -> MagicAsset.AssetType? {
        if isAudioSupported(url) {
            return .audio
        } else if isVideoSupported(url) {
            return .video
        }
        return nil
    }
} 