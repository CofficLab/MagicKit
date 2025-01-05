import SwiftUI

#if DEBUG
// MARK: - Basic Buttons Preview
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

// MARK: - Size Variations Preview
private struct SizeVariationsPreview: View {
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
        }
        .padding()
    }
}

// MARK: - Shape Variations Preview
private struct ShapeVariationsPreview: View {
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
        }
        .padding()
    }
}

// MARK: - Interactive Features Preview
private struct InteractiveFeaturesPreview: View {
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

// MARK: - Theme Preview
private struct ThemePreview: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Text("主题适配")
                .font(.headline)
            
            Group {
                Text("主要样式").font(.subheadline)
                HStack {
                    MagicButton(icon: "star", action: {})
                        .magicTitle("Primary")
                        .magicStyle(.primary)
                    
                    MagicButton(icon: "star", action: {})
                        .magicStyle(.primary)
                }
            }
            
            Group {
                Text("次要样式").font(.subheadline)
                HStack {
                    MagicButton(icon: "star", action: {})
                        .magicTitle("Secondary")
                        .magicStyle(.secondary)
                    
                    MagicButton(icon: "star", action: {})
                        .magicStyle(.secondary)
                }
            }
            
            Text("当前主题：\(colorScheme == .dark ? "深色" : "浅色")")
                .font(.caption)
        }
        .padding()
    }
}

// MARK: - Main Preview
struct MagicButtonPreview: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MagicThemePreview {
                BasicButtonsPreview()
            }
            .tabItem {
                Image(systemName: "1.circle.fill")
                Text("基础")
            }
            .tag(0)
            
            MagicThemePreview {
                SizeVariationsPreview()
            }
            .tabItem {
                Image(systemName: "2.circle.fill")
                Text("尺寸")
            }
            .tag(1)
            
            MagicThemePreview {
                ShapeVariationsPreview()
            }
            .tabItem {
                Image(systemName: "3.circle.fill")
                Text("形状")
            }
            .tag(2)
            
            MagicThemePreview {
                InteractiveFeaturesPreview()
            }
            .tabItem {
                Image(systemName: "4.circle.fill")
                Text("交互")
            }
            .tag(3)
            
            MagicThemePreview {
                ThemePreview()
            }
            .tabItem {
                Image(systemName: "5.circle.fill")
                Text("主题")
            }
            .tag(4)
        }
        .frame(height: 500)
    }
}

#Preview("MagicButton") {
    MagicButtonPreview()
}
#endif 
