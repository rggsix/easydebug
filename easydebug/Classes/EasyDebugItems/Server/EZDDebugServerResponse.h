//
//  EZDDebugServerResponse.h
//  HoldCoin
//
//  Created by Song on 2019/2/26.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GCDWebServerDataResponse.h>

typedef NSString * kEZDHTMLContentType NS_EXTENSIBLE_STRING_ENUM;
static kEZDHTMLContentType const kEZDHTMLContentTypeTextHTML = @"text/html";
static kEZDHTMLContentType const kEZDHTMLContentTypeTextCSS = @"text/css";
static kEZDHTMLContentType const kEZDHTMLContentTypeTextJS = @"application/x-javascript";
static kEZDHTMLContentType const kEZDHTMLContentTypeJson = @"application/json" ;

@interface EZDDebugServerResponse : NSObject

@property (strong,nonatomic) GCDWebServerDataResponse *GCDDataResponse;
@property (strong,nonatomic,class,readonly) EZDDebugServerResponse *r404;
@property (strong,nonatomic,class,readonly) EZDDebugServerResponse *index;

+ (EZDDebugServerResponse *)responseWithDict:(NSDictionary *)dict;

+ (EZDDebugServerResponse *)responseWithPath:(NSString *)path contentType:(kEZDHTMLContentType)contentType;

@end

