import Foundation
import OSLog
import SwiftUI
import WebKit

class WKDelegate: NSObject, WKUIDelegate, ObservableObject, WKNavigationDelegate {
    @Environment(\.openURL) var openURL

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("didReceiveServerRedirectForProvisionalNavigation")
    }

    func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        print("requestMediaCapturePermissionFor")
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation")
    }

    // MARK: 文件上传

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
//        EventProvider().emitRunJavaScriptTextInputPanelWithPrompt()
//        completionHandler("https://www.apple.com")
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
