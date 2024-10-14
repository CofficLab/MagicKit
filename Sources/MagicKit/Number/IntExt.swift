import Foundation

extension Int {
    public func isHttpOkCode() -> Bool {
        self >= 200 && self < 300
    }
    
    var string: String {
        "\(self)"
    }
}
