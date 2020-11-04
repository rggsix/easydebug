//
//  EZDRequestAgent.m
//  easydebug_Example
//
//  Created by EDZ on 2019/8/19.
//  Copyright © 2019 Song. All rights reserved.
//

#import "EZDRequestAgent.h"
#import "EasyDebug.h"

@implementation EZDRequestAgent

+ (EZDRequestAgent *)shareAgent{
    static EZDRequestAgent *agent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        agent = [[self alloc] init];
        agent.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    });
    return agent;
}

+ (NSURLSessionDataTask *)GetWithParam:(NSDictionary *)param url:(NSString *)url callback:(void (^)(BOOL, NSDictionary * _Nonnull, NSError * _Nonnull))callback{
    EZDRequestAgent *agent = [EZDRequestAgent shareAgent];
    return [agent GET:url parameters:param headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        EZDRecordNetRequest(task.originalRequest, param, responseObject);
        callback ? callback(YES, responseObject, nil) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        EZDRecordNetRequest(task.originalRequest, param, error);
        callback ? callback(YES, nil, error) : nil;
    }];
}

@end
