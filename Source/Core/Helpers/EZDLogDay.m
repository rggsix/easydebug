//
//  EZDLogDay.m
//  EasyDebug
//
//  Created by songheng on 2020/11/26.
//

#import "EZDLogDay.h"

#import "EZDLogManager.h"
#import "DebugCoreCategorys.h"
#import "EasyDebugUtil.h"
#import <fmdb/FMDatabaseQueue.h>

@interface EZDLogDay()

@end

@implementation EZDLogDay

- (instancetype)initWithFilePath:(NSString *)filePath {
    if (self = [super init]) {
        NSString *fileName = [filePath lastPathComponent];
        if ([fileName hasPrefix:kDebugLogFilePrefix]) {
            NSString *dateStr = [fileName stringByReplacingOccurrencesOfString:kDebugLogFilePrefix withString:@""];
            dateStr = [dateStr stringByDeletingPathExtension];
            NSDate *date = [EZDLogManager.shared.fileDateFormatter dateFromString:dateStr];
            self.filePath = filePath;
            self.logDate = date;
            self.dateString = date.dg_dayString;
            self.starts = [NSMutableArray arrayWithCapacity:16];
            self.dbq = [FMDatabaseQueue databaseQueueWithPath:self.filePath];
            //   从该数据库中列出所有表
            [self queryStarts];
        }
    }
    return self;
}

#pragma mark - interface
- (EZDOnceStart *)createStartWithTableName:(NSString *)tableName {
    //  创建once start
    EZDOnceStart *start = [[EZDOnceStart alloc] initWithWithDay:self tableName:tableName];
    start.isCurrentStartup = YES;
    [self.dbq inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"create table if not exists %@\
                         ('ID' INTEGER PRIMARY KEY AUTOINCREMENT,\
                         'tag' TEXT, \
                         'content' TEXT,\
                         'timeStamp' TEXT);",
                         tableName];
        [db executeUpdate:sql];
        [self.starts insertObject:start atIndex:0];
    }];
    return start;
}

- (void)deleteStart:(EZDOnceStart *)start{
    [self.dbq inDatabase:^(FMDatabase * _Nonnull db) {
        //  删除数据库中的数据
        NSString *sql = [NSString stringWithFormat:@"DROP TABLE %@;", start.tableName];
        [db executeUpdate:sql];
        //  删除logFiles数组中缓存的对应once start
        [self.starts removeObject:start];
    }];
}

- (void)closeDatabase {
    [self.dbq close];
}

#pragma mark - private
- (void)queryStarts {
    __weak typeof(self) weakSelf = self;
    [self.dbq inDatabase:^(FMDatabase * _Nonnull db) {
        NSMutableArray *starts = [NSMutableArray arrayWithCapacity:16];
        FMResultSet *result = [db executeQuery:@"SELECT name FROM sqlite_master where type='table' order by name"];
        while (result.next) {
            NSString *name = [result stringForColumn:@"name"];
            if ([name hasPrefix:kDebugLogFilePrefix]) {
                EZDOnceStart *start = [[EZDOnceStart alloc] initWithWithDay:weakSelf tableName:name];
                [starts addObject:start];
            }
        }
        [result close];
        [starts sortUsingComparator:^NSComparisonResult(EZDOnceStart *  _Nonnull obj1, EZDOnceStart *  _Nonnull obj2) {
            return [obj2.logDate compare:obj1.logDate];
        }];
        
        self.starts = starts;
    }];
}

@end
