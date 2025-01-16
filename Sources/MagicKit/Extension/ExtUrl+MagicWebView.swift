import SwiftUI
@preconcurrency import WebKit

public struct MagicWebView: View {
    internal let url: URL
    internal let onLoadComplete: ((Error?) -> Void)?
    private var logger = MagicLogger.shared
    private let showLogView: Bool

    public init(
        url: URL,
        showLogView: Bool = false,
        onLoadComplete: ((Error?) -> Void)? = nil
    ) {
        self.url = url
        self.showLogView = showLogView
        self.onLoadComplete = onLoadComplete
        logger.info("创建 WebView: \(url.absoluteString)")
    }

    public var body: some View {
        VStack(spacing: 0) {
            if url.canOpenInWebView {
                #if os(iOS)
                    WebViewWrapper(url: url, logger: logger, onLoadComplete: onLoadComplete)
                        .onAppear {
                            logger.debug("WebView 视图显示")
                        }
                        .onDisappear {
                            logger.debug("WebView 视图消失")
                        }
                #elseif os(macOS)
                    MacWebViewWrapper(url: url, logger: logger, onLoadComplete: onLoadComplete)
                        .onAppear {
                            logger.debug("WebView 视图显示")
                        }
                        .onDisappear {
                            logger.debug("WebView 视图消失")
                        }
                #else
                    Text("WebView仅支持iOS和macOS平台")
                #endif
            } else {
                Text("不支持在WebView中打开该URL")
                    .onAppear {
                        logger.error("不支持的URL类型: \(url.absoluteString)")
                    }
            }

            if showLogView {
                Divider()
                    .padding(.vertical, 4)

                logger.logView()
                    .frame(height: nil)
                    .frame(maxHeight: .infinity)
            }
        }
    }
}

#if os(iOS)
    private struct WebViewWrapper: UIViewRepresentable {
        let url: URL
        let logger: MagicLogger
        let onLoadComplete: ((Error?) -> Void)?

        func makeCoordinator() -> Coordinator {
            logger.debug("创建 WebView Coordinator")
            return Coordinator(url: url, logger: logger, onLoadComplete: onLoadComplete)
        }

        func makeUIView(context: Context) -> WKWebView {
            logger.info("🔄 准备加载网页: \(url.absoluteString)")
            let webView = WKWebView()
            webView.navigationDelegate = context.coordinator
            webView.load(URLRequest(url: url))
            logger.debug("WebView 已创建并开始加载")
            return webView
        }

        func updateUIView(_ uiView: WKWebView, context: Context) {
            logger.debug("WebView 更新")
        }
    }

    private class Coordinator: NSObject, WKNavigationDelegate {
        let url: URL
        let logger: MagicLogger
        let onLoadComplete: ((Error?) -> Void)?

        init(url: URL, logger: MagicLogger, onLoadComplete: ((Error?) -> Void)?) {
            self.url = url
            self.logger = logger
            self.onLoadComplete = onLoadComplete
            super.init()
            logger.debug("Coordinator 初始化完成")
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            logger.info("⏳ 开始加载网页: \(url.absoluteString)")
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            logger.info("📡 网页内容开始传输")
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            logger.info("✅ 网页加载完成: \(url.absoluteString)")
            onLoadComplete?(nil)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            logger.error("❌ 网页加载失败: \(error.localizedDescription)")
            onLoadComplete?(error)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            logger.error("❌ 网页预加载失败: \(error.localizedDescription)")
            onLoadComplete?(error)
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            logger.debug("🔍 请求加载URL: \(navigationAction.request.url?.absoluteString ?? "unknown")")
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if let httpResponse = navigationResponse.response as? HTTPURLResponse {
                logger.debug("📥 收到响应: HTTP \(httpResponse.statusCode)")
            }
            decisionHandler(.allow)
        }
    }

#elseif os(macOS)
    private struct MacWebViewWrapper: NSViewRepresentable {
        let url: URL
        let logger: MagicLogger
        let onLoadComplete: ((Error?) -> Void)?

        func makeCoordinator() -> Coordinator {
            Coordinator(url: url, logger: logger, onLoadComplete: onLoadComplete)
        }

        func makeNSView(context: Context) -> WKWebView {
            logger.info("准备加载网页: \(url.absoluteString)")
            let webView = WKWebView()
            webView.navigationDelegate = context.coordinator
            webView.load(URLRequest(url: url))
            logger.debug("WebView已创建并开始加载")
            return webView
        }

        func updateNSView(_ nsView: WKWebView, context: Context) {
            logger.debug("WebView更新")
        }
    }

    private class Coordinator: NSObject, WKNavigationDelegate {
        let url: URL
        let logger: MagicLogger
        let onLoadComplete: ((Error?) -> Void)?

        init(url: URL, logger: MagicLogger, onLoadComplete: ((Error?) -> Void)?) {
            self.url = url
            self.logger = logger
            self.onLoadComplete = onLoadComplete
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            logger.info("开始加载网页内容: \(url.absoluteString)")
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            logger.info("网页内容开始传输")
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            logger.info("✅ 网页加载完成: \(url.absoluteString)")
            onLoadComplete?(nil)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            logger.error("❌ 网页加载失败: \(error.localizedDescription)")
            onLoadComplete?(error)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            logger.error("❌ 网页预加载失败: \(error.localizedDescription)")
            onLoadComplete?(error)
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            logger.debug("请求加载URL: \(navigationAction.request.url?.absoluteString ?? "unknown")")
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if let httpResponse = navigationResponse.response as? HTTPURLResponse {
                logger.debug("收到响应: HTTP \(httpResponse.statusCode)")
            }
            decisionHandler(.allow)
        }
    }
#endif

#Preview("WebView Demo") {
    MagicWebViewDemo()
        .frame(height: 800)
}
