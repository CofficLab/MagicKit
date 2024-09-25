import Foundation

extension String {
    func toBase64() -> String {
        if let data = self.data(using: .utf8) {
            let base64String = data.base64EncodedString()
            
            return base64String
        } else {
            return ""
        }
    }
}
