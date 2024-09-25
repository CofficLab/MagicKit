import SwiftUI
import WebKit

protocol WebHandler: WKScriptMessageHandler {
    var functionName: String { get }
}

#Preview {
    AppPreview()
}
