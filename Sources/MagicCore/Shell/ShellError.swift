import SwiftUI

enum ShellError: Error, LocalizedError {
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case let .commandFailed(output):
            return "Command failed with output: \(output)"
        }
    }
}
