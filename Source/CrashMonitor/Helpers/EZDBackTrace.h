//
//  EZDBackTrace.h
//  EasyDebug
//
//  Created by songheng on 2020/12/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZDBackTrace : NSObject

+ (NSString *)dg_backtraceOfAllThread;
+ (NSString *)dg_backtraceOfCurrentThread;
+ (NSString *)dg_backtraceOfMainThread;
+ (NSString *)dg_backtraceOfNSThread:(NSThread *)thread;

@end

NS_ASSUME_NONNULL_END
