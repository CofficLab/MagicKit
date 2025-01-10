import Combine

import SwiftUI

struct URLEventsPreview: View {
    var body: some View {
        MagicThemePreview {
            TabView {
                // 下载进度监听
                DownloadProgressView()
                    .tabItem {
                        Image(systemName: "arrow.down.circle")
                        Text("下载进度")
                    }

                // 文件夹监听
                DirectoryChangesView()
                    .tabItem {
                        Image(systemName: "folder")
                        Text("文件夹变化")
                    }
            }
        }
    }
}

// MARK: - 下载进度视图

private struct DownloadProgressView: View {
    @State private var downloadProgress: Double = 0
    @State private var isFinished = false
    @State private var cancellable: AnyCancellable?

    var body: some View {
        VStack(spacing: 20) {
            // 下载进度示例
            VStack {
                Text("下载进度: \(Int(downloadProgress * 100))%")
                ProgressView(value: downloadProgress)
            }
            .padding()

            // 下载状态示例
            if isFinished {
                Text("下载已完成")
                    .foregroundStyle(.green)
            }

            // 测试按钮
            Button("开始监听") {
                let url = URL.documentsDirectory.appendingPathComponent("test.pdf")

                // 监听下载进度
                cancellable = url.onDownloading(
                    caller: "URLEventsPreview",
                    { progress in
                        downloadProgress = progress
                    }
                )

                // 监听下载完成
                cancellable = url.onDownloadFinished(
                    caller: "URLEventsPreview") {
                        isFinished = true
                    }
            }
        }
        .onDisappear {
            cancellable?.cancel()
        }
    }
}

// MARK: - 文件夹监听视图

private struct DirectoryChangesView: View {
    @StateObject private var viewModel = DirectoryViewModel()

    var body: some View {
        VStack(spacing: 16) {
            // 文件夹路径和打开按钮
            HStack {
                Text(viewModel.folderURL.path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer()
                
                viewModel.folderURL.makeOpenButton(showLabel: true)
            }
            .padding(.horizontal)
            
            // 状态日志
            if !viewModel.statusLog.isEmpty {
                Text(viewModel.statusLog)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // 文件列表
            if viewModel.files.isEmpty {
                ContentUnavailableView(
                    "暂无文件",
                    systemImage: "folder",
                    description: Text("开始监听后将显示文件列表")
                )
            } else {
                List {
                    ForEach(viewModel.files, id: \.url) { file in
                        FileItemView(file: file)
                    }
                }
                .listStyle(.plain)
            }

            // 控制按钮
            HStack(spacing: 20) {
                Button(viewModel.isMonitoring ? "停止监听" : "开始监听") {
                    if viewModel.isMonitoring {
                        viewModel.stopMonitoring()
                    } else {
                        viewModel.startMonitoring()
                    }
                }
                .buttonStyle(.borderedProminent)

                if viewModel.isMonitoring {
                    Text("文件数: \(viewModel.files.count)")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}

// MARK: - FileItemView

private struct FileItemView: View {
    let file: MetaWrapper

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 文件名和状态
            HStack {
                Image(systemName: file.isDirectory ? "folder.fill" : "doc.fill")
                    .foregroundStyle(file.isDirectory ? .blue : .gray)

                Text(file.fileName ?? "未知文件")
                    .font(.headline)

                Spacer()

                // 文件状态标签
                if file.isDownloading {
                    Label("下载中", systemImage: "arrow.down.circle")
                        .foregroundStyle(.blue)
                } else if file.isDownloaded {
                    Label("已下载", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            // 文件详情
            if !file.isDirectory {
                if let size = file.fileSize {
                    Text("大小: \(formatFileSize(size))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if file.isDownloading {
                    ProgressView(value: file.downloadProgress) {
                        Text("\(Int(file.downloadProgress * 100))%")
                            .font(.caption)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

// MARK: - DirectoryViewModel

private class DirectoryViewModel: ObservableObject {
    @Published var files: [MetaWrapper] = []
    @Published var isMonitoring = false
    @Published var statusLog = ""
    
    let folderURL = URL.documentsDirectory  // 添加文件夹 URL
    private var cancellable: AnyCancellable?
    
    func startMonitoring() {
        cancellable = folderURL.onDirectoryChanged(caller: "DirectoryPreview") { [weak self] files, isInitialFetch in
            guard let self = self else { return }

            self.files = files
            self.isMonitoring = true

            // 更新状态日志
            let timestamp = Self.getCurrentTime()
            if isInitialFetch {
                self.statusLog = "[\(timestamp)] 📂 收到初始数据：\(files.count) 个文件\n" + self.statusLog
            } else {
                self.statusLog = "[\(timestamp)] 📂 文件夹更新：\(files.count) 个文件\n" + self.statusLog
            }

            // 限制日志长度
            if self.statusLog.count > 1000 {
                self.statusLog = String(self.statusLog.prefix(1000))
            }
        }
    }

    func stopMonitoring() {
        cancellable?.cancel()
        isMonitoring = false
        files = []

        // 更新状态日志
        let timestamp = Self.getCurrentTime()
        statusLog = "[\(timestamp)] 🔚 停止监听文件夹\n" + statusLog
    }

    private static func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}

#Preview {
    URLEventsPreview()
}
