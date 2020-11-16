//
//  EasyDebug.h
//  easydebug
//
//  Created by Song on 2018/8/21.
//

#import <Foundation/Foundation.h>
#import "EZDOptions.h"
#import "EZDDefine.h"

#if EZDEBUG_DEBUGLOG
#define EZDRecordNetRequest(request_,param_,response_) [EasyDebug recordNetRequestWithRequest:request_ parameter:param_ response:response_]
#define EZDRecordEventTrack(trackerName_,eventName_,param_) [EasyDebug recordEventTrackWithEventTrackerName:trackerName_ eventName:eventName_ param:param_]
#define EZDRecordWebviewLoadURL(request_) [EasyDebug recordWebviewLoadURL:request_]
#define EZDRecordJSMessage(messageBody_) [EasyDebug recordJSMessageWithMessage:messageBody_]
#define EZDRecordEvent(typeName_,abstractString_,parameter_,timeStamp_) [EasyDebug recordEventWithTypeName:typeName_ abstractString:abstractString_ parameter:parameter_ timeStamp:timeStamp_]
#else
#define EZDRecordNetRequest(request_,param_,response_) nil
#define EZDRecordEventTrack(trackerName_,eventName_,param_) nil
#define EZDRecordWebviewLoadURL(request_) nil
#define EZDRecordJSMessage(message_) nil
#define EZDRecordEvent(typeName_,abstractString_,parameter_,timeStamp_) nil
#endif

@class EZDDisplayer;
@class EZDLogger;


static NSString * const kEZDNetRequestType = @"[Net request log]";
static NSString * const kEZDConsoleType = @"[Console log]";
static NSString * const kEZDAppInfoType = @"[App info log]";
static NSString * const kEZDEventTrackType = @"[Event track log]";
///  Webview加载了什么页面（URL）
static NSString * const kEZDWebviewLoadURLType = @"[Webview load URL log]";
///  Webview发出的所有请求(html/JS/image/css/...)
static NSString * const kEZDWebviewRequestType = @"[Webview request log]";
static NSString * const kEZDJSMessageType = @"[JS Message log]";

@class WKScriptMessage;

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
 Record a event track

 @param trackerName -> the name of the SDK or anything to distinguish the track type , such as "Amplitude"、"Adjust" and so on.
 @param eventName -> the name of event.
 @param param the -> parameters dictionary of event.
 */
+ (void)recordEventTrackWithEventTrackerName:(NSString *)trackerName
                                   eventName:(NSString *)eventName
                                       param:(NSDictionary *)param;

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
 Record a log

 @param typeName -> The name of the log
 @param abstractString -> A short description of the log , just like "Net Request -> google" , or null .
 @param parameter -> The parameter of the log , such as @{ @"requestParam":@{...}, @"response":@{...} }, or any info want to record
 @param timeStamp -> Time of the log , if zero , default is [NSDate date].
 */
+ (void)recordEventWithTypeName:(NSString *)typeName
                 abstractString:(NSString *)abstractString
                      parameter:(NSDictionary *)parameter
                      timeStamp:(NSTimeInterval)timeStamp;

+ (void)regiestOptions:(Class)optionHandleClass;

@end
