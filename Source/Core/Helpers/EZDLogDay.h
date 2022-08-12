//
//  EZDLogDay.h
//  EasyDebug
//
//  Created by songheng on 2020/11/26.
//

#import <Foundation/Foundation.h>
#import "EZDOnceStart.h"

@class FMDatabaseQueue;

NS_ASSUME_NONNULL_BEGIN

///  一个day代表一个sqlite文件，也就是一天产生的所有次启动的log
@interface EZDLogDay : NSObject

@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, strong) FMDatabaseQueue *dbq;
///   哪一天的Logs
@property (nonatomic, strong) NSDate *logDate;
///   哪一天的Logs(XXXX年XX月XX日)
@property (nonatomic, copy) NSString *dateString;
@property (nonatomic, strong) NSMutableArray<EZDOnceStart *> *starts;

- (instancetype)initWithFilePath:(NSString *)filePath;

- (EZDOnceStart *)createStartWithTableName:(NSString *)tableName;
- (void)deleteStart:(EZDOnceStart *)start;
- (void)closeDatabase;

@end

NS_ASSUME_NONNULL_END
