import SwiftUI
@preconcurrency import WebKit

public struct MagicWebView: View {
    internal let url: URL
    internal let onLoadComplete: ((Error?) -> Void)?
    internal let onJavaScriptError: ((String, Int, String) -> Void)?
    internal let onCustomMessage: ((Any) -> Void)?
    private var logger = MagicLogger.shared
    private let showLogView: Bool

    public init(
        url: URL,
        showLogView: Bool = false,
        onLoadComplete: ((Error?) -> Void)? = nil,
        onJavaScriptError: ((String, Int, String) -> Void)? = nil,
        onCustomMessage: ((Any) -> Void)? = nil
    ) {
        self.url = url
        self.showLogView = showLogView
        self.onLoadComplete = onLoadComplete
        self.onJavaScriptError = onJavaScriptError
        self.onCustomMessage = onCustomMessage
        logger.info("创建 WebView: \(url.absoluteString)")
    }

    public var body: some View {
        VStack(spacing: 0) {
            if url.canOpenInWebView {
                #if os(iOS)
                    WebViewWrapper(
                        url: url, 
                        logger: logger, 
                        onLoadComplete: onLoadComplete,
                        onJavaScriptError: onJavaScriptError,
                        onCustomMessage: onCustomMessage
                    )
                    .onAppear {
                        logger.debug("WebView 视图显示")
                    }
                    .onDisappear {
                        logger.debug("WebView 视图消失")
                    }
                #elseif os(macOS)
                    MacWebViewWrapper(
                        url: url, 
                        logger: logger, 
                        onLoadComplete: onLoadComplete,
                        onJavaScriptError: onJavaScriptError,
                        onCustomMessage: onCustomMessage
                    )
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

internal class WebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    let url: URL
    let logger: MagicLogger
    let onLoadComplete: ((Error?) -> Void)?
    let onJavaScriptError: ((String, Int, String) -> Void)?
    let onCustomMessage: ((Any) -> Void)?
    
    init(
        url: URL,
        logger: MagicLogger,
        onLoadComplete: ((Error?) -> Void)?,
        onJavaScriptError: ((String, Int, String) -> Void)?,
        onCustomMessage: ((Any) -> Void)?
    ) {
        self.url = url
        self.logger = logger
        self.onLoadComplete = onLoadComplete
        self.onJavaScriptError = onJavaScriptError
        self.onCustomMessage = onCustomMessage
        super.init()
        logger.debug("Coordinator 初始化完成")
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        logger.info("开始加载网页: \(url.absoluteString)")
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        logger.info("网页内容开始传输")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        logger.info("网页加载完成")
        onLoadComplete?(nil)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        logger.error("网页加载失败: \(error.localizedDescription)")
        onLoadComplete?(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        logger.error("网页预加载失败: \(error.localizedDescription)")
        onLoadComplete?(error)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "jsError":
            if let body = message.body as? [String: Any],
               let errorMessage = body["message"] as? String,
               let lineNumber = body["lineNumber"] as? Int,
               let sourceURL = body["sourceURL"] as? String {
                logger.error("JavaScript错误: \(errorMessage) at line \(lineNumber) in \(sourceURL)")
                onJavaScriptError?(errorMessage, lineNumber, sourceURL)
            }
        case "consoleLog":
            if let body = message.body as? [String: Any],
               let level = body["level"] as? String,
               let logMessage = body["message"] as? String {
                switch level {
                case "error":
                    logger.error("JS Console: \(logMessage)")
                case "warn":
                    logger.warning("JS Console: \(logMessage)")
                case "info":
                    logger.info("JS Console: \(logMessage)")
                default:
                    logger.debug("JS Console: \(logMessage)")
                }
            }
        case "customMessage":
            logger.debug("收到自定义消息: \(message.body)")
            onCustomMessage?(message.body)
        default:
            logger.warning("未知的消息类型: \(message.name)")
        }
    }
}

internal func configureWebView(coordinator: WebViewCoordinator, logger: MagicLogger) -> WKWebViewConfiguration {
    let configuration = WKWebViewConfiguration()
    let userContentController = WKUserContentController()
    
    // 注入错误捕获和日志捕获脚本
    let script = """
        (function() {
            console.log('初始化错误和日志捕获');
            
            // 全局错误处理
            window.onerror = function(msg, url, line, col, error) {
                console.log('捕获到全局错误:', msg);
                window.webkit.messageHandlers.jsError.postMessage({
                    message: msg,
                    sourceURL: url,
                    lineNumber: line
                });
                return true;
            };
            
            // 语法错误和运行时错误处理
            window.addEventListener('error', function(event) {
                console.log('捕获到错误事件:', event.message);
                window.webkit.messageHandlers.jsError.postMessage({
                    message: event.message,
                    sourceURL: event.filename,
                    lineNumber: event.lineno
                });
                return true;
            });
            
            // Promise 错误处理
            window.addEventListener('unhandledrejection', function(event) {
                console.log('捕获到 Promise 错误:', event.reason);
                window.webkit.messageHandlers.jsError.postMessage({
                    message: event.reason.toString(),
                    sourceURL: 'Promise',
                    lineNumber: 0
                });
            });
            
            // 重写所有控制台方法
            const originalConsole = {
                log: console.log,
                info: console.info,
                warn: console.warn,
                error: console.error,
                debug: console.debug
            };
            
            function stringifyArg(arg) {
                if (typeof arg === 'undefined') return 'undefined';
                if (arg === null) return 'null';
                if (typeof arg === 'object') {
                    try {
                        return JSON.stringify(arg);
                    } catch (e) {
                        return arg.toString();
                    }
                }
                return String(arg);
            }
            
            ['log', 'info', 'warn', 'error', 'debug'].forEach(function(level) {
                console[level] = function() {
                    const args = Array.from(arguments).map(stringifyArg).join(' ');
                    window.webkit.messageHandlers.consoleLog.postMessage({
                        level: level,
                        message: args
                    });
                    originalConsole[level].apply(console, arguments);
                };
            });
        })();
    """
    
    let userScript = WKUserScript(
        source: script,
        injectionTime: .atDocumentStart,
        forMainFrameOnly: false
    )
    
    userContentController.addUserScript(userScript)
    userContentController.add(coordinator, name: "jsError")
    userContentController.add(coordinator, name: "consoleLog")
    userContentController.add(coordinator, name: "customMessage")
    
    configuration.userContentController = userContentController
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
    configuration.preferences.javaScriptEnabled = true
    
    if #available(iOS 14.0, macOS 11.0, *) {
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
    }
    
    logger.debug("WebView 配置完成")
    return configuration
} 