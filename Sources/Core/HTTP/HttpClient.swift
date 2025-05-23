import Foundation
import OSLog

/// A lightweight HTTP client that supports common HTTP methods with fluent interface.
/// Example usage:
/// ```swift
/// let client = HttpClient(url: URL(string: "https://api.example.com")!)
///     .withToken("your-token")
///     .withBody(["key": "value"])
/// let response = try await client.post()
/// ```
public class HttpClient: SuperLog {
    public static let emoji = "🛞"
    private var url: URL
    private var headers: [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json",
    ]
    private var body: [String:Any] = [:]
    private var timeoutInterval: TimeInterval = 30
    private var task: URLSessionDataTask?
    
    public init(url: URL) {
        self.url = url
    }
    
    /// Sets request timeout interval in seconds
    /// - Parameter timeout: The timeout interval in seconds
    /// - Returns: Self for method chaining
    public func withTimeout(_ timeout: TimeInterval) -> Self {
        self.timeoutInterval = timeout
        return self
    }
    
    /// Cancels any ongoing request
    public func cancel() {
        task?.cancel()
    }
    
    public func withHeaders(_ headers: [String:String]) -> Self {
        self.headers = headers
        return self
    }
    
    public func withHeader(_ key: String, _ value: String) -> Self {
        headers.updateValue(value, forKey: key)
        return self
    }

    public func withToken(_ token: String) -> Self {
        self.withHeader("Authorization", "Bearer \(token)")
    }
    
    public func withBody(_ body: [String:Any]) -> Self {
        self.body = body
        return self
    }

    public func get() async throws -> String {
        var request = URLRequest(url: url)
        let session = URLSession.shared

        request.httpMethod = "GET"
        
        // 设置请求头
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HttpError.HttpNoResponse
        }

        guard httpResponse.statusCode == 200 else {
            os_log(.error, "\(self.t)Http Error -> \(httpResponse.statusCode)")
            os_log(.error, "\(self.t)Http URL -> \(self.url.absoluteString)")
            printHttpError(data, httpResponse: httpResponse)
            throw HttpError.HttpStatusError(httpResponse.statusCode)
        }

        guard let responseString = String(data: data, encoding: .utf8) else {
            throw HttpError.HttpNoData
        }

        return responseString
    }

    public func getDataAndResponse() async throws -> (Data, HTTPURLResponse) {
        var request = URLRequest(url: url)
        let session = URLSession.shared

        request.httpMethod = "GET"
        
        // 设置请求头
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HttpError.HttpNoResponse
        }

        return (data, httpResponse)
    }

    public func delete() async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        // 设置请求头
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // 设置请求体
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode != 200 {
                os_log(.error, "\(self.t)Http Error -> \(httpResponse.statusCode)")
                os_log(.error, "\(self.t)Http Error -> DELETE \(self.url)")
                printHttpError(data, httpResponse: httpResponse)
                throw HttpError.HttpStatusError(httpResponse.statusCode)
            }
        } else {
            throw HttpError.HttpNoData
        }
    }

    @discardableResult
    public func post() async throws -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // 设置请求头
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // 设置请求体
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HttpError.HttpNoResponse
        }

        guard httpResponse.statusCode.isHttpOkCode() else {
            os_log(.error, "\(self.t)Http Error -> \(httpResponse.statusCode)")
            os_log(.error, "\(self.t)Post -> \(self.url)")
            os_log(.error, "\(self.t)Headers -> \(self.headers)")
            printHttpError(data, httpResponse: httpResponse)
            throw HttpError.HttpStatusError(httpResponse.statusCode)
        }

        guard let responseString = String(data: data, encoding: .utf8) else {
            throw HttpError.HttpNoData
        }

        return responseString
    }

    @discardableResult
    public func patch() async throws -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"

        // 设置请求头
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // 设置请求体
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HttpError.HttpNoResponse
        }

        guard httpResponse.statusCode.isHttpOkCode() else {
            os_log(.error, "\(self.t)Http Error -> \(httpResponse.statusCode)")
            os_log(.error, "\(self.t)Patch -> \(self.url)")
            os_log(.error, "\(self.t)Headers -> \(self.headers)")
            printHttpError(data, httpResponse: httpResponse)
            throw HttpError.HttpStatusError(httpResponse.statusCode)
        }

        guard let responseString = String(data: data, encoding: .utf8) else {
            throw HttpError.HttpNoData
        }

        return responseString
    }

    @discardableResult
    public func put() async throws -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        // 设置请求头
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // 设置请求体
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HttpError.HttpNoResponse
        }
        
        guard httpResponse.statusCode.isHttpOkCode() else {
            os_log(.error, "\(self.t)Http Error -> \(httpResponse.statusCode)")
            os_log(.error, "\(self.t)Put -> \(self.url)")
            os_log(.error, "\(self.t)Headers -> \(self.headers)")
            printHttpError(data, httpResponse: httpResponse)
            throw HttpError.HttpStatusError(httpResponse.statusCode)
        }

        guard let responseString = String(data: data, encoding: .utf8) else {
            throw HttpError.HttpNoData
        }

        return responseString
    }

    func printHttpError(_ data: Data?, httpResponse: HTTPURLResponse) {
        if let data = data {
            let str = String(data: data, encoding: .utf8)
            os_log(.error, "\(self.t)\(str!)")
        } else {
            os_log("\(self.t)返回内容为空")
        }
    }

    private func executeRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        var urlRequest = request
        urlRequest.timeoutInterval = timeoutInterval
        
        let session = URLSession.shared
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HttpError.HttpNoResponse
        }
        
        if !httpResponse.statusCode.isHttpOkCode() {
            os_log(.error, "\(self.t)Http Error -> \(httpResponse.statusCode)")
            os_log(.error, "\(self.t)URL -> \(self.url.absoluteString)")
            os_log(.error, "\(self.t)Headers -> \(self.headers)")
            printHttpError(data, httpResponse: httpResponse)
            throw HttpError.HttpStatusError(httpResponse.statusCode)
        }
        
        return (data, httpResponse)
    }
}
