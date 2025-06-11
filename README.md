# MagicKit

MagicKit 是一个 Swift Package，提供了一些便捷的图像处理工具和功能。

## 模块功能

### Shell-File
提供文件系统相关的 Shell 命令封装，例如检查目录/文件是否存在、创建/删除文件和目录、获取文件大小和权限等。

### Shell-Git
提供 Git 命令的封装，例如检查 Git 仓库状态、获取分支信息、提交日志、远程仓库信息等。

## 要求

- iOS 13.0+ / macOS 14.0+
- Swift 5.5+

## 安装

### Swift Package Manager

MagicKit 可以通过 [Swift Package Manager](https://swift.org/package-manager/) 安装。

在您的 `Package.swift` 文件中，将以下内容添加到 dependencies 数组中:

## 测试

要运行 MagicKit 的单元测试，请在终端中导航到项目根目录，然后运行以下命令：

```bash
swift test
```

## 构建

```bash
swift build
```

## 预览功能

我们的预览视图现在集成了 `VDemoButtonWithLog` 组件，它可以直接显示 Shell 命令的执行结果或错误信息，方便调试和验证。

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
