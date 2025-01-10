import Foundation

/// DateComponentsFormatter 的扩展，提供预配置的时间格式化器
public extension DateComponentsFormatter {
    /// 缩写格式的时间格式化器
    ///
    /// 此格式化器配置为：
    /// - 显示小时、分钟和秒钟
    /// - 使用缩写样式（如：2h 30m 15s）
    ///
    /// # 示例
    /// ```swift
    /// let interval: TimeInterval = 9015 // 2小时30分15秒
    /// let formatted = DateComponentsFormatter.abbreviated.string(from: interval)
    /// print(formatted) // 输出: "2h 30m 15s"
    /// ```
    static let abbreviated: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    /// 位置格式的时间格式化器
    ///
    /// 此格式化器配置为：
    /// - 仅显示分钟和秒钟
    /// - 使用位置样式（如：04:30）
    /// - 对短于两位的数字进行补零
    ///
    /// 适用于：
    /// - 音频播放时长显示
    /// - 视频播放时长显示
    /// - 倒计时显示
    ///
    /// # 示例
    /// ```swift
    /// let interval: TimeInterval = 270 // 4分30秒
    /// let formatted = DateComponentsFormatter.positional.string(from: interval)
    /// print(formatted) // 输出: "04:30"
    /// ```
    static let positional: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
}

#if DEBUG
import SwiftUI

/// 时间格式化演示视图
struct DateComponentsFormatterDemoView: View {
    let intervals: [(String, TimeInterval)] = [
        ("2小时30分15秒", 9015),
        ("45分30秒", 2730),
        ("3分45秒", 225),
        ("30秒", 30)
    ]
    
    var body: some View {
        TabView {
            // 基础演示
            MagicThemePreview {
                VStack(spacing: 20) {
                    // 缩写格式部分
                    VStack(alignment: .leading, spacing: 12) {
                        Text("缩写格式")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 8) {
                            ForEach(intervals, id: \.0) { title, interval in
                                MagicKeyValue(
                                    key: title,
                                    value: DateComponentsFormatter.abbreviated.string(from: interval) ?? "-"
                                )
                            }
                        }
                        .padding()
                        .background(.background.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // 位置格式部分
                    VStack(alignment: .leading, spacing: 12) {
                        Text("位置格式")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 8) {
                            ForEach(intervals, id: \.0) { title, interval in
                                MagicKeyValue(
                                    key: title,
                                    value: DateComponentsFormatter.positional.string(from: interval) ?? "-"
                                )
                            }
                        }
                        .padding()
                        .background(.background.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
            }
            .tabItem {
                Image(systemName: "1.circle.fill")
                Text("基础")
            }
            
            // 应用场景演示
            MagicThemePreview {
                VStack(spacing: 20) {
                    // 音频播放场景
                    VStack(alignment: .leading, spacing: 12) {
                        Text("音频播放")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 8) {
                            MagicKeyValue(key: "当前时间", value: DateComponentsFormatter.positional.string(from: 125) ?? "-")
                            MagicKeyValue(key: "总时长", value: DateComponentsFormatter.positional.string(from: 245) ?? "-")
                            MagicKeyValue(key: "剩余时间", value: DateComponentsFormatter.abbreviated.string(from: 120) ?? "-")
                        }
                        .padding()
                        .background(.background.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // 运动计时场景
                    VStack(alignment: .leading, spacing: 12) {
                        Text("运动计时")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 8) {
                            MagicKeyValue(key: "跑步时长", value: DateComponentsFormatter.abbreviated.string(from: 3600) ?? "-")
                            MagicKeyValue(key: "休息时间", value: DateComponentsFormatter.positional.string(from: 300) ?? "-")
                            MagicKeyValue(key: "总计时间", value: DateComponentsFormatter.abbreviated.string(from: 3900) ?? "-")
                        }
                        .padding()
                        .background(.background.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
            }
            .tabItem {
                Image(systemName: "2.circle.fill")
                Text("场景")
            }
        }
    }
}

#Preview("DateComponentsFormatter 演示") {
    NavigationStack {
        DateComponentsFormatterDemoView()
    }
}
#endif
