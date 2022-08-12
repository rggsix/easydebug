//
//  EZDAppHardwareMonitor.m
//  EasyDebug
//
//  Created by songheng on 2020/12/11.
//

#import "EZDAppHardwareMonitor.h"

#ifdef __has_include
    #if __has_include("DebugNetworkMonitor.h")
        #define NETWORK_MONITOR_ON 1
    #else
        #define NETWORK_MONITOR_ON 0
    #endif
#endif

#import <mach/mach.h>

static int const kDebugCPUTimeSpan = 10;

@interface EZDAppHardwareMonitor ()

@property (nonatomic, assign) int lastFPS;

//  FPS
@property (strong,nonatomic) CADisplayLink *link;
@property (assign,nonatomic) NSInteger fps_count;
@property (assign,nonatomic) NSTimeInterval lastTime;

//  cpu
@property (assign,nonatomic) NSInteger cpu_count;
@property (nonatomic, assign) uint lastCPU;

//  callback
@property (nonatomic, copy) DebugAppHardwareMonitorCallback monitorCallback;

@end

@implementation EZDAppHardwareMonitor

+ (instancetype)shared {
    static EZDAppHardwareMonitor *ins;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [self new];
    });
    return ins;
}

- (instancetype)init {
    if (self = [super init]) {
        self.cpu_count = kDebugCPUTimeSpan;
    }
    return self;
}

#pragma mark - interface
+ (void)startMonitorWithCallback:(DebugAppHardwareMonitorCallback)callback {
    [EZDAppHardwareMonitor.shared startMonitorWithCallback:callback];
}

+ (void)pauseMonitor {
    [EZDAppHardwareMonitor.shared pauseMonitor];
}

+ (uint)fps {
    return EZDAppHardwareMonitor.shared.fps;
}

+ (uint)cpu {
    return EZDAppHardwareMonitor.shared.cpu;
}

+ (uint)mem {
    return EZDAppHardwareMonitor.shared.mem;
}

#pragma mark - private
- (void)startMonitorWithCallback:(DebugAppHardwareMonitorCallback)callback {
    self.monitorCallback = callback;
    [self.link addToRunLoop:[NSRunLoop mainRunLoop]
                                           forMode:NSRunLoopCommonModes];
}

- (void)pauseMonitor {
    [self.link invalidate];
    self.link = nil;
    self.monitorCallback = nil;
}

- (uint)fps {
    //  计算当前fps
    self.fps_count++;
    NSTimeInterval delta = self.link.timestamp - self.lastTime;
    if (delta < 1) return self.lastFPS;
    self.lastTime = self.link.timestamp;
    self.lastFPS = floor(self.fps_count / delta);
    self.fps_count = 0;
    
    return self.lastFPS;
}

- (uint)cpu {
    if (kDebugCPUTimeSpan > self.cpu_count) {
        self.cpu_count++;
        return self.lastCPU;
    }
    
    self.cpu_count = 0;
    
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    thread_array_t thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE;
        }
    }
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    self.lastCPU = (uint)floor(tot_cpu*100);
    return self.lastCPU;
}

- (uint)mem {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kern = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (kern != KERN_SUCCESS) return -1;
    //  0.0000009536 * .6
    return (uint)(info.resident_size * 0.0000005721);
}

- (void)tick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    if (!self.monitorCallback) {
        return;
    }
    
    self.monitorCallback(self.fps,
                         self.cpu,
                         self.mem);
}

#pragma mark - getter && setter
- (CADisplayLink *)link {
    if (!_link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    }
    return _link;
}

@end
