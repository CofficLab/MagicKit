import SwiftUI
@preconcurrency import WebKit

public struct MagicWebView: View {
    internal let url: URL
    internal let onLoadComplete: ((Error?) -> Void)?
    internal let onJavaScriptError: ((String, Int, String) -> Void)?
    private var logger = MagicLogger.shared
    private let showLogView: Bool

    public init(
        url: URL,
        showLogView: Bool = false,
        onLoadComplete: ((Error?) -> Void)? = nil,
        onJavaScriptError: ((String, Int, String) -> Void)? = nil
    ) {
        self.url = url
        self.showLogView = showLogView
        self.onLoadComplete = onLoadComplete
        self.onJavaScriptError = onJavaScriptError
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
                        onJavaScriptError: onJavaScriptError
                    )
                    .onAppear {
                        logger.debug("WebView 视图显示")
                    }
                    .onDisappear {
                        logger.debug("WebView 视图消失")
                    }
                #elseif os(macOS)
                    MacWebViewWrapper(url: url, logger: logger, onLoadComplete: onLoadComplete, onJavaScriptError: onJavaScriptError)
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
        let onJavaScriptError: ((String, Int, String) -> Void)?

        func makeCoordinator() -> Coordinator {
            logger.debug("创建 WebView Coordinator")
            return Coordinator(
                url: url, 
                logger: logger, 
                onLoadComplete: onLoadComplete,
                onJavaScriptError: onJavaScriptError
            )
        }

        func makeUIView(context: Context) -> WKWebView {
            logger.info("🔄 准备加载网页: \(url.absoluteString)")
            
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
            userContentController.add(context.coordinator, name: "jsError")
            userContentController.add(context.coordinator, name: "consoleLog")
            
            configuration.userContentController = userContentController
            configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
            
            let webView = WKWebView(frame: .zero, configuration: configuration)
            webView.navigationDelegate = context.coordinator
            
            // 启用所有需要的 WebKit 功能
            webView.configuration.preferences.javaScriptEnabled = true
            webView.configuration.preferences.setValue(true, forKey: "allowsContentJavaScript")
            webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
            
            if #available(iOS 14.0, macOS 11.0, *) {
                webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
            }
            
            #if DEBUG
            if #available(iOS 16.4, macOS 13.3, *) {
                webView.isInspectable = true
            }
            #endif
            
            logger.debug("WebView 配置完成，准备加载内容")
            webView.load(URLRequest(url: url))
            
            return webView
        }

        func updateUIView(_ uiView: WKWebView, context: Context) {
            logger.debug("WebView 更新")
        }
    }

    private class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let url: URL
        let logger: MagicLogger
        let onLoadComplete: ((Error?) -> Void)?
        let onJavaScriptError: ((String, Int, String) -> Void)?
        
        init(url: URL, logger: MagicLogger, onLoadComplete: ((Error?) -> Void)?, onJavaScriptError: ((String, Int, String) -> Void)?) {
            self.url = url
            self.logger = logger
            self.onLoadComplete = onLoadComplete
            self.onJavaScriptError = onJavaScriptError
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
            logger.info("网页加载完成: \(url.absoluteString)")
            onLoadComplete?(nil)
            logger.debug("页面加载完成")
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            logger.error("页面加载失败: \(error.localizedDescription)")
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

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case "jsError":
                handleJSError(message)
            case "consoleLog":
                handleConsoleLog(message)
            default:
                logger.debug("收到未知消息: \(message.name)")
            }
        }
        
        private func handleJSError(_ message: WKScriptMessage) {
            logger.debug("收到 JS 错误消息: \(message.body)")
            
            if let body = message.body as? [String: Any] {
                logger.debug("JS 错误详情: \(body)")
                
                let errorMessage = (body["message"] as? String) ?? "未知错误"
                let lineNumber = (body["lineNumber"] as? Int) ?? 0
                let sourceURL = (body["sourceURL"] as? String) ?? "未知来源"
                
                logger.error("JavaScript错误:")
                logger.error("- 消息: \(errorMessage)")
                logger.error("- 行号: \(lineNumber)")
                logger.error("- 来源: \(sourceURL)")
                
                onJavaScriptError?(errorMessage, lineNumber, sourceURL)
            }
        }
        
        private func handleConsoleLog(_ message: WKScriptMessage) {
            guard let body = message.body as? [String: Any],
                  let level = body["level"] as? String,
                  let logMessage = body["message"] as? String else {
                return
            }
            
            switch level {
            case "log":
                logger.info("Console: \(logMessage)")
            case "info":
                logger.info("Console: \(logMessage)")
            case "warn":
                logger.warning("Console: \(logMessage)" )
            case "error":
                logger.error("Console: \(logMessage)")
            case "debug":
                logger.debug("Console: \(logMessage)")
            default:
                logger.info("Console: \(logMessage)"    )
            }
        }
    }

#elseif os(macOS)
    private struct MacWebViewWrapper: NSViewRepresentable {
        let url: URL
        let logger: MagicLogger
        let onLoadComplete: ((Error?) -> Void)?
        let onJavaScriptError: ((String, Int, String) -> Void)?

        func makeCoordinator() -> Coordinator {
            Coordinator(
                url: url, 
                logger: logger, 
                onLoadComplete: onLoadComplete,
                onJavaScriptError: onJavaScriptError
            )
        }

        func makeNSView(context: Context) -> WKWebView {
            logger.info("准备加载网页: \(url.absoluteString)")
            
            let configuration = WKWebViewConfiguration()
            let userContentController = WKUserContentController()
            
            // 注入错误捕获和日志捕获脚本
            let script = """
                (function() {
                    console.log('安装错误和日志处理器');
                    
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
                    
                    // 错误处理
                    window.onerror = function(msg, url, line) {
                        window.webkit.messageHandlers.jsError.postMessage({
                            message: msg,
                            sourceURL: url,
                            lineNumber: line
                        });
                        return true;
                    };
                    
                    // 控制台日志处理
                    const originalConsole = {
                        log: console.log,
                        info: console.info,
                        warn: console.warn,
                        error: console.error,
                        debug: console.debug
                    };
                    
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
            userContentController.add(context.coordinator, name: "jsError")
            userContentController.add(context.coordinator, name: "consoleLog")
            configuration.userContentController = userContentController
            
            let webView = WKWebView(frame: .zero, configuration: configuration)
            webView.navigationDelegate = context.coordinator
            webView.load(URLRequest(url: url))
            
            logger.debug("WebView已创建并开始加载")
            return webView
        }

        func updateNSView(_ nsView: WKWebView, context: Context) {
            logger.debug("WebView更新")
        }
    }

    private class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let url: URL
        let logger: MagicLogger
        let onLoadComplete: ((Error?) -> Void)?
        let onJavaScriptError: ((String, Int, String) -> Void)?

        init(url: URL, logger: MagicLogger, onLoadComplete: ((Error?) -> Void)?, onJavaScriptError: ((String, Int, String) -> Void)?) {
            self.url = url
            self.logger = logger
            self.onLoadComplete = onLoadComplete
            self.onJavaScriptError = onJavaScriptError
            super.init()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            logger.info("网页加载完成: \(url.absoluteString)")
            onLoadComplete?(nil)
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case "jsError":
                if let body = message.body as? [String: Any],
                   let errorMessage = body["message"] as? String,
                   let lineNumber = body["lineNumber"] as? Int,
                   let sourceURL = body["sourceURL"] as? String {
                    logger.error("JavaScript错误:")
                    logger.error("- 消息: \(errorMessage)")
                    logger.error("- 行号: \(lineNumber)")
                    logger.error("- 来源: \(sourceURL)")
                    
                    onJavaScriptError?(errorMessage, lineNumber, sourceURL)
                }
            case "consoleLog":
                if let body = message.body as? [String: Any],
                   let level = body["level"] as? String,
                   let logMessage = body["message"] as? String {
                    switch level {
                    case "log":
                        logger.info("Console: \(logMessage)")
                    case "info":
                        logger.info("Console: \(logMessage)")
                    case "warn":
                        logger.warning("Console: \(logMessage)")
                    case "error":
                        logger.error("Console: \(logMessage)")
                    case "debug":
                        logger.debug("Console: \(logMessage)")
                    default:
                        logger.info("Console: \(logMessage)")
                    }
                }
            default:
                logger.debug("收到未知消息: \(message.name)")
            }
        }
    }
#endif

#Preview("WebView Demo") {
    MagicWebViewDemo()
        .frame(height: 800)
}
