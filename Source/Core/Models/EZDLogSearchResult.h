//
//  EZDLogSearchResult.h
//  EasyDebug
//
//  Created by songheng on 2022/8/5.
//

#import <Foundation/Foundation.h>
#import "EZDLogModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EZDLogSearchResult : EZDLogModel

@property (nonatomic, strong) NSAttributedString *searchAttrStr;

- (instancetype)initWithModel:(EZDLogModel *)model searchAttrStr:(NSAttributedString *)searchAttrStr;

@end

NS_ASSUME_NONNULL_END
