import Foundation

public struct GitBranch: Identifiable, Equatable {
    public let id: String // branch name
    public let name: String
    public let isCurrent: Bool
    public let upstream: String?
    public let latestCommitHash: String
    public let latestCommitMessage: String
} 