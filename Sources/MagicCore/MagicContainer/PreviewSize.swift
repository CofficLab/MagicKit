import SwiftUI

enum PreviewSize: String, CaseIterable {
    case full = "全屏"
    case iPhoneSE = "iPhone SE"
    case iPhone = "iPhone 14"
    case iPhonePlus = "iPhone 14 Plus"
    case iPhoneMax = "iPhone 14 Pro Max"
    case iPadMini = "iPad mini"
    case iPad = "iPad"
    case iPadPro11 = "iPad Pro 11"
    case iPadPro12 = "iPad Pro 12.9"
    case mac = "Mac"
    
    var size: CGSize {
        switch self {
        case .full:
            return CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
        case .iPhoneSE:
            return .iPhoneSE
        case .iPhone:
            return .iPhone
        case .iPhonePlus:
            return .iPhonePlus
        case .iPhoneMax:
            return .iPhoneMax
        case .iPadMini:
            return .iPadMini
        case .iPad:
            return .iPad
        case .iPadPro11:
            return .iPadPro11
        case .iPadPro12:
            return .iPadPro12
        case .mac:
            return .mac
        }
    }
    
    var icon: String {
        switch self {
        case .full:
            return "rectangle"
        case .iPhoneSE, .iPhone, .iPhonePlus, .iPhoneMax:
            return "iphone"
        case .iPadMini, .iPad, .iPadPro11, .iPadPro12:
            return "ipad"
        case .mac:
            return "desktopcomputer"
        }
    }
    
    var dimensions: String {
        let size = self.size
        if size.width == .infinity || size.height == .infinity {
            return "自适应"
        }
        return String(format: "%.0f × %.0f", size.width, size.height)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("MagicThemePreviewPreview") {
    MagicContainerPreview()
}
#endif
