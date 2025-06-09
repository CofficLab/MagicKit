import SwiftUI

struct CustomRoundedRectangle: Shape {
    let topLeft: CGFloat
    let topRight: CGFloat
    let bottomLeft: CGFloat
    let bottomRight: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - topRight, y: rect.minY + topRight),
            radius: topRight,
            startAngle: Angle(degrees: -90),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        path.addArc(
            center: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY - bottomRight),
            radius: bottomRight,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 90),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY - bottomLeft),
            radius: bottomLeft,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        path.addArc(
            center: CGPoint(x: rect.minX + topLeft, y: rect.minY + topLeft),
            radius: topLeft,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        
        return path
    }
}

struct CustomCapsule: Shape {
    let leftRadius: CGFloat
    let rightRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX + leftRadius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - rightRadius, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - rightRadius, y: rect.midY),
            radius: rightRadius,
            startAngle: Angle(degrees: -90),
            endAngle: Angle(degrees: 90),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX + leftRadius, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: rect.minX + leftRadius, y: rect.midY),
            radius: leftRadius,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        
        return path
    }
}

struct MagicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    BasicButtonsPreview()
        .inMagicContainer()
}
