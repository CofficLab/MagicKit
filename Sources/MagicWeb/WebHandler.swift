import SwiftUI
import WebKit

/// 用于处理WebView中JavaScript消息的协议
///
/// 这个协议扩展了WKScriptMessageHandler，为WebView提供了一种标准化的方式来处理来自JavaScript的消息。
/// 实现此协议的类需要提供一个唯一的functionName，用于在JavaScript中识别和调用对应的处理程序。
///
/// ## 使用示例:
/// ```swift
/// class MyMessageHandler: NSObject, WebHandler {
///     var functionName: String { return "handleMessage" }
///     
///     func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
///         guard message.name == functionName else { return }
///         // 处理来自JavaScript的消息
///         print("收到消息: \(message.body)")
///     }
/// }
/// ```
public protocol WebHandler: WKScriptMessageHandler {
    /// 用于在JavaScript中识别此处理程序的函数名
    ///
    /// 此属性定义了在JavaScript中调用此处理程序时使用的函数名。
    /// 例如，如果functionName为"handleMessage"，则在JavaScript中可以通过
    /// window.webkit.messageHandlers.handleMessage.postMessage(data)来调用此处理程序。
    var functionName: String { get }
}
