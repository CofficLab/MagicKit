import Foundation
import SwiftUI
import OSLog
import WebKit

#if os(iOS)
    typealias ViewRepresentable = UIViewRepresentable
#elseif os(macOS)
    typealias ViewRepresentable = NSViewRepresentable
#endif

// 将 WebContent 封装成一个普通的 View
public struct WebView: ViewRepresentable, SuperLog {
    let emoji = "🕸️"

    public init(
        url: URL? = nil,
        html: String? = "",
        code: String? = "",
        htmlFile: URL? = nil,
        config: WKWebViewConfiguration
    ) {
        let verbose = true

        if verbose {
            os_log("\(Logger.initLog) WebView with url -> \(url?.absoluteString ?? "nil")")
        }

        self.url = url
        self.html = html
        self.config = config
        self.code = code
        self.htmlFile = htmlFile
        content = WebContent(frame: .zero, configuration: config)
        content.isInspectable = true
    }

    var url: URL?
    let html: String?
    private let code: String?
    private let htmlFile: URL?
    private let config: WKWebViewConfiguration?

    /// 网页内容
    var content: WebContent

    @StateObject var delegate = WebViewDelegate()

    #if os(iOS)
        public func makeUIView(context: Context) -> WKWebView {
            makeView()
        }

        public func updateUIView(_ uiView: WKWebView, context: Context) {
            os_log("\(self.t)WebView 更新视图")
        }
    #endif

    #if os(macOS)
        public func makeNSView(context: Context) -> WKWebView {
            makeView()
        }

        public func updateNSView(_ content: WKWebView, context: Context) {
            os_log("\(self.t)WebView 更新视图")
        }
    #endif

    func makeView() -> WKWebView {
        let verbose = true

        if let url = url {
            if verbose {
                os_log("\(self.t)Make View with -> \(url.absoluteString)")
            }
            content.load(URLRequest(url: url))
        }

        if let html = html, html.isNotEmpty {
            content.loadHTMLString(html, baseURL: nil)
        }

        if let htmlFile = htmlFile {
            if verbose {
                os_log("\(self.t)Make View with htmlFile")
            }
            content.loadFileURL(htmlFile, allowingReadAccessTo: htmlFile)
        }

        if code != nil && code!.count > 0 {
            Task {
                try await content.run(code!)
            }
        }

        content.uiDelegate = delegate

        return content
    }

    mutating func changeURL(_ url: URL) {
        let verbose = true

        if self.url == url {
            return
        }

        if verbose {
            os_log("ChangeURL -> \(url.absoluteString)")
        }

        content.load(URLRequest(url: url))
    }
}

extension WebView: Equatable {
    public static func == (lhs: WebView, rhs: WebView) -> Bool {
        lhs.url == rhs.url
    }
}
