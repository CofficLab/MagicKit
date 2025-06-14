import SwiftUI

struct OpenPreivewView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 网络链接
                Group {
                    Text("网络链接示例").font(.headline)
                    
                    // 单个打开按钮
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("智能打开（自动识别链接类型）：")
                            Spacer()
                            URL.sample_web_mp3_kennedy.makeOpenButton()
                        }
                    }
                    
                    // 网页浏览器按钮
                    VStack(alignment: .leading, spacing: 12) {
                        Text("指定浏览器打开：")
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("• 默认浏览器：")
                                Spacer()
                                URL.sample_web_mp3_kennedy.makeOpenButton(.browser)
                            }
                            HStack {
                                Text("• Safari 浏览器：")
                                Spacer()
                                URL.sample_web_mp3_kennedy.makeOpenButton(.safari)
                            }
                            HStack {
                                Text("• Chrome 浏览器：")
                                Spacer()
                                URL.sample_web_mp3_kennedy.makeOpenButton(.chrome)
                            }
                        }
                    }
                }

                Divider()

                // 本地文件
                Group {
                    Text("本地文件示例").font(.headline)
                    
                    // 单个打开按钮
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("智能打开（自动识别文件类型）：")
                            Spacer()
                            URL.sample_temp_txt.makeOpenButton()
                        }
                    }
                    
                    // 文件管理
                    VStack(alignment: .leading, spacing: 12) {
                        Text("文件管理：")
                        HStack {
                            Text("• 在访达中显示并选中：")
                            Spacer()
                            URL.sample_temp_txt.makeOpenButton(.finder)
                        }
                    }
                    
                    // 文本编辑器 - 系统图标
                    VStack(alignment: .leading, spacing: 12) {
                        Text("文本编辑器（系统图标）：")
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("• 系统文本编辑器：")
                                Spacer()
                                URL.sample_temp_txt.makeOpenButton(.textEdit)
                            }
                            HStack {
                                Text("• Xcode 开发环境：")
                                Spacer()
                                URL.sample_temp_txt.makeOpenButton(.xcode)
                            }
                            HStack {
                                Text("• VS Code 编辑器：")
                                Spacer()
                                URL.sample_temp_txt.makeOpenButton(.vscode)
                            }
                            HStack {
                                Text("• Cursor AI 编辑器：")
                                Spacer()
                                URL.sample_temp_txt.makeOpenButton(.cursor)
                            }
                            HStack {
                                Text("• Trae 开发工具：")
                                Spacer()
                                URL.sample_temp_txt.makeOpenButton(.trae)
                            }
                        }
                    }
                    
                    #if os(macOS)
                    // 文本编辑器 - 真实应用图标
                    VStack(alignment: .leading, spacing: 12) {
                        Text("文本编辑器（真实应用图标）：")
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("• 系统文本编辑器：")
                                Spacer()
                                URL.sample_temp_txt.makeOpenButton(.textEdit, useRealIcon: true)
                            }
                            HStack {
                                Text("• Xcode 开发环境：")
                                Spacer()
                                URL.sample_temp_txt.makeOpenButton(.xcode, useRealIcon: true)
                            }
                            HStack {
                                Text("• VS Code 编辑器：")
                                Spacer()
                                URL.sample_temp_txt.makeOpenButton(.vscode, useRealIcon: true)
                            }
                            HStack {
                                Text("• Cursor AI 编辑器：")
                                Spacer()
                                URL.sample_temp_txt.makeOpenButton(.cursor, useRealIcon: true)
                            }
                            HStack {
                                Text("• Trae 开发工具：")
                                Spacer()
                                URL.sample_temp_txt.makeOpenButton(.trae, useRealIcon: true)
                            }
                        }
                    }
                    #endif
                    
                    // 其他工具
                    VStack(alignment: .leading, spacing: 12) {
                        Text("其他工具：")
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("• 预览应用查看：")
                                Spacer()
                                URL.sample_temp_txt.makeOpenButton(.preview)
                            }
                            HStack {
                                Text("• 终端中打开目录：")
                                Spacer()
                                URL.sample_temp_txt.makeOpenButton(.terminal)
                            }
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