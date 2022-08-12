//
//  DebugArchiveManager.h
//  EasyDebug
//
//  Created by songheng on 2020/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class EZDLogModel;
@class EZDLogDay;
@class EZDOnceStart;

static NSString * const kDebugLogFilePrefix = @"debug_log_";

@interface EZDLogManager : NSObject

@property (nonatomic, strong, readonly) NSDateFormatter *fileDateAndTimeFormatter;
@property (nonatomic, strong, readonly) NSDateFormatter *fileDateFormatter;

+ (instancetype)shared;

/**
 加载所有log文件、表信息
 */
- (void)loadLogDayList:(void(^)(NSArray<EZDLogDay *> *logDays))callback;

/**
 存储log
 */
- (void)recordLogWithTag:(NSString *)tag
                 content:(NSDictionary *)content
                complete:(os_block_t _Nullable)complete;

- (void)syncRecordLogWithTag:(NSString *)tag
                     content:(NSDictionary *)content;

/**
 删除某个表
 @content table 要删的table
 */
- (void)deleteStart:(EZDOnceStart *)start complete:(os_block_t)complete;
- (void)deleteAllStarts:(os_block_t)complete;

@end

NS_ASSUME_NONNULL_END
