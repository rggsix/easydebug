# easydebug

[![CI Status](https://img.shields.io/travis/Song/easydebug.svg?style=flat)](https://travis-ci.org/Song/easydebug)
[![Version](https://img.shields.io/cocoapods/v/easydebug.svg?style=flat)](https://cocoapods.org/pods/easydebug)
[![License](https://img.shields.io/cocoapods/l/easydebug.svg?style=flat)](https://cocoapods.org/pods/easydebug)
[![Platform](https://img.shields.io/cocoapods/p/easydebug.svg?style=flat)](https://cocoapods.org/pods/easydebug)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

easydebug is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'EasyDebugTool'
```

## Use
EasyDebugTool will run itself in DEBUG, just include it.
```
#import <EasyDebug.h>
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}
```

### Debug log
EazyDebugTool hooked the network automatic, In normal times, you do not need to call "EZDRecordNetRequest" to observe net request.

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
EZDOptionsExample implementation see Example code.

### APM
start monitoring: 
```Objective-C
    [EZDClientAPM startMonitoring];
    [EZDClientAPM addLogObserver:self];
```
recieve APM log file: 
```Objective-C
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSString *fileString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    NSLog(@"APM new log : \n type : %@ \n content : %@", type, fileString);
```

## Author

RggComing, songhengdsg@outlook.com

## License

easydebug is available under the MIT license. See the LICENSE file for more info.
