//
//  EZDDisplayer.h
//  EasyDebug
//
//  Created by songheng on 2020/11/25.
//

#import <UIKit/UIKit.h>
#import "EZDOnceStart.h"

NS_ASSUME_NONNULL_BEGIN

@interface EZDDisplayer : NSObject

- (void)start;
- (void)stop;

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END
