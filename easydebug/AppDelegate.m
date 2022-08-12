//
//  AppDelegate.m
//  QTConfig
//
//  Created by songheng on 2020/11/2.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "EasyDebug.h"
#import "EZDPerformance.h"
#import "EZDCrashMonitor.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [EasyDebug config:(EasyDebugNetMonitor | EasyDebugPerformance)];
    //  开启crash监听
    [EZDCrashMonitor config];

    //  自定义log abstract string，这个string是显示在log列表中，若无需要可不处理
    [EasyDebug.shared registerAbstractProviderForTag:@"Tracking" provider:^NSString * _Nullable(NSString * _Nullable tag, NSDictionary * _Nonnull content) {
        NSString *event_id = content[@"event_id"];
        NSString *page_id = content[@"page_id"];

        NSMutableString *absstr = [NSMutableString stringWithFormat:@"[%@]", content[@"logType"]];
        if (event_id != nil && event_id.length > 0) {
            [absstr appendFormat:@" <%@>", event_id];
        }
        [absstr appendFormat:@" %@", page_id];
        return absstr;
    }];

    //  记录一条log
    [EasyDebug logWithTag:@"Tracking" content:@{
        @"logType":@"PageViewEntry",
        @"event_id":@"testEvent1",
        @"page_id":@"testPage1",
        @"TestKey1":@"TestValue1",
    }];

    //  记录一条log
    [EasyDebug logWithTag:@"Tracking" content:@{
        @"logType":@"ActionEvent",
        @"page_id":@"testPage2",
        @"TestKey1":@"TestValue1",
    }];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MainViewController alloc] init]];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
