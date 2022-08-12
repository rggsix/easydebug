//
//  EZDLogDataSource.h
//  EasyDebug
//
//  Created by songheng on 2020/12/30.
//

#import <Foundation/Foundation.h>
#import "EZDLogModel.h"
#import "EZDLogSearchResult.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kDebugNoTagKey = @"_kDebugNoTagKey";

@interface EZDLogDataSource : NSObject

///  被tag过滤过的logs
@property (nonatomic, strong) NSArray<EZDLogModel *> *logs;
///  搜索结果
@property (nonatomic, strong) NSArray<EZDLogSearchResult *> *searchLogs;

- (instancetype)initWithLogs:(NSArray<EZDLogModel *> *)logs;
- (void)filterLogsWithTag:(NSString *)tag;
- (void)searchLogsWithKey:(NSString *)key;
- (NSArray<NSString *> *)tags;

@end

NS_ASSUME_NONNULL_END
