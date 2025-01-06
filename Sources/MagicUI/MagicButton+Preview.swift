import SwiftUI

#if DEBUG
// MARK: - Basic Preview
private struct BasicButtonsPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("基础按钮")
                .font(.headline)
            
            MagicButton(icon: "star", action: {})
                .magicTitle("默认按钮")
            
            MagicButton(icon: "heart", action: {})
                .magicTitle("主要按钮")
                .magicStyle(.primary)
            
            MagicButton(icon: "trash", action: {})
                .magicTitle("次要按钮")
                .magicStyle(.secondary)
        }
        .padding()
    }
}

// MARK: - Size Preview
private struct SizeButtonsPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("尺寸变体")
                .font(.headline)
            
            Group {
                Text("小尺寸").font(.subheadline)
                MagicButton(icon: "star", action: {})
                    .magicTitle("Small")
                    .magicSize(.small)
            }
            
            Group {
                Text("常规尺寸").font(.subheadline)
                MagicButton(icon: "star", action: {})
                    .magicTitle("Regular")
                    .magicSize(.regular)
            }
            
            Group {
                Text("大尺寸").font(.subheadline)
                MagicButton(icon: "star", action: {})
                    .magicTitle("Large")
                    .magicSize(.large)
            }
            
            Group {
                Text("自动尺寸").font(.subheadline)
                HStack(spacing: 20) {
                    // 小容器
                    VStack {
                        Text("40x40")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Frame(width: 40, height: 40) {
                            MagicButton(icon: "star", size: .auto, action: {})
                        }
                    }
                    // 中等容器
                    VStack {
                        Text("60x60")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Frame(width: 60, height: 60) {
                            MagicButton(icon: "star", size: .auto, action: {})
                        }
                    }
                    // 大容器
                    VStack {
                        Text("80x80")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Frame(width: 80, height: 80) {
                            MagicButton(icon: "star", size: .auto, action: {})
                        }
                    }
                }
            }
        }
        .padding()
    }
}

/// 用于创建固定尺寸容器的辅助视图
private struct Frame<Content: View>: View {
    let width: CGFloat?
    let height: CGFloat?
    let content: Content
    
    init(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.width = width
        self.height = height
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .foregroundStyle(.secondary.opacity(0.5))
            )
    }
}

// MARK: - Shape Preview
private struct ShapeButtonsPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("形状变体")
                .font(.headline)
            
            Group {
                Text("圆形").font(.subheadline)
                HStack {
                    MagicButton(icon: "star", action: {})
                        .magicShape(.circle)
                    
                    MagicButton(icon: "star", action: {})
                        .magicTitle("Circle")
                        .magicShape(.circle)
                }
            }
            
            Group {
                Text("胶囊形").font(.subheadline)
                HStack {
                    MagicButton(icon: "star", action: {})
                        .magicShape(.capsule)
                    
                    MagicButton(icon: "star", action: {})
                        .magicTitle("Capsule")
                        .magicShape(.capsule)
                }
            }
            
            Group {
                Text("矩形").font(.subheadline)
                HStack {
                    MagicButton(icon: "star", action: {})
                        .magicShape(.rectangle)
                    
                    MagicButton(icon: "star", action: {})
                        .magicTitle("Rectangle")
                        .magicShape(.rectangle)
                }
            }
            
            Group {
                Text("圆角矩形").font(.subheadline)
                HStack {
                    MagicButton(icon: "star", action: {})
                        .magicShape(.roundedRectangle)
                    
                    MagicButton(icon: "star", action: {})
                        .magicTitle("Rounded Rectangle")
                        .magicShape(.roundedRectangle)
                }
            }
            
            Group {
                Text("圆角正方形").font(.subheadline)
                HStack {
                    MagicButton(icon: "star", action: {})
                        .magicShape(.roundedSquare)
                    
                    MagicButton(icon: "star", action: {})
                        .magicStyle(.primary)
                        .magicShape(.roundedSquare)
                }
            }
        }
        .padding()
    }
}

// MARK: - Custom Shape Preview
private struct CustomShapeButtonsPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("自定义形状")
                .font(.headline)
            
            Group {
                Text("自定义圆角矩形").font(.subheadline)
                VStack(spacing: 12) {
                    MagicButton(icon: "star", action: {})
                        .magicTitle("仅上圆角")
                        .magicShape(.customRoundedRectangle(
                            topLeft: 16,
                            topRight: 16,
                            bottomLeft: 0,
                            bottomRight: 0
                        ))
                    
                    MagicButton(icon: "star", action: {})
                        .magicTitle("仅右圆角")
                        .magicShape(.customRoundedRectangle(
                            topLeft: 0,
                            topRight: 16,
                            bottomLeft: 0,
                            bottomRight: 16
                        ))
                    
                    MagicButton(icon: "star", action: {})
                        .magicTitle("不同圆角")
                        .magicShape(.customRoundedRectangle(
                            topLeft: 8,
                            topRight: 16,
                            bottomLeft: 16,
                            bottomRight: 8
                        ))
                }
            }
            
            Group {
                Text("自定义胶囊形").font(.subheadline)
                VStack(spacing: 12) {
                    MagicButton(icon: "star", action: {})
                        .magicTitle("左大右小")
                        .magicShape(.customCapsule(
                            leftRadius: 24,
                            rightRadius: 8
                        ))
                    
                    MagicButton(icon: "star", action: {})
                        .magicTitle("左小右大")
                        .magicShape(.customCapsule(
                            leftRadius: 8,
                            rightRadius: 24
                        ))
                }
            }
        }
        .padding()
    }
}

// MARK: - Interactive Preview
private struct InteractiveButtonsPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("交互特性")
                .font(.headline)
            
            Group {
                Text("禁用状态").font(.subheadline)
                MagicButton(icon: "exclamationmark.triangle", action: {})
                    .magicTitle("Disabled Button")
                    .magicDisabled("此按钮已禁用")
            }
            
            Group {
                Text("弹出内容").font(.subheadline)
                MagicButton(icon: "info.circle", action: {})
                    .magicTitle("With Popover")
                    .magicPopover {
                        VStack(spacing: 8) {
                            Text("弹出内容示例")
                                .font(.headline)
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text("这是一段说明文字")
                                .font(.caption)
                        }
                        .padding()
                    }
            }
        }
        .padding()
    }
}

// MARK: - Shape Visibility Preview
private struct ShapeVisibilityButtonsPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("形状显示")
                .font(.headline)
            
            Group {
                Text("始终显示").font(.subheadline)
                MagicButton(icon: "star", action: {})
                    .magicTitle("Always Visible")
                    .magicStyle(.primary)
                    .magicShapeVisibility(.always)
            }
            
            Group {
                Text("悬停显示").font(.subheadline)
                MagicButton(icon: "star", action: {})
                    .magicTitle("Show on Hover")
                    .magicStyle(.primary)
                    .magicShapeVisibility(.onHover)
            }
            
            Group {
                Text("组合效果").font(.subheadline)
                HStack(spacing: 16) {
                    MagicButton(icon: "star", action: {})
                        .magicShape(.circle)
                        .magicShapeVisibility(.onHover)
                    
                    MagicButton(icon: "star", action: {})
                        .magicTitle("Hover Me")
                        .magicShape(.capsule)
                        .magicShapeVisibility(.onHover)
                }
            }
            
            Group {
                Text("不同样式").font(.subheadline)
                HStack(spacing: 16) {
                    MagicButton(icon: "star", action: {})
                        .magicTitle("Primary")
                        .magicStyle(.primary)
                        .magicShapeVisibility(.onHover)
                    
                    MagicButton(icon: "star", action: {})
                        .magicTitle("Secondary")
                        .magicStyle(.secondary)
                        .magicShapeVisibility(.onHover)
                }
            }
        }
        .padding()
    }
}

// MARK: - Main Preview
struct MagicButtonPreview: View {
    var body: some View {
        TabView {
            MagicThemePreview {
                BasicButtonsPreview()
            }
            .tabItem {
                Image(systemName: "1.circle.fill")
                Text("基础")
            }
            
            MagicThemePreview {
                SizeButtonsPreview()
            }
            .tabItem {
                Image(systemName: "2.circle.fill")
                Text("尺寸")
            }
            
            MagicThemePreview {
                ShapeButtonsPreview()
            }
            .frame(maxHeight: .infinity)
            .tabItem {
                Image(systemName: "3.circle.fill")
                Text("形状")
            }
            
            MagicThemePreview {
                CustomShapeButtonsPreview()
            }
            .tabItem {
                Image(systemName: "4.circle.fill")
                Text("自定义")
            }
            
            MagicThemePreview {
                InteractiveButtonsPreview()
            }
            .tabItem {
                Image(systemName: "5.circle.fill")
                Text("交互")
            }
            
            MagicThemePreview {
                ShapeVisibilityButtonsPreview()
            }
            .tabItem {
                Image(systemName: "6.circle.fill")
                Text("显示")
            }
        }
    }
}

#Preview("MagicButton") {
    MagicButtonPreview()
}
#endif 
