import Foundation
import SwiftUI
import OSLog
import SwiftData

public protocol SuperLog {
    static var emoji: String { get }
    static var t: String { get }
    static var author: String { get }
}

extension SuperLog {
    public func r(_ s: String) -> String { makeReason(s) }
    
    public func makeReason(_ s: String) -> String { " ➡️ " + s }
    
    public var author: String { Self.author }
    
    public static var author: String { String(describing: Self.self) }
    
    public var className: String { author }
    
    public var isMain: Bool { Thread.isMainThread }
    
    public static var i: String {  "\(t)Init 🚩🚩🚩" }
    
    public var i: String { Self.i }
    
    public var t: String { Self.t }
    
    public static var t: String {
        let emoji = Self.emoji
        let qos = Thread.current.qualityOfService
        let qosDesc = Logger.qosDescription(qos, withName: false)
            
        return "\(qosDesc) | \(emoji) \(author.padding(toLength: 20, withPad: " ", startingAt: 0)) | "
    }
}
