import Foundation

extension CGSize {
    var isSquare: Bool {
        width == height
    }

    var description: String {
        "\(width)x\(height)"
    }
}
