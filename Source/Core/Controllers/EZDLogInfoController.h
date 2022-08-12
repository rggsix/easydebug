//
//  EZDLogInfoController.h
//  EasyDebug
//
//  Created by songheng on 2020/11/25.
//

#import <UIKit/UIKit.h>

@class EZDLogModel;

NS_ASSUME_NONNULL_BEGIN

@interface EZDLogInfoController : UIViewController

- (instancetype)initWithLogModel:(EZDLogModel *)logModel;

@end

NS_ASSUME_NONNULL_END
