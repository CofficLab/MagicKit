import XCTest
@testable import MagicCore

final class MagicKitTests: XCTestCase {
    func testExample() throws {
        // This is an example test case
        XCTAssertEqual(MagicKit.text, "Hello, World!")
    }

    func testImageCropping() {
        let originalImage = UIImage(named: "testImage")!
        let croppedImage = MagicKit.cropImage(originalImage, to: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        XCTAssertNotNil(croppedImage)
        XCTAssertEqual(croppedImage.size, CGSize(width: 100, height: 100))
    }

    // Add more test methods here
}