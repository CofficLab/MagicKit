import Foundation

enum HttpError: Error,LocalizedError {
    case ShellError(output: String)
    case HttpNoResponse
    case HttpStatusError(Int)
    case HttpNoData
    
    var errorDescription: String? {
        switch self {
        case .ShellError(let output):
            return output
        case .HttpNoResponse:
            return "HTTP 请求失败，没有响应"
        case .HttpStatusError(let code):
            return "HTTP 请求失败，状态码: \(code)"
        case .HttpNoData:
            return "HTTP 请求失败，没有数据"
        }
    }
}

