//
//  NSURLSessionManager+EasyDebug.m
//  EasyDebug
//
//  Created by songheng on 2020/12/25.
//

#import "NSURLSessionConfiguration+EasyDebug.h"
#import "EZDHTTPProtocol.h"
#import "EasyDebugUtil.h"

@implementation NSURLSessionConfiguration (EasyDebug)

+ (void)dg_hookDefaultSessionConfiguration {
    //  AFN需要hook defaultSessionConfiguration, 自行将protocol加入
    [EasyDebugUtil exchangeClassOriginMethod:@selector(defaultSessionConfiguration) newMethod:@selector(dg_defaultSessionConfiguration) mclass:[self class]];
}

+ (NSURLSessionConfiguration *)dg_defaultSessionConfiguration {
    NSURLSessionConfiguration *configuration = [self dg_defaultSessionConfiguration];
    [self dg_setSessionProtocolEnabled:YES forSessionConfiguration:configuration];
    return configuration;
}

+ (void)dg_setSessionProtocolEnabled:(BOOL)enabled forSessionConfiguration:(NSURLSessionConfiguration *)configuration{
    if ([configuration respondsToSelector:@selector(protocolClasses)]
        && [configuration respondsToSelector:@selector(setProtocolClasses:)]) {
        NSMutableArray *protocolClasses = [NSMutableArray arrayWithArray:configuration.protocolClasses];
        Class protoCls = [EZDHTTPProtocol class];
        if (enabled && ![protocolClasses containsObject:protoCls]) {
            [protocolClasses insertObject:protoCls atIndex:0];
        } else if (!enabled && [protocolClasses containsObject:protoCls]) {
            [protocolClasses removeObject:protoCls];
        }
        configuration.protocolClasses = protocolClasses;
    }
}

@end
