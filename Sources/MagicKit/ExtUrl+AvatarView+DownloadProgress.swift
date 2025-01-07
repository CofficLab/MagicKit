import SwiftUI

extension AvatarView {
    /// 下载进度视图组件
    struct DownloadProgressView: View {
        let progress: Double
        
        var body: some View {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 4)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.accentColor, style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round
                    ))
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(progress * 100))%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    AvatarView.DownloadProgressView(progress: 0.75)
        .frame(width: 100, height: 100)
} 