import Foundation
import OSLog
import SwiftUI
@preconcurrency import WebKit

/// WebView的代理类，处理导航、权限请求和用户交互
///
/// 这个类实现了WKUIDelegate和WKNavigationDelegate协议，用于处理WebView的各种事件，
/// 包括页面导航、重定向、文件上传、媒体权限请求等。同时作为ObservableObject，可以在SwiftUI中使用。
///
/// ## 主要功能:
/// - 处理页面导航和重定向事件
/// - 处理文件上传请求
/// - 处理媒体捕获权限请求
/// - 提供导航状态更新
class WebViewDelegate: NSObject, WKUIDelegate, ObservableObject, WKNavigationDelegate {
    /// 用于打开外部链接的环境变量
    @Environment(\.openURL) var openURL

    /// 处理服务器重定向事件
    /// 
    /// 当WebView收到服务器重定向时调用此方法
    /// 
    /// - Parameters:
    ///   - webView: 发生重定向的WebView
    ///   - navigation: 相关的导航对象
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("didReceiveServerRedirectForProvisionalNavigation")
    }

    /// 处理媒体捕获权限请求
    /// 
    /// 当网页请求访问摄像头或麦克风等媒体设备时调用此方法
    /// 
    /// - Parameters:
    ///   - webView: 请求权限的WebView
    ///   - origin: 请求权限的网页源
    ///   - frame: 发起请求的框架
    ///   - type: 请求的媒体捕获类型（如摄像头、麦克风）
    ///   - decisionHandler: 用于返回权限决定的回调
    func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        print("requestMediaCapturePermissionFor")
    }

    /// 处理页面开始加载事件
    /// 
    /// 当WebView开始加载页面时调用此方法
    /// 
    /// - Parameters:
    ///   - webView: 开始加载的WebView
    ///   - navigation: 相关的导航对象
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation")
    }

    // MARK: 文件上传

    #if os(macOS)
    /// 处理文件上传请求（macOS平台）
    /// 
    /// 当网页触发文件上传操作时，显示系统文件选择面板
    /// 
    /// - Parameters:
    ///   - webView: 请求文件上传的WebView
    ///   - parameters: 文件选择参数，包括是否允许多选和选择文件夹
    ///   - frame: 发起请求的框架
    ///   - completionHandler: 用于返回选择的文件URL的回调
    func webView(
        _ webView: WKWebView,
        runOpenPanelWith parameters: WKOpenPanelParameters,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping ([URL]?) -> Void
    ) {
        os_log("上传文件\n允许多个：\(parameters.allowsMultipleSelection)\n允许文件夹：\(parameters.allowsDirectories)")

        let panel = NSOpenPanel()

        panel.allowsMultipleSelection = parameters.allowsMultipleSelection
        panel.canChooseDirectories = parameters.allowsDirectories

        panel.beginSheetModal(for: webView.window!) { response in
            if response == .OK {
                let urls = panel.urls

                os_log("选择的文件是：\n\(urls)")
                completionHandler(urls)
            } else {
                os_log("取消了选择文件")
                completionHandler(nil)
            }
        }
    }
    #endif

    // 在新标签中打开链接
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        print("createWebViewWith -> \(navigationAction.request)")
        if let url = navigationAction.request.url {
            openURL(url)
        } else {
            print("链接为空")
        }
        return nil
    }

    // 在当前标签打开链接
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("打开链接")
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                openURL(url)
                decisionHandler(.cancel)
            }
        } else {
            // other navigation type, such as reload, back or forward buttons
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
        print("WKNavigationResponse")
        return WKNavigationResponsePolicy.allow
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        print("runJavaScriptTextInputPanelWithPrompt")
        completionHandler("https://www.apple.com")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webview did finish")

        webView.navigationDelegate = self
    }

    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        print("WKNavigationAction")
    }

    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        print("WKNavigationResponse")
    }
}
