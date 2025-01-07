import Combine
import SwiftUI

struct URLEventsPreview: View {
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

#Preview {
    URLEventsPreview()
}
