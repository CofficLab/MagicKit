import Foundation

extension QualityOfService {
    public func description(withName: Bool = true) -> String {
        switch self {
        case .userInteractive: return withName ? "🔥 UserInteractive" : "🔥"
        case .userInitiated: return withName ? "2️⃣ UserInitiated" : "2️⃣"
        case .default: return withName ? "3️⃣ Default" : "3️⃣"
        case .utility: return withName ? "4️⃣ Utility" : "4️⃣"
        case .background: return withName ? "5️⃣ Background" : "5️⃣"
        default: return withName ? "6️⃣ Unknown" : "6️⃣"
        }
    }
}
