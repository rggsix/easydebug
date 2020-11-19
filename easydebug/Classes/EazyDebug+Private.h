//
//  EazyDebug+Private.h
//  easydebug
//
//  Created by qingting on 2020/11/19.
//  Copyright © 2020 Song. All rights reserved.
//

#ifndef EazyDebug_Private_h
#define EazyDebug_Private_h

#import "EasyDebug.h"

@class WKScriptMessage;

typedef NSString * _Nonnull const kEZDLogType;
static kEZDLogType kEZDNetRequestType = @"[Net request log]";
static kEZDLogType kEZDConsoleType = @"[Console log]";
static kEZDLogType kEZDAppInfoType = @"[App info log]";
///  Webview加载了什么页面（URL）
static kEZDLogType kEZDWebviewLoadURLType = @"[Webview load URL log]";
///  Webview发出的所有请求(html/JS/image/css/...)
static kEZDLogType kEZDWebviewRequestType = @"[Webview request log]";
static kEZDLogType kEZDJSMessageType = @"[JS Message log]";
///  业务逻辑log分类
static kEZDLogType kEZDBusinessLogicType = @"[Business logic log]";
///  打点记录log分类
static kEZDLogType kEZDEventTrackType = @"[Event track log]";

@interface EasyDebug : NSObject

@property (strong,nonatomic) EZDOptions *options;
@property (strong,nonatomic) EZDDisplayer *displayer;
@property (strong,nonatomic) EZDLogger *defaultLogger;

+ (instancetype)shareEasyDebug;

/**
 Record a net request log

 @param request -> the NSURLRequest instance of network request
 @param param -> the Parameters of network request
 @param response -> pass NSError if request failed
 */
+ (void)recordNetRequestWithRequest:(NSURLRequest *)request parameter:(NSDictionary *)param response:(id)response;

/**
 Record a webview request

 @param request -> the NSURLRequest instance
 */
+ (void)recordWebviewLoadURL:(NSURLRequest *)request;

/**
 Record a js message
 */
+ (void)recordJSMessageWithMessage:(WKScriptMessage *)message;

/**
 记录一个打点log

 @param trackerName -> 打点SDK名， 如："Amplitude"、"Adjust" 等.
 @param eventName -> 打点名称，开发或产品定义的，如："user_login".
 @param param the -> 打点具体参数，如：@{@"isLogin":@YES}.
 */
+ (void)recordEventTrackWithEventTrackerName:(NSString *_Nonnull)trackerName
                                   eventName:(NSString *_Nonnull)eventName
                                       param:(NSDictionary * _Nullable)param;

/**
 记录一个自定义类型的Log

 @param typeName -> log类型，如：[Video load]
 @param abstractString -> log的一个简短的内容，如：videoModel.url .
 @param parameter -> log的具体参数，如：@{
    @"video_id":@"abc",
    @"video_title":@"happy",
    ...
 }
 @param timeStamp -> Log时间，传0则使用 [NSDate date].
 */
+ (void)recordEventWithTypeName:(NSString *_Nonnull)typeName
                 abstractString:(NSString *_Nullable)abstractString
                      parameter:(NSDictionary *_Nullable)parameter
                      timeStamp:(NSTimeInterval)timeStamp;

@end

#endif /* EazyDebug_Private_h */
