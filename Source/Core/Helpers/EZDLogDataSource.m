//
//  EZDLogDataSource.m
//  EasyDebug
//
//  Created by songheng on 2020/12/30.
//

#import "EZDLogDataSource.h"

#import "EasyDebugUtil.h"
#import "EZDLogModel.h"
#import "DebugCoreCategorys.h"

///  搜索结果展示前后多少字符
static NSInteger DebugSearchSimpleStringRange = 20;

@interface EZDLogDataSource ()

@property (nonatomic, strong) NSArray<EZDLogModel *> *originLogs;

@end

@implementation EZDLogDataSource

#pragma mark - life circle
- (instancetype)initWithLogs:(NSArray<EZDLogModel *> *)logs {
    if (self = [super init]) {
        self.originLogs = [DGNotNullArray(logs) copy];
        self.logs = self.originLogs;
    }
    return self;
}

#pragma mark - interface
- (void)filterLogsWithTag:(NSString *)tag {
    NSMutableArray<EZDLogModel *> *filteredLogs = [NSMutableArray arrayWithCapacity:self.originLogs.count];
    [self.originLogs enumerateObjectsUsingBlock:^(EZDLogModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self judgeLogModel:obj filterTag:tag] ? [filteredLogs addObject:obj] : nil;
    }];

    self.logs = filteredLogs;
}

- (void)searchLogsWithKey:(NSString *)key {
    NSString *lowerKey = [key lowercaseString];
    //  从logs中搜索，相当于同时过滤tag、search
    NSMutableArray<EZDLogSearchResult *> *searchResults = [NSMutableArray arrayWithCapacity:self.logs.count];
    [self.logs enumerateObjectsUsingBlock:^(EZDLogModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *contentString = [[obj.contentDic dg_JSONDescription] stringByReplacingOccurrencesOfString:@"\n" withString:@"\t"];
        NSString *lowerContentJSON = [contentString lowercaseString];
        NSRange range = [lowerContentJSON rangeOfString:lowerKey];
        //  不匹配
        if (range.location == NSNotFound) return;
        
        //  匹配到搜索文字，截取attr text, 期望结果为：
        //  ... content <Key> content ...
        //  向前取20位，获取attr text的location，不能小于0
        NSInteger location = MAX(((NSInteger)range.location) - DebugSearchSimpleStringRange, 0);
        //  计算 <Key> 后面还有多少文字
        NSInteger strLenOnKeyRight = contentString.length - range.location - range.length;
        //  向后取20位，最大不能超过 strLenOnKeyRight
        strLenOnKeyRight = MIN(DebugSearchSimpleStringRange, strLenOnKeyRight);
        //  计算出 <attr text> 文字长度， length = key前取样了多少字符 + key长度 + key后取样了多少字符
        NSInteger length = (range.location - location) + range.length + strLenOnKeyRight;
        //  生成 <attr text> 的 Range
        NSRange simpleRange = NSMakeRange(location, length);
        //  根据上面的 Range ， 创建 <attr text>
        NSString *originSimpleStr = [contentString substringWithRange:simpleRange];
        NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:originSimpleStr];
        //  在 <attr text> 中高亮 <Key>
        NSRange rangeInSimple = [[originSimpleStr lowercaseString] rangeOfString:lowerKey];
        [attrText setAttributes:@{
            NSBackgroundColorAttributeName:[[UIColor orangeColor] colorWithAlphaComponent:.7]
        } range:rangeInSimple];
        //  在 <attr text> 前后添加省略号， 表示其前后还有内容
        NSAttributedString *appendStr = [[NSAttributedString alloc] initWithString:@"..."];
        if (simpleRange.location != 0) {
            //  <attr text> 前面还有内容，加个省略号
            [attrText insertAttributedString:appendStr atIndex:0];
        }
        if ((simpleRange.location + simpleRange.length) < contentString.length) {
            //  <attr text> 后面还有内容，加个省略号
            [attrText appendAttributedString:appendStr];
        }
        
        //  创建search result model
        EZDLogSearchResult *searchModel = [[EZDLogSearchResult alloc] initWithModel:obj searchAttrStr:attrText];
        [searchResults addObject:searchModel];
    }];
    
    self.searchLogs = searchResults;
}

- (NSArray<NSString *> *)tags {
    NSMutableArray<NSString *> *tags = [NSMutableArray arrayWithCapacity:32];
    for (EZDLogModel *content in self.originLogs) {
        if (content.tag.length && ![tags containsObject:content.tag]) {
            [tags addObject:content.tag];
        }
    }
    return tags;
}

#pragma mark - private
- (BOOL)judgeLogModel:(EZDLogModel *)logModel filterTag:(NSString *)filterTag {
    if (filterTag.length) {
        if ([filterTag isEqual:kDebugNoTagKey]) {
            return logModel.tag.length == 0;
        } else {
            return [filterTag isEqualToString:logModel.tag];
        }
    }
    
    return YES;
}

@end
