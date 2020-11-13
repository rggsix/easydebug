//
//  EZDMenuInfoModel.h
//  easydebug_Example
//
//  Created by qingting on 2020/11/13.
//  Copyright © 2020 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    //  Log
    EZDMenuNetworkLog,
    EZDMenuConsoleLog,
    EZDMenuAppInfoLog,
    EZDMenuClearalllog,
    //  APM
    EZDMenuAllAPMInfo,
    //  Other
    EZDMenuDebugoptions,
} EZDMenuType;

NS_ASSUME_NONNULL_BEGIN

@interface EZDMenuInfoModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) EZDMenuType menuType;

- (instancetype)initWithTitle:(NSString *)title type:(EZDMenuType)type;

@end

NS_ASSUME_NONNULL_END
