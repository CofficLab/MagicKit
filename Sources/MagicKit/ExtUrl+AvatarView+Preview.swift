import SwiftUI

/// 头像视图的功能展示组件
public struct AvatarDemoView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 32) {
            // 默认样式
            Group {
                Text("默认样式").font(.headline)
                AvatarView(url: .sample_jpg_earth)
            }
            
            // 自定义背景色
            Group {
                Text("自定义背景色").font(.headline)
                HStack(spacing: 20) {
                    AvatarView(url: .sample_jpg_earth)
                        .magicBackground(.red.opacity(0.1))
                    
                    AvatarView(url: .sample_jpg_earth)
                        .magicBackground(.green.opacity(0.1))
                    
                    AvatarView(url: .sample_jpg_earth)
                        .magicBackground(.purple.opacity(0.1))
                }
            }
            
            // 不同尺寸
            Group {
                Text("不同尺寸").font(.headline)
                HStack(spacing: 20) {
                    AvatarView(url: .sample_jpg_earth)
                        .magicSize(32)
                    
                    AvatarView(url: .sample_jpg_earth)
                        .magicSize(48)
                    
                    AvatarView(url: .sample_jpg_earth)
                        .magicSize(64)
                }
            }
            
            // 不同形状
            Group {
                Text("不同形状").font(.headline)
                HStack(spacing: 20) {
                    AvatarView(url: .sample_jpg_earth)
                        .magicShape(.circle)
                    
                    AvatarView(url: .sample_jpg_earth)
                        .magicShape(.roundedRectangle(cornerRadius: 8))
                    
                    AvatarView(url: .sample_jpg_earth)
                        .magicShape(.rectangle)
                }
            }
        }
        .padding()
        .frame(height: 800)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview("头像视图") {
    AvatarDemoView()
} 
