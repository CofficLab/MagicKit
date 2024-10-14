import Foundation
import OSLog
import WebKit

/// 负责渲染 Web 内容，与 JS 交互等
public class WebContent: WKWebView, SuperLog, SuperThread {
    let emoji = "🛜"

    // MARK: 执行JS代码

    @discardableResult
    public func run(_ jsCode: String) async throws -> Any {
        let verbose: Bool = false

        let code = jsCode.noSpaces()

        guard code.isNotEmpty else {
            return os_log("\(self.t)执行JS代码，代码为空，放弃执行")
        }

        if verbose {
            os_log("\(self.t)JS Code: \(code)")
        }

        return try await self.evaluateJavaScriptAsync(code) ?? ""
    }

    // https://forums.developer.apple.com/forums/thread/701553
    @discardableResult
    public func evaluateJavaScriptAsync(_ str: String) async throws -> Any? {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Any?, Error>) in
            DispatchQueue.main.async {
                self.evaluateJavaScript(str) { data, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: data)
                    }
                }
            }
        }
    }
}
