import Foundation

extension URL {
    static public var null: URL {
        URL(filePath: "/dev/null")
    }
}
