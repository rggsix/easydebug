//
//  EZDDebugServerResponse.m
//  HoldCoin
//
//  Created by Song on 2019/2/26.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDDebugServerResponse.h"
#import "EZDBaseURLNode.h"
#import "EZDDefine.h"

static EZDDebugServerResponse *_c_r404;
static EZDDebugServerResponse *_c_index;

@implementation EZDDebugServerResponse

#if EZDDEBUG_SERVER_SUPPORT
+ (EZDDebugServerResponse *)r404{
    _c_r404 = [self new];
    _c_r404.GCDDataResponse = [GCDWebServerDataResponse responseWithData:[NSData dataWithContentsOfFile:[[EZDBaseURLNode baseHTMLBundle] pathForResource:@"_404" ofType:@"html"]] contentType:kEZDHTMLContentTypeTextHTML];
    return _c_r404;
}

+ (EZDDebugServerResponse *)index{
    NSString *path = [[EZDBaseURLNode baseHTMLBundle] pathForResource:@"index" ofType:@"html"];
    _c_index = [self responseWithPath:path contentType:kEZDHTMLContentTypeTextHTML];
    return _c_index;
}

+ (EZDDebugServerResponse *)responseWithPath:(NSString *)path contentType:(kEZDHTMLContentType)contentType{
    NSData *data = nil;
    
    if (contentType == kEZDHTMLContentTypeTextHTML) {
        NSArray<NSString *> *pathAndQuery = [path componentsSeparatedByString:@"?"];
        
        NSURLComponents *cp = [NSURLComponents componentsWithString:path];
        NSMutableDictionary *queryDict = [NSMutableDictionary new];
        [[cp queryItems] enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.value && obj.name) queryDict[obj.name] = obj.value;
        }];
        
        GCDWebServerDataResponse *GCDDataresponse = [GCDWebServerDataResponse responseWithHTMLTemplate:pathAndQuery.firstObject variables:queryDict];
        EZDDebugServerResponse *response = [self new];
        response.GCDDataResponse = GCDDataresponse;
        return response;
    } else {
        data = [NSData dataWithContentsOfFile:path];
    }
    
    if (!data.length) {
        return [self r404];
    }
    
    GCDWebServerDataResponse *GCDDataresponse = [GCDWebServerDataResponse responseWithData:data contentType:contentType];
    EZDDebugServerResponse *response = [self new];
    response.GCDDataResponse = GCDDataresponse;
    return response;
}

+ (EZDDebugServerResponse *)responseWithDict:(NSDictionary *)dict{
    GCDWebServerDataResponse *GCDDataresponse = [GCDWebServerDataResponse responseWithJSONObject:EZD_NotNullDict(dict) contentType:kEZDHTMLContentTypeJson];
    EZDDebugServerResponse *response = [self new];
    response.GCDDataResponse = GCDDataresponse;
    return response;
}
#endif

@end
