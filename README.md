# easydebug

[![CI Status](https://img.shields.io/travis/Song/easydebug.svg?style=flat)](https://travis-ci.org/Song/easydebug)
[![Version](https://img.shields.io/cocoapods/v/easydebug.svg?style=flat)](https://cocoapods.org/pods/easydebug)
[![License](https://img.shields.io/cocoapods/l/easydebug.svg?style=flat)](https://cocoapods.org/pods/easydebug)
[![Platform](https://img.shields.io/cocoapods/p/easydebug.svg?style=flat)](https://cocoapods.org/pods/easydebug)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Feature

- 可视化的Log数据，详细且清晰的log信息
- 性能监控控件，实时查看设备资源使用状态
- APM : 当APP发生性能问题时，生成问题发生时的快照信息
- Debug options : 以非侵入的方式为APP添加调试选项（需要手动根据具体需求实现）
- 支持在电脑上的Web端查看log
- [AOP] APP端内网络请求log
- [AOP] Console log
- [AOP] WKWebview网络请求log
- [AOP] 卡顿检测
- [AOP] CPU过载检测
- [AOP] 内存过载检测

TBD :
- 设备信息
- [AOP] WKWebview页面浏览记录log
- [AOP] WKWebview JS Message log
- [AOP] Crash log
- [AOP] JS error log
- [AOP] App delegate log(launch/openurl/deviceid/etc)
- [AOP] 开销检测
- [AOP] 请求拦截
- [AOP] 生成性能报告
- [AOP] Object Map(支持查询)
- [AOP] View层级

## Installation

Podfile 中加入:

```ruby
pod 'EasyDebugTool'
```

## Use
EasyDebugTool 在debug环境会自动运行，无需执行任何代码。  
如果你需要一些进阶性的功能，才需要导入部分头文件，比如："Debug Options"、打点信息记录等。

### Debug log
EZDRecord<Type>方法是用于记录log的， 但是EazyDebugTool 采用AOP形式，通常情况下，你不需要调用任何record方法。 只在某些特殊情况（比如记录打点）时才可能需要用到EazyDebug的记录方法。

```Objective-C
#import <EasyDebug.h> 
EZDRecordEvent(@"Event Type", 
                    @"abstractString, like:request.URL.absoluteString", 
                    Event parameter, 
                    timestamp(0 for now));
``` 

### Debug Options
```Objective-C
[EasyDebug regiestOptions:[EZDOptionsExample class]];
``` 
Debug options 具体使用方法见 EZDOptionsExample.

### APM
APM默认开启，如果需要手动控制： 
```Objective-C
    [EZDClientAPM startMonitoring];
    [EZDClientAPM addLogObserver:self];
```
Webview 网络请求拦截可能导致一些问题，如果出现问题，可以用以下方式关闭它:
```Objective-C
[EZDAPMHTTPProtocol WKWebViewNetworkMonitoring:NO];
```
接收APM日志（需要```[EZDClientAPM addLogObserver:self]```）: 
```Objective-C
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSString *fileString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    NSLog(@"APM new log : \n type : %@ \n content : %@", type, fileString);
```

## Author

RggComing, songhengdsg@outlook.com

## License

easydebug is available under the MIT license. See the LICENSE file for more info.
