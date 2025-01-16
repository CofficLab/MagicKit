import SwiftUI

/// WebView功能演示视图
public struct MagicWebViewDemo: View {
    public init() {}

    public var body: some View {
        TabView {
            // 1. 基本功能演示
            NavigationStack {
                VStack {
                    Group {
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
                }
            }
            .tabItem {
                Label("基本功能", systemImage: "globe")
            }

            // 2. 日志视图控制演示
            NavigationStack {
                VStack {
                    Group {
                        Text("带日志的WebView").font(.headline)
                        URL(string: "https://www.example.com")!
                            .makeWebView()
                            .showLogView(true)

                        Text("不带日志的WebView").font(.headline)
                        URL(string: "https://www.example.com")!
                            .makeWebView()
                            .showLogView(false)
                    }
                }
            }
            .tabItem {
                Label("日志控制", systemImage: "doc.text.magnifyingglass")
            }

            // 3. 错误处理演示
            NavigationStack {
                VStack {
                    Group {
                        let invalidWebView = URL(string: "file:///invalid")!.makeWebView { error in
                            if let error = error {
                                MagicLogger.shared.error("无效URL加载失败: \(error.localizedDescription)")
                            }
                        }

                        invalidWebView
                            .showLogView(true)
                            .frame(height: 200)
                    }
                }
                .navigationTitle("错误处理")
            }
            .tabItem {
                Label("错误处理", systemImage: "exclamationmark.triangle")
            }

            // 4. 多WebView演示
            NavigationStack {
                VStack {
                    Section("多WebView") {
                        VStack(spacing: 20) {
                            Group {
                                Text("WebView 1 (带日志)").font(.headline)
                                URL(string: "https://www.apple.com")!
                                    .makeWebView()
                                    .showLogView(true)
                                    .frame(height: 300)
                            }

                            Divider()

                            Group {
                                Text("WebView 2 (不带日志)").font(.headline)
                                URL(string: "https://www.example.com")!
                                    .makeWebView()
                                    .showLogView(false)
                                    .frame(height: 200)
                            }
                        }
                        .padding(.vertical)
                    }
                }
                .navigationTitle("多WebView")
            }
            .tabItem {
                Label("多WebView", systemImage: "square.grid.2x2")
            }

            // 5. JavaScript错误演示
            NavigationStack {
                VStack {
                    Group {
                        Text("JavaScript错误演示").font(.headline)
                        
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
                }
                .navigationTitle("JS错误")
            }
            .tabItem {
                Label("JS错误", systemImage: "exclamationmark.bubble")
            }
            
            // 6. URL跳转演示
            NavigationStack {
                VStack {
                    Group {
                        Text("URL跳转演示").font(.headline)
                        
                        let webView = URL(string: "https://www.apple.com")!.makeWebView()
                        let newWebView = webView.goto(URL(string: "https://www.example.com")!)
                        
                        newWebView
                            .showLogView(true)
                    }
                }
                .navigationTitle("URL跳转")
            }
            .tabItem {
                Label("URL跳转", systemImage: "arrow.right.circle")
            }
        }
    }
}

// MARK: - Previews

#Preview("WebView Demo") {
    MagicWebViewDemo()
        .frame(height: 800)
}
