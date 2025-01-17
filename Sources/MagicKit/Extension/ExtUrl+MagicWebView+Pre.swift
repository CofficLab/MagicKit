import SwiftUI

/// WebView功能演示视图
public struct MagicWebViewDemo: View {
    @State private var receivedMessages: [String] = []

    public init() {}

    public var body: some View {
        TabView {
            // 基本功能演示
            VStack {
                let webView = URL(string: "https://www.apple.com")!.makeWebView { error in
                    if let error = error {
                        MagicLogger.error("Apple.com加载失败: \(error.localizedDescription)")
                    } else {
                        MagicLogger.info("Apple.com加载完成")
                    }
                }

                webView
                    .showLogView(true)
            }
            .tabItem {
                Label("基本", systemImage: "globe")
            }

            // 错误处理演示
            VStack {
                let invalidWebView = URL(string: "file:///invalid")!.makeWebView { error in
                    if let error = error {
                        MagicLogger.shared.error("无效URL加载失败: \(error.localizedDescription)")
                    }
                }

                invalidWebView
            }
            .tabItem {
                Label("错误", systemImage: "exclamationmark.triangle")
            }

            // JavaScript错误演示
            VStack {
                // 包含JS错误的HTML
                let htmlWithError = """
                <html>
                <head>
                    <meta charset="utf-8">
                </head>
                <body>
                    <h1>JavaScript错误演示</h1>
                    <script>
                        // 立即执行一个错误
                        undefinedFunction();  // 这会立即触发一个错误

                        // 语法错误
                        const obj = {
                            name: "test",,  // 多余的逗号会导致语法错误
                        };
                    </script>
                </body>
                </html>
                """

                let url = URL(string: "data:text/html;base64," + Data(htmlWithError.utf8).base64EncodedString())!

                url.makeWebView(
                    onJavaScriptError: { message, line, source in
                        print("检测到 JS 错误！") // 添加调试输出
                        MagicLogger.shared.error("JavaScript错误检测到：")
                        MagicLogger.shared.error("- 消息: \(message)")
                        MagicLogger.shared.error("- 行号: \(line)")
                        MagicLogger.shared.error("- 来源: \(source)")
                    }
                )
                .showLogView(true)
            }
            .tabItem {
                Label("JS错误", systemImage: "exclamationmark.bubble")
            }

            // URL跳转演示
            VStack {
                let webView = URL(string: "https://www.apple.com")!.makeWebView()
                let newWebView = webView.goto(URL(string: "https://www.example.com")!)

                newWebView
                    .showLogView(true)
            }
            .tabItem {
                Label("URL跳转", systemImage: "arrow.right.circle")
            }

            // 控制台日志演示
            VStack {
                // 包含console.log的HTML
                let htmlWithConsoleLog = """
                <html>
                <head>
                    <meta charset="utf-8">
                </head>
                <body>
                    <h1>控制台日志演示</h1>
                    <script>
                        // 输出不同类型的日志
                        console.log('普通日志');
                        console.info('信息日志');
                        console.warn('警告日志');
                        console.error('错误日志');

                        // 定时输出日志
                        setInterval(() => {
                            console.log('每3秒输出一次：' + new Date().toLocaleTimeString());
                        }, 3000);

                        // 输出复杂对象
                        console.log('对象:', { 
                            name: 'test',
                            value: 123,
                            nested: {
                                array: [1, 2, 3]
                            }
                        });
                    </script>
                </body>
                </html>
                """

                let url = URL(string: "data:text/html;base64," + Data(htmlWithConsoleLog.utf8).base64EncodedString())!

                url.makeWebView(
                    onJavaScriptError: { message, line, source in
                        MagicLogger.shared.error("JavaScript错误：")
                        MagicLogger.shared.error("- 消息: \(message)")
                        MagicLogger.shared.error("- 行号: \(line)")
                        MagicLogger.shared.error("- 来源: \(source)")
                    }
                )
                .showLogView(true)
            }
            .tabItem {
                Label("控制台日志", systemImage: "terminal")
            }

            // JavaScript通信演示
            VStack {
                // 包含JavaScript通信示例的HTML
                let htmlWithJSCommunication = """
                <html>
                <head>
                    <meta charset="utf-8">
                    <style>
                        body { font-family: -apple-system, sans-serif; padding: 20px; }
                        button { 
                            padding: 10px 20px;
                            margin: 5px;
                            font-size: 16px;
                            border-radius: 8px;
                            border: none;
                            background-color: #007AFF;
                            color: white;
                            cursor: pointer;
                        }
                        button:active {
                            background-color: #0051A8;
                        }
                    </style>
                </head>
                <body>
                    <h2>JavaScript 与 Swift 通信演示</h2>

                    <button onclick="sendSimpleMessage()">发送简单消息</button>
                    <button onclick="sendJsonMessage()">发送JSON消息</button>
                    <button onclick="sendComplexData()">发送复杂数据</button>

                    <script>
                        // 发送简单消息
                        function sendSimpleMessage() {
                            window.webkit.messageHandlers.customMessage.postMessage("你好，Swift！");
                        }

                        // 发送JSON消息
                        function sendJsonMessage() {
                            window.webkit.messageHandlers.customMessage.postMessage({
                                type: "json",
                                data: {
                                    message: "这是一个JSON消息",
                                    timestamp: new Date().toISOString()
                                }
                            });
                        }

                        // 发送复杂数据
                        function sendComplexData() {
                            try {
                                const complexData = {
                                    type: "complexData",
                                    data: {
                                        numbers: [1, 2, 3, 4, 5],
                                        text: "复杂数据示例",
                                        nested: {
                                            bool: true,
                                            date: new Date().toISOString()
                                        }
                                    }
                                };
                                console.log("准备发送复杂数据:", JSON.stringify(complexData));
                                window.webkit.messageHandlers.customMessage.postMessage(complexData);
                                console.log("复杂数据发送完成");
                            } catch (error) {
                                console.error("发送复杂数据时出错:", error);
                                window.webkit.messageHandlers.jsError.postMessage({
                                    message: error.message,
                                    sourceURL: "sendComplexData",
                                    lineNumber: 0
                                });
                            }
                        }

                        // 页面加载完成后自动发送一条消息
                        window.onload = function() {
                            window.webkit.messageHandlers.customMessage.postMessage({
                                type: "pageLoad",
                                data: "页面加载完成！"
                            });
                        };
                    </script>
                </body>
                </html>
                """

                let url = URL(string: "data:text/html;base64," + Data(htmlWithJSCommunication.utf8).base64EncodedString())!

                let webView = url.makeWebView { error in
                    if let error = error {
                        MagicLogger.shared.error("演示页面加载失败: \(error.localizedDescription)")
                    } else {
                        MagicLogger.shared.info("演示页面加载成功")
                    }
                } onJavaScriptError: { message, line, source in
                    MagicLogger.shared.error("JavaScript错误:")
                    MagicLogger.shared.error("- 消息: \(message)")
                    MagicLogger.shared.error("- 行号: \(line)")
                    MagicLogger.shared.error("- 来源: \(source)")
                } onCustomMessage: { message in
                    MagicLogger.shared.debug("收到消息: \(String(describing: message))")
                }

                webView
                    .showLogView(true)
            }
            .tabItem {
                Label("JS通信", systemImage: "message")
            }
        }
    }
}

// MARK: - Previews

#Preview("WebView Demo") {
    MagicWebViewDemo()
        .frame(height: 800)
}
