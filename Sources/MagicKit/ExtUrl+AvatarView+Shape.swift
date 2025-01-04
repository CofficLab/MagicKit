import SwiftUI
import Combine

// MARK: - Avatar View Shape
/// 头像视图的形状类型
public enum AvatarViewShape {
    /// 圆形
    case circle
    /// 矩形
    case rectangle
    /// 圆角矩形
    case roundedRectangle(cornerRadius: CGFloat)
    /// 胶囊形状
    case capsule

    /// 获取形状
    var shape: AnyShape {
        switch self {
        case .circle:
            AnyShape(Circle())
        case .rectangle:
            AnyShape(Rectangle())
        case .roundedRectangle(let cornerRadius):
            AnyShape(RoundedRectangle(cornerRadius: cornerRadius))
        case .capsule:
            AnyShape(Capsule())
        }
    }

    /// 获取边框形状
    @ViewBuilder
    func strokeBorder(color: Color = .red, lineWidth: CGFloat = 1) -> some View {
        let style = StrokeStyle(lineWidth: lineWidth)
        switch self {
        case .circle:
            Circle().stroke(color, style: style)
        case .rectangle:
            Rectangle().stroke(color, style: style)
        case .roundedRectangle(let cornerRadius):
            RoundedRectangle(cornerRadius: cornerRadius).stroke(color, style: style)
        case .capsule:
            Capsule().stroke(color, style: style)
        }
    }
}

// MARK: - Preview
#Preview("头像视图") {
    AvatarViewPreviewContainer()
}
