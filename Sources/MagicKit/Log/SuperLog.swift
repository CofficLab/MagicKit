import Foundation
import SwiftUI
import OSLog
import SwiftData

public protocol SuperLog {
}

extension SuperLog {
    func r(_ s: String) -> String {
        makeReason(s)
    }
    
    func makeReason(_ s: String) -> String {
        " ➡️ " + s
    }
    
    var author: String {
        String(describing: type(of: self))
    }
    
    var className: String { author }
    
    var functionName: String {
        String(describing: #function).components(separatedBy: "(").first ?? #function
    }
    
    var isMain: String {
        "\(Thread.isMainThread ? "🔥 " : "")"
    }
    
    var thread: String {
        Thread.current.name ?? "-"
    }
    
    public var t: String {
        var emoji = "🈳"
        
        if let nameProperty = Mirror(reflecting: self).children.first(where: { $0.label == "emoji" }) {
            emoji = nameProperty.value as! String
        }
        
        return "\(isMain)\(emoji) \(author)::"
    }
    
    func i(_ message: String) -> String {
        "\(t)::\(message)"
    }
}
