//
//  EZDURLNodeEasyDebugLog.m
//  HoldCoin
//
//  Created by Song on 2019/2/26.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDURLNodeEasyDebugLog.h"
#import "EasyDebug.h"
#import "EZDLogger.h"
#import "EZDDefine.h"
#import "GCDWebServerRequest.h"

#import "EazyDebug+Private.h"

@implementation EZDURLNodeEasyDebugLog

#if EZDDEBUG_SERVER_SUPPORT

EZDDebugServerRegiestNodeClass

+ (NSString *)nodePath{
    return @"easydebuglog";
}

#endif

@end

static NSMutableArray *_c_connectingLogListSTs;

@implementation EZDURLNodeDebugNodeList

#if EZDDEBUG_SERVER_SUPPORT

EZDDebugServerRegiestNodeClass

+ (NSString *)nodePath{
    return @"debugloglist";
}

+ (EZDDebugServerResponse *)respondsForGCDRequest:(GCDWebServerRequest *)request{
    NSURLComponents *cp = [NSURLComponents componentsWithString:request.URL.absoluteString];
    __block NSString *f_index = nil;
    __block NSString *request_st = nil;
    __block NSString *first_request = nil;
    [[cp queryItems] enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:@"f_index"]) {
            f_index = obj.value;
        }else if ([obj.name isEqualToString:@"request_st"]) {
            request_st = obj.value;
        }else if ([obj.name isEqualToString:@"first_request"]) {
            first_request = obj.value;
        }
    }];
    
    if (!f_index) return [EZDDebugServerResponse responseWithDict:@{}];
    
    NSInteger i_f_index = f_index.integerValue;

    NSArray<EZDLoggerModel *> *logs = [[EasyDebug shareEasyDebug].defaultLogger.logModels copy];
    NSArray<EZDLoggerModel *> *totalLogs = [logs copy];
    
    bool needRefresh = ![[self connectingSTs] containsObject:request_st] && !first_request.boolValue;
    
    if ((request_st.length && needRefresh) || (first_request.boolValue)) {
        [[self connectingSTs] addObject:request_st];
    }
    
    if (i_f_index > ((NSInteger)logs.count) - 1) return [EZDDebugServerResponse responseWithDict:@{@"needRefresh":@(needRefresh)}];
    
    logs = [logs subarrayWithRange:NSMakeRange(i_f_index, logs.count - i_f_index)];
    
//    NSLog(@"Request Debug log list at index %ld , total log count : %lu",(long)i_f_index,(unsigned long)[EasyDebug shareEasyDebug].defaultLogger.logModels.count);
    
    if (!logs) return [EZDDebugServerResponse responseWithDict:@{}];
    
    NSMutableArray<NSDictionary *> *dictArr = [[NSMutableArray alloc] initWithCapacity:logs.count];
    [logs enumerateObjectsUsingBlock:^(EZDLoggerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *abStr = [NSString stringWithFormat:@"%@ -> %@",obj.displayTypeName,obj.abstractString];
        [dictArr addObject:@{@"name":abStr,@"date":obj.dateDes,@"index":@([totalLogs indexOfObject:obj]),@"body":EZD_NotNullDict(obj.parameter)}];
    }];

    return [EZDDebugServerResponse responseWithDict:@{@"needRefresh":@(needRefresh),@"dataList":dictArr}];
}

+ (NSMutableArray<NSString *> *)connectingSTs{
    if (!_c_connectingLogListSTs) {
        _c_connectingLogListSTs = [NSMutableArray new];
    }
    return _c_connectingLogListSTs;
}

#endif

@end


@implementation EZDURLNodeDetailDebugInfo

#if EZDDEBUG_SERVER_SUPPORT

EZDDebugServerRegiestNodeClass

+ (NSString *)nodePath{
    return @"debuglogdetail";
}

+ (EZDDebugServerResponse *)respondsForGCDRequest:(GCDWebServerRequest *)request{
    NSURLComponents *cp = [NSURLComponents componentsWithString:request.URL.absoluteString];
    __block NSString *index = nil;
    [[cp queryItems] enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:@"index"]) {
            index = obj.value;
        }
    }];
    
    NSArray<EZDLoggerModel *> *logs = [EasyDebug shareEasyDebug].defaultLogger.logModels;

    if (!index || (index.integerValue >= logs.count)) return [EZDDebugServerResponse r404];

    return [EZDDebugServerResponse responseWithDict:logs[index.integerValue].parameter];
}

#endif

@end
