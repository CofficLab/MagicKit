import Foundation

/// 表示一个 Git 远程仓库
public struct GitRemote: Identifiable, Equatable {
    /// 远程名（唯一标识）
    public let id: String
    /// 远程名
    public let name: String
    /// 远程仓库主 URL
    public let url: String
    /// fetch URL（如有）
    public let fetchURL: String?
    /// push URL（如有）
    public let pushURL: String?
    /// 是否为默认远程（如 origin）
    public let isDefault: Bool
} 