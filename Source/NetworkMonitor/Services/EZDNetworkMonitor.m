//
//  EZDNetworkMonitor.m
//  EasyDebug
//
//  Created by songheng on 2020/12/25.
//

#import "EZDNetworkMonitor.h"
#import "NSURLSessionConfiguration+EasyDebug.h"
#import "EZDHTTPProtocol.h"

@implementation EZDNetworkMonitor

+ (instancetype)shared{
    static EZDNetworkMonitor *ins;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[self alloc] init];
    });
    return ins;
}

- (instancetype)init {
    if (self = [super init]) {
        self.ignoreUrlList = [NSMutableArray new];
    }
    return self;
}

/// EasyDebug会通过runtime调用此方法，不要修改方法签名
+ (void)config{
    [NSURLSessionConfiguration dg_hookDefaultSessionConfiguration];
    [EZDHTTPProtocol registerSelf];
    EZDNetworkMonitor.shared.isOn = YES;
}

@end
