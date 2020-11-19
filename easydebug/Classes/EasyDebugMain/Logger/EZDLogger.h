//
//  EZDLogger.h
//  easydebug
//
//  Created by Song on 2018/8/21.
//

#import <Foundation/Foundation.h>
#import "EZDLoggerModel.h"
#import "EZDFilter.h"
#import "EasyDebug.h"

@class WKScriptMessage;

@class EZDLogger;

@protocol EZDLoggerDelegate <NSObject>

- (void)logger:(EZDLogger *)logger logsDidChange:(NSArray<EZDLoggerModel *> *)chageLogs;

@end

@interface EZDLogger : NSObject

@property (strong,nonatomic) NSMutableArray<EZDLoggerModel *> *logModels;
@property (strong,nonatomic) EZDFilter *filterItem;
@property (nonatomic, weak) EZDLogger *sourceLogger;

- (EZDLogger *)subLogerWithFilterItem:(EZDFilter *)filterItem;

- (void)recordNetRequestWithRequest:(NSURLRequest *)request parameter:(NSDictionary *)param response:(id)response;
- (void)recordBusinessLogicWithTag:(NSString *)tag level:(kEZDLogLevel)level param:(NSDictionary *)param log:(NSString *)log,...;
- (void)recordEventTrackWithEventTrackerName:(NSString *)trackerName
                                   eventName:(NSString *)eventName
                                       param:(NSDictionary *)param;
- (void)recordWebviewLoadURL:(NSURLRequest *)request;
- (void)recordJSMessageWithMessage:(WKScriptMessage *)message;

- (void)recordEventWithTypeName:(NSString *)typeName
                 abstractString:(NSString *)abstractString
                      parameter:(NSDictionary *)parameter
                      timeStamp:(NSTimeInterval)timeStamp;

- (void)updateLogModelsWithFilter;
- (void)clearLogs;

- (void)addDelegate:(id<EZDLoggerDelegate>)delegate;
- (void)removeDelegate:(id<EZDLoggerDelegate>)delegate;
- (void)removeAllDelegates;

@end
