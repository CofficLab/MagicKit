import SwiftUI

/// Toast类型定义
public enum MagicToastType {
    case info
    case success
    case warning
    case error
    case loading
    case custom(systemImage: String, color: Color)
    
    var systemImage: String {
        switch self {
        case .info:
            return "info.circle"
        case .success:
            return "checkmark.circle"
        case .warning:
            return "exclamationmark.triangle"
        case .error:
            return "xmark.circle"
        case .loading:
            return "arrow.clockwise"
        case .custom(let systemImage, _):
            return systemImage
        }
    }
    
    var color: Color {
        switch self {
        case .info:
            return .blue
        case .success:
            return .green
        case .warning:
            return .orange
        case .error:
            return .red
        case .loading:
            return .gray
        case .custom(_, let color):
            return color
        }
    }
}

/// Toast显示模式
public enum MagicToastDisplayMode {
    case overlay       // 覆盖层显示在屏幕中央
    case banner        // 横幅从顶部滑下
    case bottom        // 从底部弹出
    case corner        // 在角落显示
}

#if DEBUG
#Preview {
    MagicRootView {
        MagicToastExampleView()
    }
    .frame(width: 400, height: 600)
}
#endif
