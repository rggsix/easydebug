//
//  EZDAPMFPSMonitor.m
//  HoldCoin
//
//  Created by Song on 2019/1/24.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#define dispatch_hc_fps_sync_safe(queue_,block)\
if (dispatch_queue_get_label(queue_) == [[self className] cStringUsingEncoding:(NSUTF8StringEncoding)]) {\
block();\
} else {\
dispatch_sync(queue_, block);\
}

#import "EZDAPMFPSMonitor.h"
#import "EZDAPMBacktrace.h"
#import "EZDAPMUtil.h"
#import "EZDAPMOperationRecorder.h"

static NSTimeInterval stuckTriggerMinDuration = .2;
static NSTimeInterval stuckReportMinDuration = 10;
static NSInteger stuckMonitorFrameCount = 3;

@interface EZDAPMFPSMonitor ()

@property (strong,nonatomic) CADisplayLink *displayLink;
@property (strong,nonatomic) NSTimer *fps_timer;
@property (strong,nonatomic) dispatch_queue_t fps_queue;

@property (assign,nonatomic) NSTimeInterval lastTickTimestamp;
@property (assign,nonatomic) NSTimeInterval lastReportTimestamp;

@property (assign,nonatomic) bool isSuspension;

@end

@implementation EZDAPMFPSMonitor

+ (void)startFPSMonitoring{
#if EZD_APM
    [[self shareInstance] monitoring_start];
#endif
}

+ (instancetype)shareInstance{
    static EZDAPMFPSMonitor *ins = nil;
#if EZD_APM
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [self new];
        ins.displayLink = [CADisplayLink displayLinkWithTarget:ins selector:@selector(displayLinkCallback)];
        ins.displayLink.frameInterval = stuckMonitorFrameCount;
        ins.displayLink.paused = true;
        [ins.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        NSString *clsName = NSStringFromClass([self class]);
        ins.fps_queue = dispatch_queue_create([clsName cStringUsingEncoding:(NSUTF8StringEncoding)], DISPATCH_QUEUE_SERIAL);
        ins.fps_timer = [[NSTimer alloc] initWithFireDate:[NSDate distantFuture] interval:.1 target:ins selector:@selector(monitorTimer:) userInfo:nil repeats:true];
    });
#endif
    return ins;
}

- (void)dealloc{
    self.displayLink.paused = false;
    self.displayLink = nil;
    [self.fps_timer invalidate];
    self.fps_timer = nil;
}

- (void)monitoring_start{
#if EZD_APM
    self.displayLink.paused = false;
    
    dispatch_async(self.fps_queue, ^{
        self.isSuspension = false;
        NSDate *curDate = [NSDate date];
        self.lastTickTimestamp = [curDate timeIntervalSince1970];
        self.fps_timer.fireDate = curDate;
        [self.fps_timer fire];
        
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [runloop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runloop addTimer:self.fps_timer forMode:NSRunLoopCommonModes];
        [runloop run];
    });
#endif
}

- (void)monitoring_pause{
    self.isSuspension = true;
    self.fps_timer.fireDate = [NSDate distantFuture];
}

- (void)displayLinkCallback{
    self.lastTickTimestamp = [[NSDate date] timeIntervalSince1970];
}

- (void)monitorTimer:(NSTimer *)timer{
    if (self.isSuspension) return;
    
    NSTimeInterval lastTickTime = self.lastTickTimestamp;
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    
//    NSLog(@"-> %f",curTime - lastTickTime);
    if (curTime - lastTickTime < stuckTriggerMinDuration) return;
    if (curTime - self.lastReportTimestamp < stuckReportMinDuration) return;
    
    //  Application not ready.
    if (![EZDAPMUtil shareInstance].currentVCName.length) return;
    self.lastReportTimestamp = curTime;
    
    NSString *reportString = [EZDAPMBacktrace getCurrentTraceLogWithTraceInfo:true onlyMainThread:true operationPathInfo:true];

    NSString *fileName = [NSString stringWithFormat:@"stuck_%@_%ld.crash",[EZDAPMUtil shareInstance].mIDFA,(long)self.lastReportTimestamp];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[EZDAPMUtil shareInstance].crashFilePath,fileName];
    [reportString writeToFile:filePath atomically:true encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"stuck! --> %@",filePath);
    
    [EZDAPMOperationRecorder recordOperation:fileName operationType:EZDAPMOperationStuck  filePath:filePath];
}

@end
