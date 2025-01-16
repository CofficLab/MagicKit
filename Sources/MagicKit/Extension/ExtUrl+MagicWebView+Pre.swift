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
                                MagicLogger.shared.error("Apple.com加载失败: \(error.localizedDescription)")
                            } else {
                                MagicLogger.shared.info("Apple.com加载完成")
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
        }
    }
}

// MARK: - Previews

#Preview("WebView Demo") {
    MagicWebViewDemo()
        .frame(height: 800)
}
