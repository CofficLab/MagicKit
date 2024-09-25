import SwiftUI
import WebKit

struct WebOption {
    var url: URL? = nil
    var html: String? = nil
    var code: String? = nil
    var htmlFile: URL? = nil
    
    static func url(_ url: URL) -> WebOption {
        WebOption(url: url)
    }
    
    static func file(_ file: URL) -> WebOption {
        WebOption(htmlFile: file)
    }
}
