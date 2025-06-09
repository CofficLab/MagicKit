import SwiftUI

/// MagicDiffView 的预览示例视图
/// 展示了不同场景下的差异视图效果
struct MagicDiffPreviewView: View {
    var body: some View {
        TabView {
            // GitHub Desktop 风格示例
            VStack(spacing: 16) {
                Text("GitHub Desktop 风格差异视图")
                    .font(.headline)
                    .padding()
                
                MagicDiffView(
                    oldText: "if let view = self.view {\n    ZStack {\n        // 必须加载，其内部3才能加载\n        view\n            .frame(maxWidth: .infinity)\n            .frame(maxHeight: .infinity)\n            .opacity(self.isReady && self.viewReady ? 1 : 0)\n    }\n    \n    if !self.isReady || !self.viewReady {\n        MagicLoading()\n    }\n} else {\n    MagicLoading()\n}",
                    newText: "ZStack {\n    if let view = self.view {\n        // 必须加载，其内部3才能加载\n        view\n            .frame(maxWidth: .infinity)\n            .frame(maxHeight: .infinity)\n            .opacity(self.isReady && self.viewReady ? 1 : 0)\n    }\n    \n    if !self.isReady || !self.viewReady {\n        MagicLoading()\n    }\n}"
                )
                .padding()
            }
            .tabItem {
                Image(systemName: "star.fill")
                Text("GitHub 风格")
            }
            
            // 基础示例
            MagicDiffView(
                oldText: "Hello World\nThis is line 2\nLine 3 will be removed\nLine 4 unchanged",
                newText: "Hello Swift\nThis is line 2\nLine 4 unchanged\nNew line 5 added"
            )
            .padding()
            .tabItem {
                Image(systemName: "1.circle.fill")
                Text("基础")
            }
            
            // 代码差异示例
            MagicDiffView(
                oldText: "func oldFunction() {\n    print(\"old\")\n    return 42\n}",
                newText: "func newFunction() {\n    print(\"new\")\n    print(\"additional line\")\n    return 100\n}"
            )
            .padding()
            .tabItem {
                Image(systemName: "2.circle.fill")
                Text("代码")
            }
            
            // 无行号示例
            MagicDiffView(
                oldText: "Simple text\nAnother line",
                newText: "Modified text\nAnother line\nExtra line",
                showLineNumbers: false
            )
            .padding()
            .tabItem {
                Image(systemName: "3.circle.fill")
                Text("无行号")
            }
        }
        .frame(width: 900, height: 700)
    }
}

// MARK: - Preview
#Preview("MagicDiffPreviewView") {
    MagicDiffPreviewView()
        .inMagicContainer()
}
