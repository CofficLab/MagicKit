import Foundation

public struct GitTag: Identifiable, Equatable {
    public let id: String // tag name
    public let name: String
    public let commitHash: String
    public let author: String?
    public let date: Date?
    public let message: String?
} 