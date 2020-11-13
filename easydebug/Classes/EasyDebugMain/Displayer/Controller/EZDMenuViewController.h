//
//  EZDMenuViewController.h
//  easydebug_Example
//
//  Created by qingting on 2020/11/13.
//  Copyright © 2020 Song. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EZDLogger.h"

NS_ASSUME_NONNULL_BEGIN

@interface EZDMenuViewController : UIViewController

- (instancetype)initWithLogger:(EZDLogger *)logger;

@end

NS_ASSUME_NONNULL_END
