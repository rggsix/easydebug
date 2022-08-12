//
//  EZDOnceStart.m
//  EasyDebug
//
//  Created by songheng on 2020/11/25.
//

#import "EZDOnceStart.h"
#import <objc/runtime.h>
#import "EasyDebugUtil.h"
#import "DebugCoreCategorys.h"
#import "EasyDebug.h"
#import "EZDLogManager.h"
#import "EZDLogDay.h"
#import <fmdb/FMDatabaseQueue.h>


@interface EZDOnceStart ()

@property (strong,nonatomic) NSHashTable *onceStartDelegates;

@end

@implementation EZDOnceStart

- (instancetype)init{
    if (self = [super init]) {
        self.originLogs = [[NSMutableArray alloc] init];
        self.onceStartDelegates = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (instancetype)initWithWithDay:(EZDLogDay *)day
                      tableName:(NSString *)tableName {
    if (self = [self init]) {
        self.tableName = tableName;
        self.dbq = day.dbq;
        self.day = day;
        [self prepare];
    }
    return self;
}

- (void)prepare {
    NSString *dateStr = self.tableName;
    if ([self.tableName hasPrefix:kDebugLogFilePrefix]) {
        dateStr = [self.tableName stringByReplacingOccurrencesOfString:kDebugLogFilePrefix withString:@""];
    }
    self.logDate = [EZDLogManager.shared.fileDateAndTimeFormatter dateFromString:dateStr];
    self.dateString = self.logDate.dg_timeString;
}

#pragma mark - record funcs

#pragma mark - database func
///  获取table中所有的log
- (void)queryLogModelsIfNeed {
    //  当天的不用查
    if (self.isCurrentStartup) {
        return;
    }
    //  已经查过的不用再查了
    if (self.originLogs.count) {
        return;
    }
    //  从数据库查询log 记录
    __weak typeof(self) weakSelf = self;
    [self.dbq inDatabase:^(FMDatabase * _Nonnull db) {
        NSMutableArray<EZDLogModel *> *models = [NSMutableArray array];
        NSString *sql = [NSString stringWithFormat:@"select * from %@;", weakSelf.tableName];
        FMResultSet *result = [db executeQuery:sql];
        while (result.next) {
            NSString *tag = [result stringForColumn:@"tag"];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataForColumn:@"content"] options:0 error:nil];
            NSTimeInterval timeStamp = [result doubleForColumn:@"timeStamp"];
            EZDLogModel *logModel = [[EZDLogModel alloc] initWithTag:tag
                                                              contentDic:dic
                                                               timeStamp:timeStamp];
            [models addObject:logModel];
        }
        [result close];
        weakSelf.originLogs = models;
    }];
    
    //  倒序排列
    [self.originLogs sortUsingComparator:^NSComparisonResult(EZDLogModel * _Nonnull obj1,
                                                             EZDLogModel *  _Nonnull obj2) {
        return obj1.timeStamp < obj2.timeStamp ? NSOrderedDescending : obj1.timeStamp == obj2.timeStamp ? NSOrderedSame : NSOrderedAscending;
    }];
    
    [self callDelegateMethodWithMethod:@selector(onceStart:logsDidChange:) contents:self, self.originLogs, nil];
}

- (void)archiveLogModel:(EZDLogModel *)model {
    NSString *sql = [NSString stringWithFormat:@"insert into '%@'\
                     (tag,content,timeStamp) \
                     values(?,?,?)",
                     self.tableName];
    NSString *contentStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:model.contentDic options:0 error:nil] encoding:(NSUTF8StringEncoding)];
    NSArray *values = @[
        DGNotNullString(model.tag),
        DGNotNullString(contentStr),
        @(model.timeStamp).stringValue,
    ];
    
    __weak typeof(self) weakSelf = self;
    [self.dbq inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:sql
                   values:values
                    error:nil];
        //  存入log list
        [weakSelf.originLogs insertObject:model atIndex:0];
    }];
    //  通知代理
    [self callDelegateMethodWithMethod:@selector(onceStart:logsDidChange:) contents:self,@[model],nil];
}

#pragma mark - delegate funcs
- (void)addDelegate:(id<EZDOnceStartDelegate>)delegate{
    if (![delegate conformsToProtocol:NSProtocolFromString(@"EZDOnceStartDelegate")]) {
        return;
    }
    if (delegate && ![self.onceStartDelegates containsObject:delegate]) {
        [self.onceStartDelegates addObject:delegate];
    }
}

- (void)removeDelegate:(id<EZDOnceStartDelegate>)delegate{
    [self.onceStartDelegates removeObject:delegate];
}

- (void)removeAllDelegates{
    [self.onceStartDelegates removeAllObjects];
}

- (void)callDelegateMethodWithMethod:(SEL)selector contents:(id)firstObj,...{
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
    
    NSEnumerator *enumerator = [self.onceStartDelegates objectEnumerator];
    id<EZDOnceStartDelegate> delegate;
    while ((delegate = [enumerator nextObject])) {
        if ([delegate respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [EasyDebugUtil executeMain:^{
                [delegate performSelector:selector withObject:objs.firstObject withObject:objs.count>=2?objs[1]:nil];
            }];
#pragma clang diagnostic pop
        }
    }
}


@end
