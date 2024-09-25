import SwiftUI
import WebKit
import OSLog

class DefaultReadyHandler: NSObject, WebHandler {
    var functionName: String = "ready"

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        os_log("收到JS发送的消息：\(message.name)")
    }
}
