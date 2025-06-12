import Foundation

public struct GitCommit: Identifiable, Equatable {
    public let id: String // hash
    public let hash: String
    public let author: String
    public let email: String
    public let date: Date
    public let message: String
    public let refs: [String]
    public let tags: [String]
} 