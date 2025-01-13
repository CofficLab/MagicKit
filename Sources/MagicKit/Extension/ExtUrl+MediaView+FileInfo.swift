import SwiftUI

/// 文件信息视图组件
///
/// 显示文件的基本信息，包括：
/// - 文件名
/// - 文件大小（可选）
/// - 文件状态（可选）
struct FileInfoSection: View {
    let url: URL
    let showFileSize: Bool
    let showFileStatus: Bool
    let showBorder: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(url.lastPathComponent)
                .font(.headline)
                .lineLimit(1)
                .overlay(borderOverlay(.green))
            
            HStack {
                if showFileSize {
                    Text(url.getSizeReadable())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .overlay(borderOverlay(.green))
                }
                
                if showFileStatus, let status = url.magicFileStatus {
                    Text(status)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .overlay(borderOverlay(.green))
                }
            }
        }
        .overlay(borderOverlay(.purple))
    }
    
    private func borderOverlay(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 0)
            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
            .foregroundColor(showBorder ? color : .clear)
    }
}

#Preview("File Info") {
    FileInfoSection(
        url: URL(fileURLWithPath: "/path/to/file.txt"),
        showFileSize: true,
        showFileStatus: true,
        showBorder: true
    )
    .padding()
} 