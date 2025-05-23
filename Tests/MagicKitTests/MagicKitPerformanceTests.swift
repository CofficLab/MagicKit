import XCTest
@testable import MagicCore

class MagicKitPerformanceTests: XCTestCase {
    func testImageCroppingPerformance() {
        let originalImage = UIImage(named: "largeTestImage")!
        measure {
            _ = MagicKit.cropImage(originalImage, to: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        }
    }
}