import Foundation
import OSLog
import SwiftUI
import WebKit

#if os(iOS)
    typealias ViewRepresentable = UIViewRepresentable
#elseif os(macOS)
    typealias ViewRepresentable = NSViewRepresentable
#endif

struct WebView {
    /// 配置
    public var option: WebOption? = nil

    /// 网页内容
    public var content: WebContent
    
    /// JS脚本处理器
    public var controller: WKUserContentController

    @StateObject public var delegate: WKDelegate = .init()

    public init(_ option: WebOption) {
        os_log("🚩 初始化 Webview")
        self.option = option
        self.controller = WKUserContentController()

        // 初始化网络内容部分

        let config = WKWebViewConfiguration()

        config.userContentController = self.controller
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        self.content = WebContent(frame: .zero, configuration: config)
        self.content.isInspectable = true
        
        // 处理JS发送的消息
        self.addHanlder(DefaultMessageHandler())
        self.addHanlder(DefaultDownloadHandler())
        self.addHanlder(DefaultReadyHandler())
    }
    
    func addHanlder(_ h: WebHandler) {
        self.controller.add(h, name: h.functionName)
    }
    
    func removeHanlders() {
        self.controller.removeAllScriptMessageHandlers()
    }
}

/// 将 WebContent 封装成一个普通的 View
extension WebView: ViewRepresentable {
    #if os(iOS)
        public func makeUIView(context: Context) -> WKWebView {
            makeView()
        }

        public func updateUIView(_ uiView: WKWebView, context: Context) {}
    #endif

    #if os(macOS)
        public func makeNSView(context: Context) -> WKWebView {
            makeView()
        }

        public func updateNSView(_ content: WKWebView, context: Context) {
            // print("WebView 更新视图")
        }
    #endif

    func makeView() -> WKWebView {
        if let option = option, let url = option.url {
            content.load(URLRequest(url: url))
        }

        if let option = option, let html = option.html, !html.isEmpty {
            content.loadHTMLString(html, baseURL: nil)
        }

        if let option = option, let htmlFile = option.htmlFile {
            content.loadFileURL(htmlFile, allowingReadAccessTo: htmlFile)
        }

        if let option = option, let code = option.code, !code.isEmpty {
            content.run(code)
        }

        content.uiDelegate = delegate

        return content
    }
}
