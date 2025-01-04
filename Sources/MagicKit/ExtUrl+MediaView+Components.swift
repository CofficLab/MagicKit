import SwiftUI

// MARK: - Folder Content View
struct FolderContentView: View {
    let url: URL
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("文件夹内容")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.top, 12)
            
            if let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
                if contents.isEmpty {
                    Text("文件夹为空")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    List(contents, id: \.path) { itemURL in
                        itemURL.makeMediaView()
                            .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    }
                    .listStyle(.plain)
                }
            } else {
                Text("无法读取文件夹内容")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - Folder Content Modifier
struct FolderContentModifier: ViewModifier {
    let url: URL
    let isVisible: Bool
    
    func body(content: Content) -> some View {
        VStack(spacing: 16) {
            content
            
            if isVisible && url.isDirectory {
                FolderContentView(url: url)
                    .frame(minHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.bottom, 16)
    }
} 