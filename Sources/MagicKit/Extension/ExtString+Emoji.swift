import Foundation
import SwiftUI

extension String {
    /// 根据字符串内容生成相关的 emoji 并添加到原始内容前
    /// - Returns: emoji + 原始内容的组合字符串
    public var withContextEmoji: String {
        let emoji = self.generateContextEmoji()
        return "\(emoji) \(self)"
    }

    /// 根据字符串内容分析并生成相关的 emoji
    /// - Returns: 相关的 emoji
    private func generateContextEmoji() -> String {
        let lowercased = self.lowercased()

        // 跳过相关
        if lowercased.contains("skip") || lowercased.contains("ignore") || lowercased.contains("bypass") ||
            lowercased.contains("跳过") || lowercased.contains("忽略") || lowercased.contains("略过") {
            return "⏭️"
        }

        // 错误和警告
        if lowercased.contains("error") || lowercased.contains("fail") || lowercased.contains("crash") ||
            lowercased.contains("错误") || lowercased.contains("失败") || lowercased.contains("崩溃") {
            return "❌"
        }
        if lowercased.contains("warning") || lowercased.contains("warn") ||
            lowercased.contains("警告") || lowercased.contains("提醒") {
            return "⚠️"
        }

        // 成功和完成
        if lowercased.contains("success") 
        || lowercased.contains("complete") 
        || lowercased.contains("finish") 
        || lowercased.contains("ok") 
        || lowercased.contains("ready") 
        || lowercased.contains("done") 
        || lowercased.contains("成功") 
        || lowercased.contains("完成") 
        || lowercased.contains("结束") {
            return "✅"
        }

        // 网络相关
        if lowercased.contains("network") || lowercased.contains("http") || lowercased.contains("request") ||
            lowercased.contains("网络") || lowercased.contains("请求") || lowercased.contains("响应") {
            return "🌐"
        }

        // 同步相关
        if lowercased.contains("sync") || lowercased.contains("synchronize") || 
            lowercased.contains("同步") || lowercased.contains("同步中") || lowercased.contains("刷新") {
            return "🔄"
        }

        // 数据相关
        if lowercased.contains("data") || lowercased.contains("save") || lowercased.contains("load") ||
            lowercased.contains("数据") || lowercased.contains("保存") || lowercased.contains("加载") {
            return "💾"
        }

        // 初始化和配置
        if lowercased.contains("init") || lowercased.contains("setup") || lowercased.contains("config") ||
            lowercased.contains("初始化") || lowercased.contains("设置") || lowercased.contains("配置") {
            return "🚩"
        }

        // 更新和变化 (修改emoji避免重复)
        if lowercased.contains("update") || lowercased.contains("change") || lowercased.contains("modify") ||
            lowercased.contains("更新") || lowercased.contains("变化") || lowercased.contains("修改") {
            return "🍋"
        }

        // 调试和测试
        if lowercased.contains("debug") || lowercased.contains("test") || lowercased.contains("log") ||
            lowercased.contains("调试") || lowercased.contains("测试") || lowercased.contains("日志") {
            return "🔍"
        }

        // 性能相关
        if lowercased.contains("performance") || lowercased.contains("memory") || lowercased.contains("cpu") ||
            lowercased.contains("性能") || lowercased.contains("内存") || lowercased.contains("耗时") {
            return "📊"
        }

        // 用户交互
        if lowercased.contains("click") || lowercased.contains("tap") || lowercased.contains("touch") ||
            lowercased.contains("点击") || lowercased.contains("触摸") || lowercased.contains("手势") {
            return "👆"
        }

        // 默认返回一个通用的 emoji
        return "📝"
    }
}   

    struct StringEmojiPreview: View {
        let examples = [
            // 错误和警告
            "网络请求失败了",
            "警告：内存使用过高",

            // 成功和完成
            "数据保存成功",
            "任务完成",

            // 网络相关
            "发起网络请求",
            "HTTP响应超时",

            // 数据相关
            "正在加载数据",
            "开始保存文件",

            // 初始化和配置
            "初始化系统配置",
            "设置用户参数",

            // 更新和变化
            "更新用户信息",
            "修改配置文件",

            // 调试和测试
            "调试模式启动",
            "开始性能测试",

            // 性能相关
            "CPU使用率过高",
            "检测内存泄漏",

            // 用户交互
            "用户点击登录按钮",
            "检测到双指手势",

            // 跳过相关
            "跳过此步骤",
            "忽略错误继续",
        ]

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(examples, id: \.self) { text in
                    Text("原始文本：\(text)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("添加 Emoji：\(text.withContextEmoji)")
                        .font(.body)
                }
                .padding(.vertical, 4)
            }
        }
    }

    #Preview {
        StringEmojiPreview().inMagicContainer()
    }   
