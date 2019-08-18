//
//  EZDLogger.m
//  easydebug
//
//  Created by Song on 2018/8/21.
//

#import "EZDLogger.h"
#import "EZDDefine.h"
#import "EasyDebug.h"
#import <WebKit/WebKit.h>

#import "NSObject+EZDAddition.h"

@interface EZDLogger ()

@property (strong,nonatomic) NSMutableArray<EZDLoggerModel *> *originLogs;
@property (strong,nonatomic) NSHashTable *loggerDelegates;
@property (strong,nonatomic) UIWebView *webV;

@end

@implementation EZDLogger

- (instancetype)init{
    if (self = [super init]) {
        self.logModels = [[NSMutableArray alloc] init];
        self.originLogs = [[NSMutableArray alloc] init];
        self.loggerDelegates = [NSHashTable weakObjectsHashTable];
        self.logConfig =  @{
                            kEZDNetRequestType:@"Net request",
                            kEZDEventTrackType:@"Event track",
                            kEZDWebviewRequestType:@"Webview request",
                            kEZDJSMessageType:@"JS message",
                            };
        self.filterItem = [[EZDFilter alloc] initWithName:@"EZDLoggerDefaultFilter"];
    }
    return self;
}

#pragma mark - record funcs
- (void)recordNetRequestWithRequest:(NSURLRequest *)request parameter:(NSDictionary *)param response:(id)response{
    NSDictionary *resonseDict = nil;
    if ([response isKindOfClass:[NSError class]]) {
        NSError *err = (NSError *)response;

        resonseDict = [err userInfo];
    }else{
        resonseDict = EZD_NotNullDict(response);
    }
    NSDictionary *rparameter = @{
                                @"targetURL":EZD_NotNullString(request.URL.absoluteString),
                                @"method":EZD_NotNullString(request.HTTPMethod),
                                @"header":EZD_NotNullDict(request.allHTTPHeaderFields),
                                @"param":EZD_NotNullDict(param),
                                @"response":resonseDict,
                                };
    [self recordEventWithTypeName:kEZDNetRequestType abstractString:request.URL.absoluteString parameter:rparameter timeStamp:[[NSDate date] timeIntervalSince1970]];
}

- (void)recordEventTrackWithEventTrackerName:(NSString *)trackerName
                                   eventName:(NSString *)eventName
                                       param:(NSDictionary *)param{
    NSDictionary *rparameter = @{
                                @"trackerName":EZD_NotNullString(trackerName),
                                @"eventName":EZD_NotNullString(eventName),
                                @"param":EZD_NotNullDict(param),
                                };
    NSString *abStr = [NSString stringWithFormat:@"%@->%@",NotNullString(trackerName),NotNullString(eventName)];
    [self recordEventWithTypeName:kEZDEventTrackType abstractString:abStr parameter:rparameter timeStamp:[[NSDate date] timeIntervalSince1970]];
}

- (void)recordWebviewRequest:(NSURLRequest *)request{
    NSString *userAgent = [self.webV stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSDictionary *requestParam = request.HTTPBody.length ? [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:nil] : @{};
    NSDictionary *rparameter = @{
                                 @"targetURL":EZD_NotNullString(request.URL.absoluteString),
                                 @"header":EZD_NotNullDict(request.allHTTPHeaderFields),
                                 @"param":EZD_NotNullDict(requestParam),
                                 @"user-agent":EZD_NotNullString(userAgent),
                                 };
    [self recordEventWithTypeName:kEZDWebviewRequestType abstractString:request.URL.absoluteString parameter:rparameter timeStamp:[[NSDate date] timeIntervalSince1970]];
}

- (void)recordJSMessageWithMessage:(WKScriptMessage *)message{
#if EZDEBUG_DEBUGLOG
    NSString *abStr = NotNullString(message.name);
    NSString *userAgent = [self.webV stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSDictionary *rparameter = @{
                                 @"targetURL":EZD_NotNullString(message.frameInfo.request.URL.absoluteString),
                                 @"name":abStr,
                                 @"user-agent":userAgent,
                                 @"header":EZD_NotNullDict(message.frameInfo.request.allHTTPHeaderFields),
                                 @"body":EZD_NotNullObj(message.body),
                                 };
    [self recordEventWithTypeName:kEZDJSMessageType abstractString:abStr parameter:rparameter timeStamp:[[NSDate date] timeIntervalSince1970]];
}

- (void)recordEventWithTypeName:(NSString *)typeName abstractString:(NSString *)abstractString parameter:(NSDictionary *)parameter timeStamp:(NSTimeInterval)timeStamp{
    [EZDFilter regiestTypeName:typeName];
    
    EZDLoggerModel *model = [EZDLoggerModel modelWithTypeName:typeName abstractString:abstractString parameter:parameter timeStamp:timeStamp];
    model.displayTypeName = self.logConfig[typeName];
    
    [self.originLogs addObject:model];
    if ([self.filterItem judgeLogModel:model]) {
        [self.logModels addObject:model];
        [self callDelegateMethodWithMethod:@selector(logger:logsDidChange:) params:self,@[model],nil];
    }
#endif
}

- (void)updateLogModelsWithFilter{

    if (!self.filterItem.filterItems.count) {
        self.logModels = [self.originLogs mutableCopy];
    }else{
        [self.logModels removeAllObjects];
        [self.originLogs enumerateObjectsUsingBlock:^(EZDLoggerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.filterItem judgeLogModel:obj] ? [self.logModels addObject:obj] : nil;
        }];
    }
}

- (void)clearLogs{
    [self.logModels removeAllObjects];
    [self.originLogs removeAllObjects];
    [self callDelegateMethodWithMethod:@selector(logger:logsDidChange:) params:self,@[],nil];
}

#pragma mark - delegate funcs
- (void)addDelegate:(id<EZDLoggerDelegate>)delegate{
    if (![delegate conformsToProtocol:objc_getProtocol("EZDLoggerDelegate")]) {
        return;
    }
    
    if (![self.loggerDelegates containsObject:delegate]) {
        delegate ? [self.loggerDelegates addObject:delegate] : nil;
    }
}

- (void)removeDelegate:(id<EZDLoggerDelegate>)delegate{
    [self.loggerDelegates removeObject:delegate];
}

- (void)removeAllDelegates{
    [self.loggerDelegates removeAllObjects];
}

- (void)callDelegateMethodWithMethod:(SEL)selector params:(id)firstObj,...{
#if EZDEBUG_DEBUGLOG
    NSMutableArray *objs = [NSMutableArray array];
    if (firstObj) {
        va_list argsList;
        [objs addObject:firstObj];
        va_start(argsList, firstObj);
        id arg;
        while ((arg = va_arg(argsList, id))) {
            [objs addObject:arg];
        }
        va_end(argsList);
    }
    
    NSEnumerator *enumerator = [self.loggerDelegates objectEnumerator];
    id<EZDLoggerDelegate> delegate;
    while ((delegate = [enumerator nextObject])) {
        if ([delegate respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate performSelector:selector withObject:objs.firstObject withObject:objs.count>=2?objs[1]:nil];
            });
#pragma clang diagnostic pop
        }
    }
#endif
}

#pragma mark - getter && setter
- (UIWebView *)webV{
    if (!_webV) {
        _webV = [UIWebView new];
    }
    return _webV;
}

@end
