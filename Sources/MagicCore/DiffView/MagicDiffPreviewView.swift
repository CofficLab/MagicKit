import SwiftUI

/// MagicDiffView 的预览示例视图
/// 展示了不同场景下的差异视图效果
struct MagicDiffPreviewView: View {
    var body: some View {
        TabView {
            MagicDiffView(
                oldText: "if let view = self.view {\n    ZStack {\n        // 必须加载，其内部3才能加载\n        view\n            .frame(maxWidth: .infinity)\n            .frame(maxHeight: .infinity)\n            .opacity(self.isReady && self.viewReady ? 1 : 0)\n    }\n    \n    if !self.isReady || !self.viewReady {\n        MagicLoading()\n    }\n} else {\n    MagicLoading()\n}",
                newText: "ZStack {\n    if let view = self.view {\n        // 必须加载，其内部3才能加载\n        view\n            .frame(maxWidth: .infinity)\n            .frame(maxHeight: .infinity)\n            .opacity(self.isReady && self.viewReady ? 1 : 0)\n    }\n    \n    if !self.isReady || !self.viewReady {\n        MagicLoading()\n    }\n}"
            )
            .tabItem {
                Text("基础")
            }
            
            MagicDiffView(
                oldText: "Simple text\nAnother line",
                newText: "Modified text\nAnother line\nExtra line",
                showLineNumbers: false
            )
            .tabItem {
                Text("无行号")
            }
            
            // 新增代码示例
            MagicDiffView(
                oldText: "",
                newText: "struct ContentView: View {\n    var body: some View {\n        Text(\"Hello, World!\")\n            .padding()\n    }\n}"
            )
            .tabItem {
                Text("新增")
            }
            
            // 删除代码示例
            MagicDiffView(
                oldText: "struct ContentView: View {\n    var body: some View {\n        Text(\"Hello, World!\")\n            .padding()\n    }\n}",
                newText: ""
            )
            .tabItem {
                Text("删除")
            }
            
            // 代码块删除示例
            MagicDiffView(
                oldText: "struct UserView: View {\n    @State private var username = \"\"\n    @State private var password = \"\"\n    \n    var body: some View {\n        VStack {\n            TextField(\"用户名\", text: $username)\n            SecureField(\"密码\", text: $password)\n            Button(\"登录\") {\n                // 处理登录逻辑\n            }\n        }\n        .padding()\n    }\n}",
                newText: "struct UserView: View {\n    @State private var username = \"\"\n    \n    var body: some View {\n        VStack {\n            TextField(\"用户名\", text: $username)\n        }\n        .padding()\n    }\n}"
            )
            .tabItem {
                Text("删除块")
            }
            
            // 混合变更示例
            MagicDiffView(
                oldText: "class ImageLoader {\n    private var cache: [URL: UIImage] = [:]\n    \n    func loadImage(from url: URL) -> UIImage? {\n        if let cached = cache[url] {\n            return cached\n        }\n        \n        // 从网络加载图片\n        return nil\n    }\n}",
                newText: "class ImageLoader {\n    private var cache: [URL: UIImage] = [:]\n    private let queue = DispatchQueue(label: \"com.app.imageloader\")\n    \n    func loadImage(from url: URL) async throws -> UIImage {\n        if let cached = cache[url] {\n            return cached\n        }\n        \n        let (data, _) = try await URLSession.shared.data(from: url)\n        guard let image = UIImage(data: data) else {\n            throw ImageError.invalidData\n        }\n        \n        queue.async {\n            self.cache[url] = image\n        }\n        \n        return image\n    }\n    \n    enum ImageError: Error {\n        case invalidData\n    }\n}"
            )
            .tabItem {
                Text("混合")
            }
            
            // 折叠功能演示
            MagicDiffView(
                oldText: "import SwiftUI\n\nstruct ContentView: View {\n    @State private var count = 0\n    @State private var name = \"\"\n    @State private var isEnabled = true\n    @State private var items: [String] = []\n    \n    var body: some View {\n        VStack {\n            Text(\"Hello, World!\")\n            Text(\"Counter: \\(count)\")\n            Button(\"Increment\") {\n                count += 1\n            }\n            TextField(\"Name\", text: $name)\n            Toggle(\"Enabled\", isOn: $isEnabled)\n            \n            List(items, id: \\.self) { item in\n                Text(item)\n            }\n            \n            Button(\"Add Item\") {\n                items.append(\"Item \\(items.count + 1)\")\n            }\n        }\n        .padding()\n    }\n}",
                newText: "import SwiftUI\n\nstruct ContentView: View {\n    @State private var count = 0\n    @State private var name = \"\"\n    @State private var isEnabled = true\n    @State private var items: [String] = []\n    @State private var showAlert = false\n    \n    var body: some View {\n        VStack {\n            Text(\"Hello, SwiftUI!\")\n            Text(\"Counter: \\(count)\")\n            Button(\"Increment\") {\n                count += 1\n                if count > 10 {\n                    showAlert = true\n                }\n            }\n            TextField(\"Name\", text: $name)\n            Toggle(\"Enabled\", isOn: $isEnabled)\n            \n            List(items, id: \\.self) { item in\n                Text(item)\n            }\n            \n            Button(\"Add Item\") {\n                items.append(\"Item \\(items.count + 1)\")\n            }\n        }\n        .padding()\n        .alert(\"Count is high!\", isPresented: $showAlert) {\n            Button(\"OK\") { }\n        }\n    }\n}",
                enableCollapsing: true,
                minUnchangedLines: 3
            )
            .tabItem {
                Text("折叠")
            }
            
            // 无折叠对比
            MagicDiffView(
                oldText: "import SwiftUI\n\nstruct ContentView: View {\n    @State private var count = 0\n    @State private var name = \"\"\n    @State private var isEnabled = true\n    @State private var items: [String] = []\n    \n    var body: some View {\n        VStack {\n            Text(\"Hello, World!\")\n            Text(\"Counter: \\(count)\")\n            Button(\"Increment\") {\n                count += 1\n            }\n            TextField(\"Name\", text: $name)\n            Toggle(\"Enabled\", isOn: $isEnabled)\n            \n            List(items, id: \\.self) { item in\n                Text(item)\n            }\n            \n            Button(\"Add Item\") {\n                items.append(\"Item \\(items.count + 1)\")\n            }\n        }\n        .padding()\n    }\n}",
                newText: "import SwiftUI\n\nstruct ContentView: View {\n    @State private var count = 0\n    @State private var name = \"\"\n    @State private var isEnabled = true\n    @State private var items: [String] = []\n    @State private var showAlert = false\n    \n    var body: some View {\n        VStack {\n            Text(\"Hello, SwiftUI!\")\n            Text(\"Counter: \\(count)\")\n            Button(\"Increment\") {\n                count += 1\n                if count > 10 {\n                    showAlert = true\n                }\n            }\n            TextField(\"Name\", text: $name)\n            Toggle(\"Enabled\", isOn: $isEnabled)\n            \n            List(items, id: \\.self) { item in\n                Text(item)\n            }\n            \n            Button(\"Add Item\") {\n                items.append(\"Item \\(items.count + 1)\")\n            }\n        }\n        .padding()\n        .alert(\"Count is high!\", isPresented: $showAlert) {\n            Button(\"OK\") { }\n        }\n    }\n}",
                enableCollapsing: false
            )
            .tabItem {
                Text("无折叠")
            }
            
            // 指定默认语言示例
            MagicDiffView(
                oldText: "// 旧版本 JavaScript 代码\nfunction calculateTotal(items) {\n  var total = 0;\n  for (var i = 0; i < items.length; i++) {\n    total += items[i].price;\n  }\n  return total;\n}",
                newText: "// 新版本 JavaScript 代码\nfunction calculateTotal(items) {\n  // 使用 reduce 方法计算总和\n  const total = items.reduce((sum, item) => {\n    return sum + item.price;\n  }, 0);\n  \n  return total;\n}"
            )
            .tabItem {
                Text("指定语言")
            }
            
            // 语言检测和详细日志示例
            MagicDiffView(
                oldText: "struct OldView: View {\n    var body: some View {\n        Text(\"Hello\")\n    }\n}",
                newText: "struct NewView: View {\n    @State private var message = \"Hello, World!\"\n    \n    var body: some View {\n        VStack {\n            Text(message)\n                .font(.title)\n            Button(\"Update\") {\n                message = \"Updated!\"\n            }\n        }\n        .padding()\n    }\n}",
                verbose: true  // 启用详细日志
            )
            .tabItem {
                Text("语言检测")
            }
        }
    }
}

// MARK: - Preview

#Preview("MagicDiffPreviewView") {
    MagicDiffPreviewView()
        .inMagicContainer()
}

/// 动态文本变化演示视图
/// 用于测试 MagicDiffView 在父视图状态变化时的重新创建行为
struct DynamicTextPreview: View {
    @State private var oldText = ""
    @State private var newText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // 状态显示
            VStack(alignment: .leading, spacing: 8) {
                Text("当前状态:")
                    .font(.headline)
                Text("oldText: \(oldText.isEmpty ? "空" : "\(oldText.count) 字符")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("newText: \(newText.isEmpty ? "空" : "\(newText.count) 字符")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // MagicDiffView
            MagicDiffView(
                oldText: oldText,
                newText: newText,
                verbose: true
            )
        }
        .padding()
        .onAppear {
            // 延迟 1 秒后设置 Swift 代码
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    oldText = """
                    struct OldView: View {
                        var body: some View {
                            Text("Hello")
                        }
                    }
                    """
                    
                    newText = """
                    struct NewView: View {
                        @State private var message = "Hello, World!"
                        
                        var body: some View {
                            VStack {
                                Text(message)
                                    .font(.title)
                                Button("Update") {
                                    message = "Updated!"
                                }
                            }
                            .padding()
                        }
                    }
                    """
                }
            }
        }
    }
}

#Preview("动态文本变化") {
    DynamicTextPreview()
        .inMagicContainer()
}

#Preview("语言检测测试") {
    let swiftCode = """
    import SwiftUI
    
    struct TestView: View {
        @State private var count = 0
        
        var body: some View {
            Text("Count: \\(count)")
        }
    }
    """
    
    return MagicDiffView(
        oldText: "",
        newText: swiftCode,
        verbose: true
    )
    .inMagicContainer()
}

#Preview("调试语言检测") {
    struct DebugLanguageDetectionView: View {
        @State private var oldText = ""
        @State private var newText = ""
        @State private var detectedLanguage: CodeLanguage = .plainText
        
        var body: some View {
            VStack(spacing: 20) {
                // 状态显示
                VStack(alignment: .leading, spacing: 8) {
                    Text("调试信息:")
                        .font(.headline)
                    Text("oldText: \(oldText.isEmpty ? "空" : "\(oldText.count) 字符")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("newText: \(newText.isEmpty ? "空" : "\(newText.count) 字符")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("检测到的语言: \(detectedLanguage.rawValue)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // 手动检测按钮
                Button("手动检测语言") {
                    let textToDetect = newText.isEmpty ? oldText : newText
                    detectedLanguage = SyntaxHighlighter.detectLanguage(textToDetect, verbose: true)
                }
                .buttonStyle(.borderedProminent)
                
                // MagicDiffView
                MagicDiffView(
                    oldText: oldText,
                    newText: newText,
                    verbose: true
                )
            }
            .padding()
            .onAppear {
                // 延迟 1 秒后设置 Swift 代码
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        oldText = """
                        struct OldView: View {
                            var body: some View {
                                Text("Hello")
                            }
                        }
                        """
                        
                        newText = """
                        struct NewView: View {
                            @State private var message = "Hello, World!"
                            
                            var body: some View {
                                VStack {
                                    Text(message)
                                        .font(.title)
                                    Button("Update") {
                                        message = "Updated!"
                                    }
                                }
                                .padding()
                            }
                        }
                        """
                        
                        // 手动检测一次
                        let textToDetect = newText.isEmpty ? oldText : newText
                        detectedLanguage = SyntaxHighlighter.detectLanguage(textToDetect, verbose: true)
                    }
                }
            }
        }
    }
    
    return DebugLanguageDetectionView()
        .inMagicContainer()
}
