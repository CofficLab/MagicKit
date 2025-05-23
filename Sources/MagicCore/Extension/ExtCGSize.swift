import Foundation

public extension CGSize {
    static let iPhoneSE = CGSize(width: 375, height: 667)
    static let iPhone = CGSize(width: 390, height: 844)
    static let iPhonePlus = CGSize(width: 428, height: 926)
    static let iPhoneMax = CGSize(width: 430, height: 932)
    static let iPadMini = CGSize(width: 744, height: 1133)
    static let iPad = CGSize(width: 820, height: 1180)
    static let iPadPro11 = CGSize(width: 834, height: 1194)
    static let iPadPro12 = CGSize(width: 1024, height: 1366)
    static let mac = CGSize(width: 1024, height: 768)
    
    var isSquare: Bool {
        width == height
    }

    var description: String {
        "\(width)x\(height)"
    }
}
