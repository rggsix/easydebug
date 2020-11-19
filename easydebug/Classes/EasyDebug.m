//
//  EasyDebug.m
//  easydebug
//
//  Created by Song on 2018/8/21.
//

#import "EasyDebug.h"
#import "EZDNSLogHooker.h"
#import "EZDDisplayer.h"
#import "EZDSystemUtil.h"

#import "EazyDebug+Private.h"

static EasyDebug *EasyDebugIns;

@interface EasyDebug()

@property (nonatomic,weak) UIWindow *window;

@end

@implementation EasyDebug

#if EZDEBUG_DEBUGLOG
+ (void)load{
    [self shareEasyDebug];
    [EZDNSLogHooker hookNSLog];
}
#endif

#pragma mark - init funcs
- (instancetype)initWithWindow:(UIWindow *)window{
#if EZDEBUG_DEBUGLOG
    if (self = [super init]) {
        self.displayer = [EZDDisplayer setupDisplayerWithWindow:window];
        self.defaultLogger = [[EZDLogger alloc] init];
        self.displayer.logger = self.defaultLogger;
    }
    return self;
#else
    return nil;
#endif
}

void EZDRegiestDebugOptions(Class _Nonnull optionHandleClass) {
    [EZDOptions regiestOptionInstace:optionHandleClass];
}

void EZDSetConsoleDisplayLogLevel(kEZDLogLevel level) {
    
}

+ (instancetype)shareEasyDebug{
#if EZDEBUG_DEBUGLOG
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        EasyDebugIns = [[self alloc] initWithWindow:[EZDSystemUtil currentWindow]];
    });
    return EasyDebugIns;
#else
    return nil;
#endif
}

#pragma mark - record funcs
+ (void)recordEventTrackWithEventTrackerName:(NSString *)trackerName
                                   eventName:(NSString *)eventName
                                       param:(NSDictionary *)param{
    EasyDebug *ins = [self shareEasyDebug];
    [ins.displayer.logger recordEventTrackWithEventTrackerName:trackerName eventName:eventName param:param];
}

void EZDBLLLog(NSString * _Nonnull log,...) {
#if EZDEBUG_DEBUGLOG
    va_list va;
    va_start(va, log);
    NSString *str = [[NSString alloc] initWithFormat:log arguments:va];
    va_end(va);

    EZDBLLLog_D(nil,
                kEZDLogLevelInfo,
                nil,
                str);
#endif
}

void EZDBLLLog_D(NSString * _Nullable tag,
                 kEZDLogLevel level,
                 NSDictionary *_Nullable param,
                 NSString * _Nonnull log,...) {
#if EZDEBUG_DEBUGLOG
    va_list va;
    va_start(va, log);
    NSString *str = [[NSString alloc] initWithFormat:log arguments:va];
    va_end(va);
    
    EasyDebug *ins = [EasyDebug shareEasyDebug];
    [ins.displayer.logger recordBusinessLogicWithTag:tag level:level param:param log:str];
#endif
}

+ (void)recordNetRequestWithRequest:(NSURLRequest *)request parameter:(NSDictionary *)param response:(id)response{
    EasyDebug *ins = [self shareEasyDebug];
    [ins.displayer.logger recordNetRequestWithRequest:request parameter:param response:response];
}

+ (void)recordWebviewLoadURL:(NSURLRequest *)request{
    EasyDebug *ins = [self shareEasyDebug];
    [ins.displayer.logger recordWebviewLoadURL:request];
}

+ (void)recordJSMessageWithMessage:(WKScriptMessage *)message{
    EasyDebug *ins = [self shareEasyDebug];
    [ins.displayer.logger recordJSMessageWithMessage:message];
}

+ (void)recordEventWithTypeName:(NSString *)typeName abstractString:(NSString *)abstractString parameter:(NSDictionary *)parameter timeStamp:(NSTimeInterval)timeStamp{
    EasyDebug *ins = [self shareEasyDebug];
    [ins.displayer.logger recordEventWithTypeName:typeName abstractString:abstractString parameter:parameter timeStamp:timeStamp];
}

@end
