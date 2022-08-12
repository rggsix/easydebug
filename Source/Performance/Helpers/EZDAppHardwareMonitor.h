//
//  EZDAppHardwareMonitor.h
//  EasyDebug
//
//  Created by songheng on 2020/12/11.
//

#import <UIKit/UIKit.h>

typedef void(^DebugAppHardwareMonitorCallback)(uint fps, float cpu, uint mem);

NS_ASSUME_NONNULL_BEGIN

@interface EZDAppHardwareMonitor : NSObject

+ (void)startMonitorWithCallback:(DebugAppHardwareMonitorCallback)callback;
+ (void)pauseMonitor;

///  帧率，上限为60 fps
+ (uint)fps;
///  cpu，单位为百分比, 如： 8% CPU使用率
+ (uint)cpu;
///  内存，单位为兆，如： 75M 内存使用
+ (uint)mem;

@end

NS_ASSUME_NONNULL_END
