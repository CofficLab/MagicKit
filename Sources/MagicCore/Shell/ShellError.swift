import SwiftUI

enum ShellError: Error, LocalizedError {
    case commandFailed(String, String)

    var errorDescription: String? {
        switch self {
        case let .commandFailed(output, command):
            return "Command failed with output: \n\(output)\nCommand: \n\(command)"
        }
    }
}
