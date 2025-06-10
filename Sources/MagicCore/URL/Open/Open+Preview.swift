import SwiftUI

struct OpenPreivewView: View {
    var body: some View {
        VStack(spacing: 20) {
            // 网络链接
            Group {
                Text("网络链接").font(.headline)

                URL.sample_web_mp3_kennedy.makeOpenButton()
                URL.sample_web_mp3_kennedy.makeOpenButton()
                URL.sample_web_mp3_kennedy.makeOpenButton()
            }

            Divider()

            // 本地文件
            Group {
                Text("本地文件").font(.headline)

                URL.sample_temp_txt.makeOpenButton()
                URL.sample_temp_txt.makeOpenButton()
                URL.sample_temp_txt.makeOpenButton()
            }
        }
        .padding()
    }
}

#Preview("Open Buttons") {
    OpenPreivewView()
        .inMagicContainer()
}
