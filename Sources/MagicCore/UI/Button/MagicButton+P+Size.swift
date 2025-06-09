import SwiftUI

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

struct SizeButtonsPreview: View {
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
                .frame(maxWidth: .infinity)
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

                    // 大尺寸
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

                    // 超大尺寸
                    Frame(width: 180, height: 120) {
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

                    // 巨大尺寸
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

                    Frame(width: 280, height: 140) {
                        MagicButton(icon: "star", size: .auto)
                            .magicTitle("Massive")
                            .magicShape(.capsule)
                            .magicDebugBorder()
                    }
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }.padding()
    }
}

#Preview {
    SizeButtonsPreview()
        .inMagicContainer()
}