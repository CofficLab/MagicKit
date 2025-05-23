#if os(iOS)
    import SwiftUI
    @preconcurrency import WebKit

    internal struct WebViewWrapper: UIViewRepresentable {
        let url: URL
        let logger: MagicLogger
        let onLoadComplete: ((Error?) -> Void)?
        let onJavaScriptError: ((String, Int, String) -> Void)?
        let onCustomMessage: ((Any) -> Void)?
        let isVerboseMode: Bool

        @Environment(WebViewStore.self) private var webViewStore

        func makeCoordinator() -> WebViewCoordinator {
            if isVerboseMode {
                logger.debug("创建 WebView Coordinator")
            }
            return WebViewCoordinator(
                url: url,
                logger: logger,
                onLoadComplete: onLoadComplete,
                onJavaScriptError: onJavaScriptError,
                onCustomMessage: onCustomMessage,
                isVerboseMode: isVerboseMode
            )
        }

        func makeUIView(context: Context) -> WKWebView {
            if isVerboseMode {
                logger.info("准备加载网页: \(url.absoluteString)")
            }

            let configuration = configureWebView(coordinator: context.coordinator, logger: logger)
            let webView = WKWebView(frame: .zero, configuration: configuration)
            webView.navigationDelegate = context.coordinator

            #if DEBUG
                if #available(iOS 16.4, *) {
                    webView.isInspectable = true
                }
            #endif

            if isVerboseMode {
                logger.debug("WebView 配置完成，准备加载内容")
            }
            webView.load(URLRequest(url: url))

            webViewStore.webView = webView
            return webView
        }

        func updateUIView(_ uiView: WKWebView, context: Context) {
            if isVerboseMode {
                logger.debug("WebView 更新")
            }
        }
    }
#endif
