//
//  EZDAppShortInfoLabel.m
//  easydebug
//
//  Created by Song on 2018/8/25.
//

#import "EZDAppShortInfoLabel.h"
#if EZDEBUG_DEBUGLOG
#import <mach/mach.h>
#endif

#define kSize CGSizeMake(90, 24)

@interface EZDAppShortInfoLabel()

#if EZDEBUG_DEBUGLOG
@property (strong,nonatomic) CADisplayLink *link;
@property (assign,nonatomic) NSInteger count;
@property (assign,nonatomic) NSTimeInterval lastTime;
#endif

@end

@implementation EZDAppShortInfoLabel

#if EZDEBUG_DEBUGLOG
- (instancetype)initWithFrame:(CGRect)frame {
    frame.size = kSize;
    
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        self.textAlignment = NSTextAlignmentCenter;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.700];
        self.textColor = [UIColor whiteColor];
        
        UIFont *font = [UIFont fontWithName:@"Menlo" size:14];
        if (font) {
        } else {
            font = [UIFont fontWithName:@"Courier" size:14];
        }
        self.font = font;
        
        __unsafe_unretained typeof(self) weakSelf = self;
        _link = [CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(tick:)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)dealloc {
    [_link invalidate];
}

- (void)tick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) return;
    _lastTime = link.timestamp;
    float fps = _count / delta;
    _count = 0;
    
    NSUInteger len_f = [NSString stringWithFormat:@"%d",(int)round(fps)].length;
    int cpu = (int)round([self cpuUsage]*100);
    NSUInteger len_c = [NSString stringWithFormat:@"%d",cpu].length;
    int mem = (int)([self memoryUsage]*0.0000009536*.6);
    NSUInteger len_m = [NSString stringWithFormat:@"%d",mem].length;
    CGFloat progress = fps / 60.0;
    UIColor *color1 = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1];
    UIColor *color2 = [UIColor colorWithHue:0.27 * ((200-cpu)*.005 - 0.2) saturation:1 brightness:0.9 alpha:1];
    UIColor *color3 = [UIColor colorWithHue:0.27 * ((500-mem)*.002 - 0.2) saturation:1 brightness:0.9 alpha:1];
    
    NSMutableAttributedString *text = nil;
    text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d|%d|%d",(int)round(fps), cpu, mem]];
    
    [text addAttribute:NSForegroundColorAttributeName value:color1 range:NSMakeRange(0, len_f)];
    [text addAttribute:NSForegroundColorAttributeName value:color2 range:NSMakeRange(len_f + 1, len_c)];
    [text addAttribute:NSForegroundColorAttributeName value:color3 range:NSMakeRange(len_f + len_c + 2, len_m)];
    self.attributedText = text;
}

- (float)cpuUsage {
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
    
    return tot_cpu;
}

- (int64_t)memoryUsage {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kern = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (kern != KERN_SUCCESS) return -1;
    return info.resident_size;
}

#endif
@end
