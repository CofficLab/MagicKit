import SwiftUI
import WebKit
import OSLog

class DefaultMessageHandler: NSObject, WebHandler {
    var functionName: String = "sendMessage"

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        os_log("收到JS发送的消息：\(message.name)")
        print(message.body)
    }
}
