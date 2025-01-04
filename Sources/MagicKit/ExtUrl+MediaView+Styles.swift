import SwiftUI

// MARK: - Media View Style
/// 媒体视图的背景样式
public enum MediaViewStyle {
    /// 无背景
    case none
    /// 自定义背景视图
    case background(AnyView)
}

// MARK: - Media View Shape
/// 媒体视图左侧缩略图的形状
public enum MediaViewShape {
    /// 圆形
    case circle
    /// 圆角矩形，可指定圆角半径
    case roundedRectangle(cornerRadius: CGFloat = 8)
    /// 矩形
    case rectangle
    
    @ViewBuilder
    func apply<V: View>(to view: V) -> some View {
        switch self {
        case .circle:
            view.clipShape(Circle())
        case .roundedRectangle(let radius):
            view.clipShape(RoundedRectangle(cornerRadius: radius))
        case .rectangle:
            view
        }
    }
    
    @ViewBuilder
    func strokeShape() -> some View {
        switch self {
        case .circle:
            Circle().stroke(Color.red, lineWidth: 2)
        case .roundedRectangle(let radius):
            RoundedRectangle(cornerRadius: radius).stroke(Color.red, lineWidth: 2)
        case .rectangle:
            Rectangle().stroke(Color.red, lineWidth: 2)
        }
    }
}

// MARK: - Background Modifier
struct MediaViewBackground: ViewModifier {
    let style: MediaViewStyle
    
    func body(content: Content) -> some View {
        Group {
            switch style {
            case .none:
                content
            case .background(let background):
                content
                    .background(background)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - View Extension
extension View {
    func apply(shape: MediaViewShape) -> some View {
        shape.apply(to: self)
    }
} 