import SwiftUI

public struct MagicCard<Content, Background>: View where Content: View, Background: View {
    private let content: Content
    private var background: Background
    private var paddingVertical: CGFloat = 8

    public init(background: Background, paddingVertical: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.background = background
        self.content = content()
        self.paddingVertical = paddingVertical ?? self.paddingVertical
    }

    public var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, paddingVertical)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Preview
#Preview("MagicCard") {
    TabView {
        // 基础样式
        MagicContainer {
            VStack(spacing: 16) {
                Text("基础卡片")
                    .font(.headline)
                
                MagicCard(background: AnyView(Color.clear.background(.ultraThinMaterial))) {
                    Text("基础卡片")
                }
                
                MagicCard(background: Color.accentColor) {
                    Text("强调卡片")
                        .foregroundStyle(.white)
                }
                
                MagicCard(background: AnyView(Color.clear.background(.thinMaterial))) {
                    Text("毛玻璃卡片")
                }
            }
            .padding()
            .frame(width: 300)
        }
        .tabItem {
            Image(systemName: "1.circle.fill")
            Text("基础")
        }
        
        // 复杂内容
        MagicContainer {
            VStack(spacing: 16) {
                Text("复杂内容")
                    .font(.headline)
                
                MagicCard(background: AnyView(Color.clear.background(.ultraThinMaterial))) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title)
                            .foregroundStyle(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("用户名")
                                .font(.headline)
                            Text("用户简介")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
                
                MagicCard(background: AnyView(Color.clear.background(.ultraThinMaterial))) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("标题")
                            .font(.headline)
                        
                        Text("这是一段较长的描述文本，用来展示卡片中的多行内容效果。")
                            .font(.body)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Image(systemName: "hand.thumbsup.fill")
                            Text("点赞")
                            Spacer()
                            Image(systemName: "bubble.right.fill")
                            Text("评论")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .frame(width: 300)
        }
        .tabItem {
            Image(systemName: "2.circle.fill")
            Text("复杂")
        }
        
        // 不同背景
        MagicContainer {
            VStack(spacing: 16) {
                Text("不同背景")
                    .font(.headline)
                
                Group {
                    Text("材质背景").font(.subheadline)
                    
                    MagicCard(background: AnyView(Color.clear.background(.ultraThinMaterial))) {
                        Text("超薄材质")
                    }
                    
                    MagicCard(background: AnyView(Color.clear.background(.thinMaterial))) {
                        Text("薄材质")
                    }
                    
                    MagicCard(background: AnyView(Color.clear.background(.regularMaterial))) {
                        Text("常规材质")
                    }
                    
                    MagicCard(background: AnyView(Color.clear.background(.thickMaterial))) {
                        Text("厚材质")
                    }
                }
                
                Group {
                    Text("颜色背景").font(.subheadline)
                    
                    MagicCard(background: Color.blue.opacity(0.1)) {
                        Text("透明蓝")
                    }
                    
                    MagicCard(background: AnyView(LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))) {
                        Text("蓝色渐变")
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding()
            .frame(width: 300)
        }
        .tabItem {
            Image(systemName: "3.circle.fill")
            Text("背景")
        }
        
        // 交互样式
        MagicContainer {
            VStack(spacing: 16) {
                Text("交互样式")
                    .font(.headline)
                
                InteractiveCard()
                InteractiveCard(showIcon: true)
                InteractiveCard(showSubtitle: true)
            }
            .padding()
            .frame(width: 300)
        }
        .tabItem {
            Image(systemName: "4.circle.fill")
            Text("交互")
        }
    }
}

// MARK: - Interactive Preview
private struct InteractiveCard: View {
    @State private var isHovering = false
    let showIcon: Bool
    let showSubtitle: Bool
    
    init(showIcon: Bool = false, showSubtitle: Bool = false) {
        self.showIcon = showIcon
        self.showSubtitle = showSubtitle
    }
    
    var body: some View {
        MagicCard(background: AnyView(Color.clear.background(isHovering ? .thinMaterial : .ultraThinMaterial))) {
            HStack {
                if showIcon {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .scaleEffect(isHovering ? 1.1 : 1.0)
                }
                
                VStack(alignment: .leading) {
                    Text("交互卡片")
                    if showSubtitle {
                        Text("悬停查看效果")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .opacity(isHovering ? 1 : 0.5)
                    .offset(x: isHovering ? 4 : 0)
            }
        }
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovering = hovering
            }
        }
        .scaleEffect(isHovering ? 1.02 : 1.0)
    }
}
