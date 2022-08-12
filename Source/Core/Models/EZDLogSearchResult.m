//
//  EZDLogSearchResult.m
//  EasyDebug
//
//  Created by songheng on 2022/8/5.
//

#import "EZDLogSearchResult.h"


@implementation EZDLogSearchResult

- (instancetype)initWithModel:(EZDLogModel *)model searchAttrStr:(NSAttributedString *)searchAttrStr {
    if (self = [super initWithTag:model.tag contentDic:model.contentDic timeStamp:model.timeStamp]) {
        self.searchAttrStr = searchAttrStr;
    }
    return self;
}

@end
