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
    public static var emoji: String { "🈳" }

    public func r(_ s: String) -> String { makeReason(s) }
    
    public func makeReason(_ s: String) -> String { " ➡️ " + s }
    
    public var author: String { Self.author }
    
    public var className: String { author }
    
    public var isMain: Bool { Thread.isMainThread }
    
    public var a: String { Self.a }
    public var i: String { Self.i }
    public var t: String { Self.t }
    
    public static var a: String { Self.onAppear }
    public static var i: String { Self.onInit }
    
    public static var author: String {
        let fullName = String(describing: Self.self)
        if let genericStart = fullName.firstIndex(of: "<") {
            return String(fullName[..<genericStart])
        }
        return fullName
    }
    public static var onAppear: String { "\(t)📺📺📺 OnAppear " }
    public static var onInit: String {  "\(t)🚩🚩🚩 Init " }
    public static var t: String {
        let emoji = Self.emoji
        let qos = Thread.current.qualityOfService
        let qosDesc = qosDescription(qos, withName: false)
            
        return "\(qosDesc) | \(emoji) \(author.padding(toLength: 20, withPad: " ", startingAt: 0)) | "
    }
    
    static public func qosDescription(_ qos: QualityOfService, withName: Bool = true) -> String {
        switch qos {
        case .userInteractive: return withName ? "🔥 UserInteractive" : "🔥"
        case .userInitiated: return withName ? "2️⃣ UserInitiated" : "2️⃣"
        case .default: return withName ? "3️⃣ Default" : "3️⃣"
        case .utility: return withName ? "4️⃣ Utility" : "4️⃣"
        case .background: return withName ? "5️⃣ Background" : "5️⃣"
        default: return withName ? "6️⃣ Unknown" : "6️⃣"
        }
    }

}
