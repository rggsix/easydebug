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
pod 'easydebug'
```

## Use

### Debug log
```Objective-C
#import <EasyDebug.h> 
EZDRecordEvent(@"Event Type", 
                    @"abstractString, like:request.URL.absoluteString", 
                    Event parameter, 
                    timestamp(0 for now));
``` 
or use like "EZDRecordNetRequest(request_,param_,response_)" to record network.
```Objective-C
[agent GET:url parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)    {
        EZDRecordNetRequest(task.originalRequest, param, responseObject);
        callback ? callback(YES, responseObject, nil) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        EZDRecordNetRequest(task.originalRequest, param, error);
        callback ? callback(YES, nil, error) : nil;
}];
```

### Debug Options
```Objective-C
[EasyDebug regiestOptions:[EZDOptionsExample class]];
```

### APM
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

RggComing, songhengdsg@sohu.com

## License

easydebug is available under the MIT license. See the LICENSE file for more info.
