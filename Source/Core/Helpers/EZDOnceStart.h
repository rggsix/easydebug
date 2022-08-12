//
//  EZDOnceStart.h
//  EasyDebug
//
//  Created by songheng on 2020/11/25.
//

#import <Foundation/Foundation.h>
#import "EZDLogModel.h"
#import "EasyDebug.h"

@class FMDatabaseQueue;
@class EZDLogDay;
@class EZDOnceStart;

NS_ASSUME_NONNULL_BEGIN

@protocol EZDOnceStartDelegate <NSObject>

- (void)onceStart:(EZDOnceStart *)onceStart logsDidChange:(NSArray<EZDLogModel *> *)chageLogs;

@end

///  一个OnceStart代表一个表，也就是一次启动的所有log
@interface EZDOnceStart : NSObject

//  ---------------- Start 相关信息 -----------------
///  是否为本次启动的log
@property (nonatomic, assign) BOOL isCurrentStartup;
///  表名（存入kTableNameOfStartList表作为一行）
@property (nonatomic, copy) NSString *tableName;
///  startup的时间
@property (nonatomic, strong) NSDate *logDate;
///  startup的时间(XXXX年XX月XX日 XX:XX:XX)
@property (nonatomic, copy) NSString *dateString;
///  本次启动是哪一天
@property (nonatomic, weak) EZDLogDay *day;
/**
 start不应持有dbq:
 因为他的dbq来自day，如果day被释放了，说明这个dbq不应存在了
 */
@property (nonatomic, weak) FMDatabaseQueue *dbq;

//  ---------------- log数据 ----------------
/**
 若为logModels空，会尝试去磁盘读取对应logs，
 并回调 EZDOnceStartDelegate 的 onceStart:logsDidChange:
 */
@property (strong,nonatomic) NSMutableArray<EZDLogModel *> *originLogs;
- (void)queryLogModelsIfNeed;

//  ---------------- log记录方法 ----------------
- (void)archiveLogModel:(EZDLogModel *)model;

//  ---------------- 代理 ----------------
- (void)addDelegate:(id<EZDOnceStartDelegate>)delegate;
- (void)removeDelegate:(id<EZDOnceStartDelegate>)delegate;
- (void)removeAllDelegates;


//  ---------------- 初始化 ----------------
- (instancetype)initWithWithDay:(EZDLogDay *)day
                      tableName:(NSString *)tableName;
///  如果没调上面的init方法，需要调一下prepare()
- (void)prepare;

@end

NS_ASSUME_NONNULL_END
