# MagicRootView - 通用 Toast 系统

一个功能完整、易于复用的 SwiftUI Toast 系统，整合了根视图容器功能。

## 功能特点

- ✅ **5 种 Toast 类型**：信息、成功、警告、错误、加载中
- ✅ **4 种显示模式**：覆盖层、横幅、底部、角落
- ✅ **优雅动画**：弹簧动画、拖拽关闭、旋转加载
- ✅ **自动管理**：定时消失、重复检测、内存清理
- ✅ **高度定制**：自定义图标、颜色、持续时间
- ✅ **跨平台**：支持 iOS 和 macOS
- ✅ **零依赖**：纯 SwiftUI 实现，无第三方依赖

## 快速开始

### 1. 基本使用

```swift
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MagicRootView {
                ContentView()
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var messageProvider = MagicMessageProvider()

    var body: some View {
        VStack {
            Button("显示成功消息") {
                messageProvider.showSuccess("操作完成！")
            }

            Button("显示错误消息") {
                messageProvider.showError("操作失败", subtitle: "请检查网络连接")
            }
        }
        .environmentObject(messageProvider)
    }
}
```

### 2. 使用便捷扩展

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello World")
        }
        .withMagicToast()  // 一行代码启用Toast系统
    }
}
```

## 详细用法

### Toast 类型

```swift
let messageProvider = MagicMessageProvider()

// 信息提示
messageProvider.showInfo("提示信息", subtitle: "详细说明")

// 成功提示
messageProvider.showSuccess("操作成功")

// 警告提示
messageProvider.showWarning("注意事项", subtitle: "请仔细阅读")

// 错误提示（不自动消失）
messageProvider.showError("错误信息", subtitle: "错误详情", autoDismiss: false)

// 加载状态
messageProvider.showLoading("正在处理...")
messageProvider.hideLoading()

// 自定义Toast
messageProvider.showCustom(
    systemImage: "heart.fill",
    color: .pink,
    title: "自定义消息",
    displayMode: .corner
)
```

### 显示模式

```swift
// 覆盖层（默认）- 屏幕中央
.showSuccess("成功", displayMode: .overlay)

// 横幅 - 从顶部滑下
.showError("错误", displayMode: .banner)

// 底部 - 从底部弹出
.showInfo("信息", displayMode: .bottom)

// 角落 - 在右上角显示
.showWarning("警告", displayMode: .corner)
```

### 操作结果 Toast

```swift
let messageProvider = MagicMessageProvider()

// 开始操作
messageProvider.operationStart("正在上传文件", details: "请稍等...")

do {
    // 执行操作
    try await performOperation()

    // 操作成功
    messageProvider.operationSuccess("上传完成", details: "文件已保存")
} catch {
    // 操作失败
    messageProvider.operationError("上传", error: error)
}

// 结束加载状态
messageProvider.operationEnd()
```

### 高级自定义

```swift
// 直接使用Toast管理器
let toastManager = MagicToastManager.shared

let customToast = MagicToastModel(
    type: .custom(systemImage: "star.fill", color: .yellow),
    title: "自定义Toast",
    subtitle: "完全自定义的消息",
    displayMode: .banner,
    duration: 5.0,
    autoDismiss: true,
    tapToDismiss: true,
    showProgress: true,
    onTap: {
        print("Toast被点击")
    },
    onDismiss: {
        print("Toast已消失")
    }
)

toastManager.show(customToast)
```

## 集成现有项目

### 替换现有 Toast 系统

如果你的项目已经有 Toast 系统，可以这样迁移：

```swift
// 旧代码
AlertToast.show("消息")

// 新代码
messageProvider.showInfo("消息")
```

### 与现有架构整合

```swift
// 在ViewModel中使用
class MyViewModel: ObservableObject {
    private let messageProvider = MagicMessageProvider()

    func performAction() {
        messageProvider.operationStart("处理中")

        // 异步操作
        Task {
            do {
                try await someAsyncOperation()
                await MainActor.run {
                    messageProvider.operationSuccess("完成")
                }
            } catch {
                await MainActor.run {
                    messageProvider.operationError("处理", error: error)
                }
            }
        }
    }
}

// 在View中注入
struct MyView: View {
    @StateObject private var viewModel = MyViewModel()

    var body: some View {
        // UI代码
        Button("执行操作") {
            viewModel.performAction()
        }
        .withMagicToast()
    }
}
```

## 最佳实践

### 1. 消息文案

```swift
// ✅ 好的实践
messageProvider.showSuccess("文件上传完成")
messageProvider.showError("网络连接失败", subtitle: "请检查网络设置后重试")

// ❌ 不好的实践
messageProvider.showSuccess("OK")
messageProvider.showError("Error")
```

### 2. 加载状态管理

```swift
// ✅ 确保加载状态被正确清理
func uploadFile() {
    messageProvider.showLoading("上传中...")

    defer {
        messageProvider.hideLoading()  // 无论成功失败都清理
    }

    // 执行上传操作
}
```

### 3. 错误处理

```swift
// ✅ 为重要错误禁用自动消失
messageProvider.showError(
    "保存失败",
    subtitle: "数据可能丢失，请重试",
    autoDismiss: false  // 让用户主动关闭
)

// ✅ 为一般错误启用自动消失
messageProvider.showError("网络超时", autoDismiss: true)
```

## 注意事项

1. **线程安全**：Toast 管理器内部处理了线程安全，可以在任何线程调用
2. **内存管理**：定时器会自动清理，无需手动管理
3. **重复消息**：相同类型和标题的 Toast 会自动替换，避免重复显示
4. **性能优化**：使用了延迟加载和动画优化，不会影响主界面性能

## 自定义主题

可以通过修改`MagicToastType`的颜色来自定义主题：

```swift
// 在MagicRootView.swift中修改颜色
var color: Color {
    switch self {
    case .info:
        return .blue      // 修改为你的品牌色
    case .success:
        return .green     // 修改为你的成功色
    // ...
    }
}
```

## 文件结构

将以下文件复制到你的项目中：

```
YourProject/
├── Components/
│   └── MagicRootView/
│       ├── MagicRootView.swift  // 主文件
│       └── README.md           // 说明文档
```

只需要一个文件即可使用完整的 Toast 系统！
