//
//  EZDDisplayer.h
//  easydebug
//
//  Created by Song on 2018/8/21.
//

#import <Foundation/Foundation.h>
#import "EZDLogger.h"

@interface EZDDisplayer : NSObject

@property (strong,nonatomic)  EZDLogger *logger;

+ (instancetype)setupDisplayerWithWindow:(UIWindow *)window;

+ (void)setToolIcon:(UIImage *)image;

+ (void)showFPSLabel:(bool)show;

@end
