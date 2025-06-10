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
        }
    }
}

// MARK: - Preview

#Preview("MagicDiffPreviewView") {
    MagicDiffPreviewView()
        .inMagicContainer()
}
