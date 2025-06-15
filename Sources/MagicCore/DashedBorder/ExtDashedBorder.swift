import SwiftUI

extension View {
    /// 为视图添加虚线边框
    /// - Parameters:
    ///   - color: 虚线颜色，默认为灰色
    ///   - lineWidth: 线宽，默认为1
    ///   - dash: 虚线样式，默认为[5,5]表示线段长5点，间隔5点
    public func dashedBorder(
        color: Color = .gray,
        lineWidth: CGFloat = 1,
        dash: [CGFloat] = [5, 5]
    ) -> some View {
        self.overlay(
            Rectangle()
                .strokeBorder(style: StrokeStyle(
                    lineWidth: lineWidth,
                    dash: dash
                ))
                .foregroundColor(color)
        )
    }
}

// MARK: - Preview

#if DEBUG
#Preview("ExtDashedBorderPreview") {
    Color.red
        .frame(width: 100, height: 100)
        .dashedBorder(color: .blue, lineWidth: 2, dash: [10, 5])
        .frame(width: 200, height: 200)
}
#endif
