# EasyDebug

![CocoaPods](https://img.shields.io/cocoapods/v/EasyDebug.svg)
![Platform](https://img.shields.io/cocoapods/p/EasyDebug.svg)
![License](https://img.shields.io/cocoapods/l/EasyDebug.svg)

`EasyDebug` 是一个轻量级的 iOS 调试日志工具库，旨在帮助开发者快速定位和解决问题。它提供了便捷的日志面板等功能，适用于开发和测试阶段。

## 功能特性

- **快捷键管理**：模拟器快捷键设置。
- **网络监听**: 自动监听网络请求信息。
- **设备指标监控**: MEM/CPU/FPS。
- **日志面板**：支持灵活的日志记录，方便调试网络请求和自定义日志。
- **轻量级**：无侵入性设计，易于集成到现有项目。

## 安装

### CocoaPods

`EasyDebug` 可以通过 [CocoaPods](https://cocoapods.org) 安装。编辑你的 `Podfile`，添加以下内容：

```ruby
pod 'EasyDebug'
```

然后运行以下命令：

```
pod install
```

## 手动安装
如果你不想使用 `CocoaPods`，也可以手动将 `EasyDebug` 集成到你的项目中：

1. 将 `EasyDebug` 仓库克隆到本地：
```
git clone https://github.com/rggsix/EasyDebug.git
```
2. 将 EasyDebug 文件夹拖入你的 Xcode 项目。
3. 在 Xcode 中，确保 EasyDebug 已添加到你的目标（Target）中。

## 使用方法
### 初始化
在你的 `AppDelegate` 或 `SceneDelegate` 中初始化 `EasyDebug`：
```swift
import EasyDebug

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
#if DEBUG
        //  初始化 EasyDebug
        EasyDebug.shared().isOn = true
        //  网络+性能监听
        EasyDebug.config(.init(rawValue: EasyDebugModule.netMonitor.rawValue | EasyDebugModule.performance.rawValue) ?? .netMonitor)
#endif

        //  记录一个日志 (建议Tag非空)
        EasyDebug.log(withTag: "AppLifecycle", content: [
            "type": "didFinishLaunchingWithOptions",
            "launchOptions": launchOptions ?? [:]
        ])
    }
}
```

### 可选配置
```
//  自定义日志列表中的缩略内容
EasyDebug.shared().registerAbstractProvider(forTag: "SomeIgnoredTag") { tag, contentDict in
    return contentDict["name"] as? String ?? "Unknown"
}

//  自定义判断 网络请求请求成功 or 失败, 失败请求在日志面板中将以红色展示
EZDNetworkMonitor.shared().responseJudgeBlock = { _, response in
    return ((response?["data"] as? [String: Any])?["code"] as? Int) != 0
}
        
//  需要忽略的网络请求 host
EZDNetworkMonitor.shared().ignoreUrlList = [ "some.thirdparty-api.com" ]
```

## 要求
- iOS 12.0 或更高版本
- Xcode 15.0 或更高版本
- Swift 5.0 或更高版本

## 贡献
欢迎为 EasyDebug 贡献代码！请按照以下步骤操作：
1. Fork 本仓库。
2. 创建你的功能分支（git checkout -b feature/AmazingFeature）。
3. 提交你的更改（git commit -m 'Add some AmazingFeature'）。
4. 推送到分支（git push origin feature/AmazingFeature）。
5. 创建一个 Pull Request。
请确保你的代码符合 Swift 编码规范。

## 许可证
EasyDebug 使用 MIT 许可证。详情请查看[文件]()。

## 联系方式
如果有任何问题或建议，请通过以下方式联系我们：

- **邮箱**：songhengdsg@icloud.com
- **GitHub Issues**：https://github.com/rggsix/EasyDebug/issues
