import SwiftUI

// MARK: - Basic Preview
private struct BasicButtonsPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("基础按钮")
                .font(.headline)
            
            VStack(spacing: 16) {
                MagicButton(icon: "star")
                    .magicTitle("默认按钮")
                    .magicDebugBorder()
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 16) {
                MagicButton(icon: "heart")
                    .magicTitle("主要按钮")
                    .magicStyle(.primary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 16) {
                MagicButton(icon: "trash")
                    .magicTitle("次要按钮")
                    .magicStyle(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
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
            
            // Mini Size
            VStack(spacing: 16) {
                Text("迷你尺寸").font(.subheadline)
                HStack(spacing: 16) {
                    MagicButton(icon: "star")
                        .magicTitle("Mini")
                        .magicSize(.mini)
                        .magicShape(.roundedRectangle)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicSize(.mini)
                        .magicShape(.circle)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicTitle("Mini")
                        .magicSize(.mini)
                        .magicShape(.capsule)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicSize(.mini)
                        .magicShape(.roundedSquare)
                        .magicDebugBorder()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Small Size
            VStack(spacing: 16) {
                Text("小尺寸").font(.subheadline)
                HStack(spacing: 16) {
                    MagicButton(icon: "star")
                        .magicTitle("Small")
                        .magicSize(.small)
                        .magicShape(.roundedRectangle)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicSize(.small)
                        .magicShape(.circle)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicTitle("Small")
                        .magicSize(.small)
                        .magicShape(.capsule)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicSize(.small)
                        .magicShape(.roundedSquare)
                        .magicDebugBorder()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Regular Size
            VStack(spacing: 16) {
                Text("常规尺寸").font(.subheadline)
                HStack(spacing: 16) {
                    MagicButton(icon: "star")
                        .magicTitle("Regular")
                        .magicSize(.regular)
                        .magicShape(.roundedRectangle)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicSize(.regular)
                        .magicShape(.circle)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicTitle("Regular")
                        .magicSize(.regular)
                        .magicShape(.capsule)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicSize(.regular)
                        .magicShape(.roundedSquare)
                        .magicDebugBorder()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Large Size
            VStack(spacing: 16) {
                Text("大尺寸").font(.subheadline)
                HStack(spacing: 16) {
                    MagicButton(icon: "star")
                        .magicTitle("Large")
                        .magicSize(.large)
                        .magicShape(.roundedRectangle)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicSize(.large)
                        .magicShape(.circle)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicTitle("Large")
                        .magicSize(.large)
                        .magicShape(.capsule)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicSize(.large)
                        .magicShape(.roundedSquare)
                        .magicDebugBorder()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Extra Large Size
            VStack(spacing: 16) {
                Text("超大尺寸").font(.subheadline)
                HStack(spacing: 16) {
                    MagicButton(icon: "star")
                        .magicTitle("Extra Large")
                        .magicSize(.extraLarge)
                        .magicShape(.roundedRectangle)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicSize(.extraLarge)
                        .magicShape(.circle)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicTitle("Extra Large")
                        .magicSize(.extraLarge)
                        .magicShape(.capsule)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicSize(.extraLarge)
                        .magicShape(.roundedSquare)
                        .magicDebugBorder()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Huge Size
            VStack(spacing: 16) {
                Text("巨大尺寸").font(.subheadline)
                HStack(spacing: 16) {
                    MagicButton(icon: "star")
                        .magicTitle("Huge")
                        .magicSize(.huge)
                        .magicShape(.roundedRectangle)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicSize(.huge)
                        .magicShape(.circle)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicTitle("Huge")
                        .magicSize(.huge)
                        .magicShape(.capsule)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicSize(.huge)
                        .magicShape(.roundedSquare)
                        .magicDebugBorder()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 16) {
                Text("自定义尺寸").font(.subheadline)
                VStack(spacing: 16) {
                    // 40 尺寸
                    HStack(spacing: 16) {
                        MagicButton(icon: "star", size: .custom(40))
                            .magicTitle("40")
                            .magicShape(.roundedRectangle)
                            .magicDebugBorder()
                        
                        MagicButton(icon: "star", size: .custom(40))
                            .magicShape(.circle)
                            .magicDebugBorder()
                        
                        MagicButton(icon: "star", size: .custom(40))
                            .magicTitle("40")
                            .magicShape(.capsule)
                            .magicDebugBorder()
                        
                        MagicButton(icon: "star", size: .custom(40))
                            .magicShape(.roundedSquare)
                            .magicDebugBorder()
                    }
                    
                    // 60 尺寸
                    HStack(spacing: 16) {
                        MagicButton(icon: "star", size: .custom(60))
                            .magicTitle("60")
                            .magicShape(.roundedRectangle)
                            .magicDebugBorder()
                        
                        MagicButton(icon: "star", size: .custom(60))
                            .magicShape(.circle)
                            .magicDebugBorder()
                        
                        MagicButton(icon: "star", size: .custom(60))
                            .magicTitle("60")
                            .magicShape(.capsule)
                            .magicDebugBorder()
                        
                        MagicButton(icon: "star", size: .custom(60))
                            .magicShape(.roundedSquare)
                            .magicDebugBorder()
                    }
                    
                    // 80 尺寸
                    HStack(spacing: 16) {
                        MagicButton(icon: "star", size: .custom(80))
                            .magicTitle("80")
                            .magicShape(.roundedRectangle)
                            .magicDebugBorder()
                        
                        MagicButton(icon: "star", size: .custom(80))
                            .magicShape(.circle)
                            .magicDebugBorder()
                        
                        MagicButton(icon: "star", size: .custom(80))
                            .magicTitle("80")
                            .magicShape(.capsule)
                            .magicDebugBorder()
                        
                        MagicButton(icon: "star", size: .custom(80))
                            .magicShape(.roundedSquare)
                            .magicDebugBorder()
                    }
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Auto Size
            VStack(spacing: 16) {
                Text("自动尺寸").font(.subheadline)
                VStack(spacing: 16) {
                    // 小尺寸行
                    HStack(spacing: 16) {
                        Frame(width: 32, height: 32) {
                            MagicButton(icon: "star", size: .auto)
                                .magicShape(.circle)
                                .magicDebugBorder()
                        }
                        
                        Frame(width: 60, height: 32) {
                            MagicButton(icon: "star", size: .auto)
                                .magicTitle("Mini")
                                .magicShape(.capsule)
                                .magicDebugBorder()
                        }
                        
                        Frame(width: 40, height: 40) {
                            MagicButton(icon: "star", size: .auto)
                                .magicShape(.roundedSquare)
                                .magicDebugBorder()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 中等尺寸行
                    HStack(spacing: 16) {
                        Frame(width: 120, height: 40) {
                            MagicButton(icon: "star", size: .auto)
                                .magicTitle("Regular")
                                .magicShape(.roundedRectangle)
                                .magicDebugBorder()
                        }
                        
                        Frame(width: 60, height: 60) {
                            MagicButton(icon: "star", size: .auto)
                                .magicShape(.circle)
                                .magicDebugBorder()
                        }
                        
                        Frame(width: 100, height: 50) {
                            MagicButton(icon: "star", size: .auto)
                                .magicTitle("Medium")
                                .magicShape(.capsule)
                                .magicDebugBorder()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 大尺寸行
                    HStack(spacing: 16) {
                        Frame(width: 160, height: 80) {
                            MagicButton(icon: "star", size: .auto)
                                .magicTitle("Large")
                                .magicShape(.roundedRectangle)
                                .magicDebugBorder()
                        }
                        
                        Frame(width: 100, height: 100) {
                            MagicButton(icon: "star", size: .auto)
                                .magicShape(.circle)
                                .magicDebugBorder()
                        }
                        
                        Frame(width: 140, height: 70) {
                            MagicButton(icon: "star", size: .auto)
                                .magicTitle("Big")
                                .magicShape(.capsule)
                                .magicDebugBorder()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 超大尺寸行
                    HStack(spacing: 16) {
                        Frame(width: 200, height: 120) {
                            MagicButton(icon: "star", size: .auto)
                                .magicTitle("Extra Large")
                                .magicShape(.roundedRectangle)
                                .magicDebugBorder()
                        }
                        
                        Frame(width: 150, height: 150) {
                            MagicButton(icon: "star", size: .auto)
                                .magicShape(.circle)
                                .magicDebugBorder()
                        }
                        
                        Frame(width: 180, height: 90) {
                            MagicButton(icon: "star", size: .auto)
                                .magicTitle("Huge")
                                .magicShape(.capsule)
                                .magicDebugBorder()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 巨大尺寸行
                    VStack(spacing: 16) {
                        // 第一行
                        HStack(spacing: 16) {
                            Frame(width: 300, height: 200) {
                                MagicButton(icon: "star", size: .auto)
                                    .magicTitle("Giant")
                                    .magicShape(.roundedRectangle)
                                    .magicDebugBorder()
                            }
                            
                            Frame(width: 250, height: 250) {
                                MagicButton(icon: "star", size: .auto)
                                    .magicShape(.circle)
                                    .magicDebugBorder()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // 第二行
                        HStack(spacing: 16) {
                            Frame(width: 280, height: 140) {
                                MagicButton(icon: "star", size: .auto)
                                    .magicTitle("Massive")
                                    .magicShape(.capsule)
                                    .magicDebugBorder()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
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
        VStack(spacing: 4) {
            if let width = width, let height = height {
                Text("\(Int(width))×\(Int(height))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            content
                .frame(width: width, height: height)
                .clipShape(Rectangle())
                .background(
                    Rectangle()
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                        .foregroundStyle(.secondary.opacity(0.5))
                )
        }
    }
}

// MARK: - Shape Preview
private struct ShapeButtonsPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("形状变体")
                .font(.headline)
            
            VStack(spacing: 16) {
                Text("圆形").font(.subheadline)
                HStack {
                    MagicButton(icon: "star")
                        .magicShape(.circle)
                    
                    MagicButton(icon: "star")
                        .magicTitle("Circle")
                        .magicShape(.circle)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 16) {
                Text("胶囊形").font(.subheadline)
                HStack {
                    MagicButton(icon: "star")
                        .magicShape(.capsule)
                    
                    MagicButton(icon: "star")
                        .magicTitle("Capsule")
                        .magicShape(.capsule)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 16) {
                Text("矩形").font(.subheadline)
                HStack {
                    MagicButton(icon: "star")
                        .magicShape(.rectangle)
                    
                    MagicButton(icon: "star")
                        .magicTitle("Rectangle")
                        .magicShape(.rectangle)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 16) {
                Text("圆角矩形").font(.subheadline)
                HStack {
                    MagicButton(icon: "star")
                        .magicShape(.roundedRectangle)
                    
                    MagicButton(icon: "star")
                        .magicTitle("Rounded Rectangle")
                        .magicShape(.roundedRectangle)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 16) {
                Text("圆角正方形").font(.subheadline)
                HStack {
                    MagicButton(icon: "star")
                        .magicShape(.roundedSquare)
                    
                    MagicButton(icon: "star")
                        .magicStyle(.primary)
                        .magicShape(.roundedSquare)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
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
            
            VStack(spacing: 16) {
                Text("自定义圆角矩形").font(.subheadline)
                VStack(spacing: 12) {
                    MagicButton(icon: "star")
                        .magicTitle("仅上圆角")
                        .magicShape(.customRoundedRectangle(
                            topLeft: 16,
                            topRight: 16,
                            bottomLeft: 0,
                            bottomRight: 0
                        ))
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicTitle("仅右圆角")
                        .magicShape(.customRoundedRectangle(
                            topLeft: 0,
                            topRight: 16,
                            bottomLeft: 0,
                            bottomRight: 16
                        ))
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicTitle("不同圆角")
                        .magicShape(.customRoundedRectangle(
                            topLeft: 8,
                            topRight: 16,
                            bottomLeft: 16,
                            bottomRight: 8
                        ))
                        .magicDebugBorder()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 16) {
                Text("自定义胶囊形").font(.subheadline)
                VStack(spacing: 12) {
                    MagicButton(icon: "star")
                        .magicTitle("左大右小")
                        .magicShape(.customCapsule(
                            leftRadius: 24,
                            rightRadius: 8
                        ))
                    
                    MagicButton(icon: "star")
                        .magicTitle("左小右大")
                        .magicShape(.customCapsule(
                            leftRadius: 8,
                            rightRadius: 24
                        ))
                        .magicDebugBorder()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}

// MARK: - Interactive Preview
private struct InteractiveButtonsPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("交互变体")
                .font(.headline)
            
            VStack(spacing: 16) {
                Text("禁用状态").font(.subheadline)
                MagicButton(
                    icon: "star",
                    disabledReason: "This button is disabled"
                )
                .magicTitle("Disabled Button")
                .magicDebugBorder()
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 16) {
                Text("弹出内容").font(.subheadline)
                HStack(spacing: 16) {
                    // 点击显示的弹出内容
                    MagicButton(icon: "star")
                        .magicTitle("Click to Show")
                        .magicPopover {
                            Text("Click Triggered Popover")
                                .padding()
                        }
                        .magicDebugBorder()
                    
                    // 默认显示的弹出内容
                    MagicButton(icon: "bell")
                        .magicTitle("Default Shown")
                        .magicPopover {
                            Text("Default Shown Popover")
                                .padding()
                        }
                        .magicPopoverPresented(true)
                        .magicDebugBorder()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}

// MARK: - Shape Visibility Preview
private struct ShapeVisibilityButtonsPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("显示变体")
                .font(.headline)
            
            VStack(spacing: 16) {
                Text("始终显示形状").font(.subheadline)
                HStack {
                    MagicButton(icon: "star")
                        .magicTitle("Always")
                        .magicShapeVisibility(.always)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicStyle(.primary)
                        .magicTitle("Always")
                        .magicShapeVisibility(.always)
                        .magicDebugBorder()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 16) {
                Text("悬停时显示形状").font(.subheadline)
                HStack {
                    MagicButton(icon: "star")
                        .magicTitle("On Hover")
                        .magicShapeVisibility(.onHover)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicStyle(.primary)
                        .magicTitle("On Hover")
                        .magicShapeVisibility(.onHover)
                        .magicDebugBorder()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}

// MARK: - Background Color Preview
private struct BackgroundColorButtonsPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("背景色变体")
                .font(.headline)
            
            VStack(spacing: 16) {
                Text("基础颜色").font(.subheadline)
                HStack(spacing: 16) {
                    MagicButton(icon: "star")
                        .magicTitle("Blue")
                        .magicBackgroundColor(.blue)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "heart")
                        .magicTitle("Red")
                        .magicBackgroundColor(.red)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "leaf")
                        .magicTitle("Green")
                        .magicBackgroundColor(.green)
                        .magicDebugBorder()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 16) {
                Text("不同形状").font(.subheadline)
                HStack(spacing: 16) {
                    MagicButton(icon: "star")
                        .magicShape(.circle)
                        .magicBackgroundColor(.purple)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicShape(.roundedSquare)
                        .magicBackgroundColor(.orange)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicTitle("Capsule")
                        .magicShape(.capsule)
                        .magicBackgroundColor(.mint)
                        .magicDebugBorder()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 16) {
                Text("组合效果").font(.subheadline)
                HStack(spacing: 16) {
                    MagicButton(icon: "star")
                        .magicTitle("Primary")
                        .magicStyle(.primary)
                        .magicBackgroundColor(.blue)
                    
                    MagicButton(icon: "star")
                        .magicTitle("Secondary")
                        .magicStyle(.secondary)
                        .magicBackgroundColor(.green)
                    
                    MagicButton(icon: "star")
                        .magicTitle("Disabled")
                        .magicDisabled("Disabled with background")
                        .magicBackgroundColor(.red)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 16) {
                Text("自定义背景").font(.subheadline)
                HStack(spacing: 16) {
                    MagicButton(icon: "sun.max")
                        .magicTitle("Dawn")
                        .magicBackground(MagicBackground.dawnSky)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "cloud.bolt")
                        .magicTitle("Storm")
                        .magicBackground(MagicBackground.stormyHeaven)
                        .magicDebugBorder()
                    
                    MagicButton(icon: "sunset")
                        .magicTitle("Sunset")
                        .magicBackground(MagicBackground.sunsetGlow)
                        .magicDebugBorder()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 16) {
                Text("渐变背景").font(.subheadline)
                HStack(spacing: 16) {
                    MagicButton(icon: "star")
                        .magicTitle("Linear")
                        .magicBackground(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicTitle("Angular")
                        .magicBackground(
                            AngularGradient(
                                colors: [.red, .orange, .yellow, .green, .blue, .purple, .red],
                                center: .center
                            )
                        )
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicTitle("Radial")
                        .magicBackground(
                            RadialGradient(
                                colors: [.mint, .cyan],
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .magicDebugBorder()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}

// 在 BackgroundColorButtonsPreview 后添加
private struct DebugBorderButtonsPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("调试边框")
                .font(.headline)
            
            VStack(spacing: 16) {
                Text("默认边框").font(.subheadline)
                HStack(spacing: 16) {
                    MagicButton(icon: "star")
                        .magicTitle("Default")
                        .magicDebugBorder()
                    
                    MagicButton(icon: "star")
                        .magicShape(.circle)
                        .magicDebugBorder()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 16) {
                Text("自定义边框").font(.subheadline)
                HStack(spacing: 16) {
                    MagicButton(icon: "star")
                        .magicTitle("Red Border")
                        .magicDebugBorder(.red, lineWidth: 2)
                    
                    MagicButton(icon: "star")
                        .magicTitle("Custom Dash")
                        .magicDebugBorder(.blue, dash: [8, 4])
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 16) {
                Text("不同大小").font(.subheadline)
                HStack(spacing: 16) {
                    MagicButton(icon: "star")
                        .magicSize(.small)
                        .magicDebugBorder(.green)
                    
                    MagicButton(icon: "star")
                        .magicSize(.large)
                        .magicDebugBorder(.orange)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
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
            
            MagicThemePreview {
                BackgroundColorButtonsPreview()
            }
            .tabItem {
                Image(systemName: "7.circle.fill")
                Text("背景")
            }
            
            MagicThemePreview {
                DebugBorderButtonsPreview()
            }
            .tabItem {
                Image(systemName: "8.circle.fill")
                Text("调试")
            }
        }
    }
}

#Preview("MagicButton") {
    MagicButtonPreview()
        .frame(height: 800)
}
