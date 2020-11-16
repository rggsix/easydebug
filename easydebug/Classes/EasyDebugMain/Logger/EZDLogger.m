//
//  EZDLogger.m
//  easydebug
//
//  Created by Song on 2018/8/21.
//

#import "EZDLogger.h"

#import <WebKit/WebKit.h>
#import <objc/runtime.h>

#import "EZDDefine.h"
#import "EasyDebug.h"

#import "NSObject+EZDAddition.h"
#import "NSURLRequest+EZDAddition.h"

@interface EZDLogger () <EZDLoggerDelegate>

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
        self.filterItem = [[EZDFilter alloc] initWithName:@"EZDLoggerDefaultFilter"];
    }
    return self;
}

- (EZDLogger *)subLogerWithFilterItem:(EZDFilter *)filterItem {
    EZDLogger *nloger = [[EZDLogger alloc] init];
    nloger.originLogs = [self logModelsWithFilter:filterItem];
    nloger.filterItem = filterItem;
    nloger.sourceLogger = self;
    [self addDelegate:nloger];
    return nloger;
}

#pragma mark - record funcs
- (void)recordNetRequestWithRequest:(NSURLRequest *)request parameter:(NSDictionary *)param response:(id)response{
    NSDictionary *responseDict = [self handleResponse:response];
    NSDictionary *rparameter = @{
                                @"targetURL":EZD_NotNullString(request.URL.absoluteString),
                                @"method":EZD_NotNullString(request.HTTPMethod),
                                @"header":EZD_NotNullDict(request.allHTTPHeaderFields),
                                @"param":[self handleParamterWithParam:param request:request],
                                @"response":responseDict,
                                };
    
    NSString *logType = request.ezd_fromNative ? kEZDNetRequestType : kEZDWebviewRequestType;
    [self recordEventWithTypeName:logType abstractString:request.URL.absoluteString parameter:rparameter timeStamp:[[NSDate date] timeIntervalSince1970]];
}

- (void)recordEventTrackWithEventTrackerName:(NSString *)trackerName
                                   eventName:(NSString *)eventName
                                       param:(NSDictionary *)param{
    NSDictionary *rparameter = @{
                                @"trackerName":EZD_NotNullString(trackerName),
                                @"eventName":EZD_NotNullString(eventName),
                                @"param":EZD_NotNullDict(param),
                                };
    NSString *abStr = [NSString stringWithFormat:@"%@->%@",EZD_NotNullString(trackerName),EZD_NotNullString(eventName)];
    [self recordEventWithTypeName:kEZDEventTrackType abstractString:abStr parameter:rparameter timeStamp:[[NSDate date] timeIntervalSince1970]];
}

- (void)recordWebviewLoadURL:(NSURLRequest *)request{
    NSString *userAgent = [self.webV stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSDictionary *requestParam = request.HTTPBody.length ? [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:nil] : @{};
    NSDictionary *rparameter = @{
                                 @"targetURL":EZD_NotNullString(request.URL.absoluteString),
                                 @"header":EZD_NotNullDict(request.allHTTPHeaderFields),
                                 @"param":EZD_NotNullDict(requestParam),
                                 @"user-agent":EZD_NotNullString(userAgent),
                                 };
    [self recordEventWithTypeName:kEZDWebviewLoadURLType abstractString:request.URL.absoluteString parameter:rparameter timeStamp:[[NSDate date] timeIntervalSince1970]];
}

- (void)recordJSMessageWithMessage:(WKScriptMessage *)message{
#if EZDEBUG_DEBUGLOG
    NSString *abStr = EZD_NotNullString(message.name);
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
    model.displayTypeName = typeName;
    
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
        self.logModels = [self logModelsWithFilter:self.filterItem];
    }
}

- (void)clearLogs{
    ///  如果是sublogger做了clear，这些被删除的log也要从主logger同步移除
    [self.sourceLogger clearLogsFromArray:self.originLogs];
    [self.logModels removeAllObjects];
    [self.originLogs removeAllObjects];
    [self callDelegateMethodWithMethod:@selector(logger:logsDidChange:) params:self,@[],nil];
}

- (void)clearLogsFromArray:(NSArray<EZDLoggerModel *> *)logs {
    [self.originLogs removeObjectsInArray:logs];
    [self updateLogModelsWithFilter];
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

#pragma mark - EZDLoggerDelegate
- (void)logger:(EZDLogger *)logger logsDidChange:(NSArray<EZDLoggerModel *> *)chageLogs {
    [chageLogs enumerateObjectsUsingBlock:^(EZDLoggerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self recordEventWithTypeName:obj.typeName abstractString:obj.abstractString parameter:obj.parameter timeStamp:obj.timeStamp];
    }];
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

- (void)setFilterItem:(EZDFilter *)filterItem {
    _filterItem = filterItem;
    [self updateLogModelsWithFilter];
}

#pragma mark - util func
- (NSMutableArray<EZDLoggerModel *> *)logModelsWithFilter:(EZDFilter *)filter {
    NSMutableArray<EZDLoggerModel *> *filteredLogs = [NSMutableArray arrayWithCapacity:self.originLogs.count];
    [self.originLogs enumerateObjectsUsingBlock:^(EZDLoggerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [filter judgeLogModel:obj] ? [filteredLogs addObject:obj] : nil;
    }];
    return filteredLogs;
}

+ (NSDictionary *)errorResponseWithError:(NSError *)error {
    NSDictionary *userinfo = [[NSDictionary alloc] initWithDictionary:error.userInfo];
    
    NSDictionary *errorResponseDict = nil;
    
    NSString *htmlstr = nil;
    NSString *errorDesc = @"unknow error.";

    if(userinfo) {
          NSError *innerError = [userinfo valueForKey:@"NSUnderlyingError"];
          if(innerError) {
             NSDictionary *innerUserInfo = [[NSDictionary alloc] initWithDictionary:innerError.userInfo];
             if(innerUserInfo) {
                  if([innerUserInfo objectForKey:@"com.alamofire.serialization.response.error.data"]) {
                       htmlstr = [[NSString alloc] initWithData:[innerUserInfo objectForKey:@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
                      errorDesc = [innerUserInfo objectForKey:NSLocalizedDescriptionKey];
                  }
             }
          } else {
               htmlstr = [[NSString alloc] initWithData:[userinfo valueForKey:@"AFNetworkingOperationFailingURLResponseDataErrorKey"] encoding:NSUTF8StringEncoding];
          }
    }
    
    if (htmlstr.length) {
        NSData *errDesData = [htmlstr dataUsingEncoding:(NSUTF8StringEncoding)];
        NSError *htmlConvertErr = nil;
        NSAttributedString *htmlstr = [[NSAttributedString alloc] initWithData:errDesData options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:&htmlConvertErr];
        if (!htmlConvertErr) {
            errorResponseDict = @{@"desc":EZD_NotNullString(errorDesc),@"html":EZD_NotNullString([htmlstr string])};
        }
    }
    
    return errorResponseDict;
}

- (NSDictionary *)handleParamterWithParam:(id)param request:(NSURLRequest *)request {
    NSDictionary *paramDict = nil;
    if ([param isKindOfClass:[NSDictionary class]]) {
        paramDict = param;
    } else if ([param isKindOfClass:[NSString class]]) {
        NSString *paramStr = (NSString *)param;
        if (paramStr.length) {
            paramDict = [NSJSONSerialization JSONObjectWithData:[paramStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            
            if (!paramDict.allKeys.count && [paramStr containsString:@"="]) {
                NSURLComponents *comp = [NSURLComponents componentsWithString:[NSString stringWithFormat:@"https://x?%@", paramStr]];
                NSMutableDictionary *querys = [NSMutableDictionary dictionaryWithCapacity:comp.queryItems.count];
                [comp.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [querys setObject:EZD_NotNullString(obj.value) forKey:EZD_NotNullString(obj.name)];
                }];
                paramDict = [querys copy];
            }
            
            if (!paramDict.allKeys.count) {
                paramDict = @{@"__unknow_param":param};
            }
        } else {
            paramDict = @{};
        }

    } else if(param){
        paramDict = @{@"__unknow_param":EZD_NotNullString([param description])};
    } else {
        paramDict = @{};
    }
    
    //  append parameter from url query
    NSURLComponents *urlComp = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
    NSMutableDictionary *cptmpdict = [paramDict mutableCopy];
    [urlComp.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [cptmpdict setObject:EZD_NotNullString(obj.value) forKey:EZD_NotNullString(obj.name)];
    }];
    
    return [cptmpdict copy];
}

- (NSDictionary *)handleResponse:(id)response {
    NSDictionary *responseDict = nil;
    if ([response isKindOfClass:[NSError class]]) {
        responseDict = [EZDLogger errorResponseWithError:response];
        
        if (!responseDict.allKeys.count) {
            NSError *err = (NSError *)response;

            responseDict = EZD_NotNullDict([err userInfo]);
        }
    } else if(![response isKindOfClass:[NSDictionary class]]) {
        if ([response isKindOfClass:[NSString class]]) {
            NSData *data = [(NSString *)response dataUsingEncoding:(NSUTF8StringEncoding)];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json isKindOfClass:[NSDictionary class]]) {
                responseDict = json;
            } else {
                responseDict = @{@"__unknow_type_response":response};
            }
        } else {
            response = EZD_NotNullString([response description]);
            responseDict = @{@"__unknow_type_response":response};
        }
    } else{
        responseDict = EZD_NotNullDict(response);
    }
    
    return responseDict;
}

@end
