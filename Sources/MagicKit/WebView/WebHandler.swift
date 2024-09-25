import SwiftUI
import WebKit

public protocol WebHandler: WKScriptMessageHandler {
    var functionName: String { get }
}
