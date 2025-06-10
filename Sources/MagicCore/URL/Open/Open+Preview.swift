import SwiftUI

struct OpenPreivewView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 网络链接
                Group {
                    Text("网络链接").font(.headline)
                    
                    // 单个打开按钮
                    HStack {
                        Text("默认打开按钮：")
                        URL.sample_web_mp3_kennedy.makeOpenButton()
                    }
                    
                    // 网页浏览器按钮
                    VStack(alignment: .leading, spacing: 12) {
                        Text("网页浏览器：")
                        HStack(spacing: 8) {
                            URL.sample_web_mp3_kennedy.makeOpenInButton(.browser)
                            URL.sample_web_mp3_kennedy.makeOpenInButton(.safari)
                            URL.sample_web_mp3_kennedy.makeOpenInButton(.chrome)
                        }
                    }
                }

                Divider()

                // 本地文件
                Group {
                    Text("本地文件").font(.headline)
                    
                    // 单个打开按钮
                    HStack {
                        Text("默认打开按钮：")
                        URL.sample_temp_txt.makeOpenButton()
                    }
                    
                    // 所有支持的应用程序
                    VStack(alignment: .leading, spacing: 12) {
                        Text("所有支持的应用程序：")
                        HStack(spacing: 8) {
                            URL.sample_temp_txt.makeOpenInButton(.finder)
                            URL.sample_temp_txt.makeOpenInButton(.preview)
                            URL.sample_temp_txt.makeOpenInButton(.textEdit)
                            URL.sample_temp_txt.makeOpenInButton(.terminal)
                            URL.sample_temp_txt.makeOpenInButton(.xcode)
                            URL.sample_temp_txt.makeOpenInButton(.vscode)
                        }
                    }
                    
                    // 按应用类型分组
                    Group {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("文件浏览：")
                            URL.sample_temp_txt.makeOpenInButton(.finder)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("文本编辑：")
                            HStack(spacing: 8) {
                                URL.sample_temp_txt.makeOpenInButton(.textEdit)
                                URL.sample_temp_txt.makeOpenInButton(.xcode)
                                URL.sample_temp_txt.makeOpenInButton(.vscode)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("预览：")
                            URL.sample_temp_txt.makeOpenInButton(.preview)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("终端：")
                            URL.sample_temp_txt.makeOpenInButton(.terminal)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview("Open Buttons") {
    OpenPreivewView()
        .inMagicContainer()
}