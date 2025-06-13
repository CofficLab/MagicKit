import SwiftUI

struct InteractiveButtonsPreview: View {
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
                        .magicDebugBorder()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(spacing: 16) {
                Text("悬停提示").font(.subheadline)
                HStack(spacing: 16) {
                    // 只显示图标，标题作为 tooltip
                    MagicButton(icon: "star")
                        .magicTitle("收藏") // 设置标题但不显示
                        .magicShape(.circle)
                        .magicDebugBorder()

                    MagicButton(icon: "heart")
                        .magicTitle("喜欢") // 设置标题但不显示
                        .magicShape(.roundedSquare)
                        .magicStyle(.primary)
                        .magicDebugBorder()

                    MagicButton(icon: "bell")
                        .magicTitle("通知") // 设置标题但不显示
                        .magicShape(.circle)
                        .magicBackgroundColor(.orange)
                        .magicDebugBorder()
                }
                .padding(.vertical)
                Text("提示：将鼠标悬停在按钮上查看提示文本")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}

#Preview {
    InteractiveButtonsPreview()
        .inMagicContainer()
}