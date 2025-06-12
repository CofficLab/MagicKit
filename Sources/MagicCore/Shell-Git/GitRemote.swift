import Foundation

public struct GitRemote: Identifiable, Equatable {
    public let id: String // remote name
    public let name: String
    public let url: String
    public let fetchURL: String?
    public let pushURL: String?
    public let isDefault: Bool
} 