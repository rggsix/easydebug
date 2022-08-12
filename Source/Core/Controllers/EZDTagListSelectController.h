//
//  EZDTagListSelectController.h
//  EasyDebug
//
//  Created by songheng on 2020/11/30.
//

#import <UIKit/UIKit.h>
#import "EZDOnceStart.h"

NS_ASSUME_NONNULL_BEGIN

@interface EZDTagListSelectController : UIViewController

- (instancetype)initWithTags:(NSArray<NSString *> *)tags callback:(void(^)(NSString *tag))callback;

@end

NS_ASSUME_NONNULL_END
