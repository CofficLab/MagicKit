import SwiftUI

/// 用于展示键值对的通用行组件
public struct MagicKeyValue<Icon: View>: View {
    private let key: String
    private let value: String
    private let icon: Icon?
    @State private var isCopied = false
    
    /// 创建键值对行组件（带复制功能）
    /// - Parameters:
    ///   - key: 键名
    ///   - value: 值
    public init(key: String, value: String) where Icon == Never {
        self.key = key
        self.value = value
        self.icon = nil
    }
    
    /// 创建键值对行组件（带自定义图标）
    /// - Parameters:
    ///   - key: 键名
    ///   - value: 值
    ///   - icon: 自定义图标视图
    public init(key: String, value: String, @ViewBuilder icon: () -> Icon) {
        self.key = key
        self.value = value
        self.icon = icon()
    }
    
    public var body: some View {
        HStack {
            Text(key)
            Spacer()
            Text(value)
                .monospaced()
            
            if let icon = icon {
                icon
                    .foregroundStyle(.secondary)
            } else {
                Button {
                    value.copy()
                    withAnimation {
                        isCopied = true
                    }
                    
                    // 2秒后重置状态
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isCopied = false
                        }
                    }
                } label: {
                    Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                        .foregroundStyle(isCopied ? .green : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview("MagicKeyValue 演示") {
    TabView {
        // 基础示例
        MagicContainer {
            VStack(spacing: 16) {
                MagicKeyValue(key: "用户名", value: "admin")
                MagicKeyValue(key: "创建时间", value: "2024-03-15 14:30:45")
                MagicKeyValue(key: "Token", value: "abc123xyz789")
                MagicKeyValue(key: "描述", value: "这是一个很长的描述文本，用于测试长文本的显示效果和复制功能")
            }
            .padding()
        }
        .tabItem {
            Image(systemName: "1.circle.fill")
            Text("基础")
        }
        
        // 图标示例
        MagicContainer {
            VStack(spacing: 16) {
                MagicKeyValue(key: "播放", value: "play.circle") {
                    Image(systemName: "play.circle")
                }
                MagicKeyValue(key: "暂停", value: "pause.circle") {
                    Image(systemName: "pause.circle")
                }
                MagicKeyValue(key: "停止", value: "stop.circle") {
                    Image(systemName: "stop.circle")
                }
            }
            .padding()
        }
        .tabItem {
            Image(systemName: "2.circle.fill")
            Text("图标")
        }
        
        // 分组示例
        MagicContainer {
            VStack(spacing: 20) {
                // 用户信息组
                VStack(alignment: .leading, spacing: 12) {
                    Text("用户信息")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 8) {
                        MagicKeyValue(key: "用户名", value: "admin")
                        MagicKeyValue(key: "邮箱", value: "admin@example.com")
                        MagicKeyValue(key: "角色", value: "管理员")
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // 系统信息组
                VStack(alignment: .leading, spacing: 12) {
                    Text("系统信息")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 8) {
                        MagicKeyValue(key: "版本", value: "1.0.0")
                        MagicKeyValue(key: "构建号", value: "20240315001")
                        MagicKeyValue(key: "更新时间", value: "2024-03-15 14:30:45")
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
        }
        .tabItem {
            Image(systemName: "3.circle.fill")
            Text("分组")
        }
    }
}
