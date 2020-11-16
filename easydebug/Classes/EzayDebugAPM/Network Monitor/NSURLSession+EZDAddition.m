//
//  NSURLSession+EZDAddition.m
//  easydebug_Example
//
//  Created by qingting on 2020/11/16.
//  Copyright © 2020 Song. All rights reserved.
//

#import "NSURLSession+EZDAddition.h"

#import "EZDAPMHooker.h"

#import "NSURLRequest+EZDAddition.h"

@implementation NSURLSession (EZDAddition)

+ (void)load {
    [EZDAPMHooker exchangeOriginMethod:@selector(dataTaskWithRequest:completionHandler:) newMethod:@selector(ezd_dataTaskWithRequest:completionHandler:) mclass:[NSURLSession class]];
    [EZDAPMHooker exchangeOriginMethod:@selector(dataTaskWithRequest:) newMethod:@selector(ezd_dataTaskWithRequest:) mclass:[NSURLSession class]];
}

- (NSURLSessionDataTask *)ezd_dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    NSURLSessionDataTask *task = [self ezd_dataTaskWithRequest:request completionHandler:completionHandler];
    //  If the request not from EZDAPM, we mark it as native request.
    if (!request.ezd_fromEZDAPM) {
        request.ezd_fromNative = YES;
        task.originalRequest.ezd_fromNative = YES;
        task.currentRequest.ezd_fromNative = YES;
    }
    return task;
}

- (NSURLSessionDataTask *)ezd_dataTaskWithRequest:(NSURLRequest *)request {
    NSURLSessionDataTask *task = [self ezd_dataTaskWithRequest:request];
    //  If the request not from EZDAPM, we mark it as native request.
    if (!request.ezd_fromEZDAPM) {
        request.ezd_fromNative = YES;
        task.originalRequest.ezd_fromNative = YES;
        task.currentRequest.ezd_fromNative = YES;
    }
    return task;
}

@end
