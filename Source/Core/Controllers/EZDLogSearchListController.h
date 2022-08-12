//
//  EZDLogSearchListController.h
//  EasyDebug
//
//  Created by songheng on 2021/1/8.
//

#import <UIKit/UIKit.h>

#import "EZDLogDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface EZDLogSearchListController : UIViewController

- (instancetype)initWithDataSource:(EZDLogDataSource *)dataSource;

@end

NS_ASSUME_NONNULL_END
