import Foundation
import OSLog

public class HttpClient: SuperLog {
    let emoji = "🛞"
    var url: URL
    var headers: [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json",
    ]
    var body: [String:Any]=[:]

    init(url: URL) {
        self.url = url
    }
    
    func withHeaders(_ headers: [String:String]) -> Self {
        self.headers = headers
        return self
    }
    
    func withHeader(_ key: String, _ value: String) -> Self {
        headers.updateValue(value, forKey: key)
        return self
    }

    func withToken(_ token: String) -> Self {
        self.withHeader("Authorization", "Bearer \(token)")
    }
    
    func withBody(_ body: [String:Any]) -> Self {
        self.body = body
        return self
    }

    func get() async throws -> String {
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

    func getDataAndResponse() async throws -> (Data, HTTPURLResponse) {
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

    func delete() async throws {
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

    func post() async throws -> String {
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

    func patch() async throws -> String {
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

    func put() async throws -> String {
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
}
