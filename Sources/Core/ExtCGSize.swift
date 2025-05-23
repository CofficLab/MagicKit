import Foundation

/// CGSize 类型的扩展，提供常用设备尺寸和实用方法
///
/// 这个扩展为CGSize类型添加了常用iOS和macOS设备的标准尺寸常量，
/// 以及一些实用的属性，便于在开发中快速引用和判断尺寸特性。
///
/// ## 使用示例:
/// ```swift
/// // 使用预定义的设备尺寸
/// let iPhoneSize = CGSize.iPhone
/// 
/// // 检查尺寸是否为正方形
/// let isSquare = iPhoneSize.isSquare // false
/// 
/// // 获取尺寸的字符串描述
/// let sizeDescription = iPhoneSize.description // "390x844"
/// ```
public extension CGSize {
    /// iPhone SE 的标准屏幕尺寸 (375x667 点)，适用于较小的iPhone设备
    static let iPhoneSE = CGSize(width: 375, height: 667)
    /// 标准iPhone的屏幕尺寸 (390x844 点)，适用于iPhone 12/13/14等
    static let iPhone = CGSize(width: 390, height: 844)
    /// 大尺寸iPhone Plus的屏幕尺寸 (428x926 点)，适用于iPhone Plus系列
    static let iPhonePlus = CGSize(width: 428, height: 926)
    /// 最大尺寸iPhone的屏幕尺寸 (430x932 点)，适用于iPhone Pro Max系列
    static let iPhoneMax = CGSize(width: 430, height: 932)
    /// iPad Mini的标准屏幕尺寸 (744x1133 点)
    static let iPadMini = CGSize(width: 744, height: 1133)
    /// 标准iPad的屏幕尺寸 (820x1180 点)
    static let iPad = CGSize(width: 820, height: 1180)
    /// iPad Pro 11英寸的屏幕尺寸 (834x1194 点)
    static let iPadPro11 = CGSize(width: 834, height: 1194)
    /// iPad Pro 12.9英寸的屏幕尺寸 (1024x1366 点)
    static let iPadPro12 = CGSize(width: 1024, height: 1366)
    /// 标准Mac窗口的参考尺寸 (1024x768 点)
    static let mac = CGSize(width: 1024, height: 768)
    
    /// 判断尺寸是否为正方形
    ///
    /// 当宽度等于高度时返回true，否则返回false
    var isSquare: Bool {
        width == height
    }

    /// 获取尺寸的字符串描述
    ///
    /// 返回格式为"宽度x高度"的字符串，例如"390x844"
    var description: String {
        "\(width)x\(height)"
    }
}
