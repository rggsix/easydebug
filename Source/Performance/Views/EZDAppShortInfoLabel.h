//
//  EZDAppShortInfoLabel.h
//  EasyDebug
//
//  Created by songheng on 2020/11/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZDAppShortInfoLabel : UILabel

- (void)updateWithFPS:(uint)FPS cpu:(uint)cpu mem:(uint)mem;

@end

NS_ASSUME_NONNULL_END
