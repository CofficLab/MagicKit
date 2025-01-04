import SwiftUI

// MARK: - Folder Content View

struct FolderContentView: View {
    let url: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
                if contents.isEmpty {
                    Text("文件夹为空")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    List(contents, id: \.path) { itemURL in
                        itemURL
                            .makeMediaView()
                            .verticalPadding(0)
                            .hideActions()
                    }
                    .border(.blue)
                    .listStyle(.plain)
                }
            } else {
                Text("无法读取文件夹内容")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }
}

// MARK: - Folder Content Modifier

struct FolderContentModifier: ViewModifier {
    let url: URL
    let isVisible: Bool

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content

            if isVisible && url.isDirectory {
                FolderContentView(url: url)
                    .frame(minHeight: 300)
            }
        }
    }
}

#Preview("Media View") {
    MediaViewPreviewContainer()
}
