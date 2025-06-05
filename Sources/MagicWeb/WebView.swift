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
public struct WebView: ViewRepresentable {
    let emoji = "🕸️"
    var url: URL?
    let html: String?
    var verbose = false
    private let code: String?
    private let htmlFile: URL?
    private let config: WKWebViewConfiguration?

    public init(
        url: URL? = nil,
        html: String? = "",
        code: String? = "",
        htmlFile: URL? = nil,
        config: WKWebViewConfiguration,
        verbose: Bool = false
    ) {
        if verbose {
            os_log("WebView with url -> \(url?.absoluteString ?? "nil")")
        }

        self.url = url
        self.html = html
        self.config = config
        self.code = code
        self.htmlFile = htmlFile
        self.verbose = verbose
        content = WebContent(frame: .zero, configuration: config)
        content.isInspectable = true
    }

    /// 网页内容
    public var content: WebContent
    
    /// The current URL of the web view.
    public var currentURL: URL? {
        content.url
    }

    @StateObject var delegate = WebViewDelegate()

    #if os(iOS)
        public func makeUIView(context: Context) -> WKWebView {
            makeView()
        }

        public func updateUIView(_ uiView: WKWebView, context: Context) {
            let verbose = false 
            if verbose {
                os_log("WebView 更新视图")
            }
        }
    #endif

    #if os(macOS)
        public func makeNSView(context: Context) -> WKWebView {
            makeView()
        }

        public func updateNSView(_ content: WKWebView, context: Context) {
            if verbose {
                os_log("WebView 更新视图")
            }
        }
    #endif

    func makeView() -> WKWebView {
        if let url = url {
            if verbose {
                os_log("Make View with -> \(url.absoluteString)")
            }
            content.load(URLRequest(url: url))
        }

        if let html = html, html.isNotEmpty {
            content.loadHTMLString(html, baseURL: nil)
        }

        if let htmlFile = htmlFile {
            if verbose {
                os_log("Make View with htmlFile")
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

    public func goto(_ url: URL) {
        if self.currentURL == url {
            return
        }

        content.load(URLRequest(url: url))
    }
}

extension WebView: Equatable {
    public static func == (lhs: WebView, rhs: WebView) -> Bool {
        lhs.url == rhs.url
    }
}
