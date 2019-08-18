//
//  EZDAPMUtil.m
//  HoldCoin
//
//  Created by Song on 2019/1/25.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDAPMUtil.h"

#import <sys/utsname.h>
#import <mach/mach.h>
#import <sys/mount.h>
#import <AdSupport/AdSupport.h>

#import "EZDReachability.h"

static NSTimeInterval EZDAPMLaunchTS = 0;

@interface EZDAPMUtil ()

@property (nonatomic,assign) NSTimeInterval currentVCAppearTime;

@end

@implementation EZDAPMUtil

#if EZD_APM
+ (void)load{
    EZDAPMLaunchTS = [[NSDate date] timeIntervalSince1970];
}
#endif

+ (instancetype)shareInstance{
    static EZDAPMUtil *ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[self alloc] init];
    });
    return ins;
}

- (instancetype)init{
    if (self = [super init]) {
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *model = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
        
        self.phoneType = model;
        self.osVersion = [[UIDevice currentDevice] systemVersion];
        self.mIDFA = [EZDAPMUtil idfaString];
        
        self.processName = [NSProcessInfo processInfo].processName;
        self.processID = [NSString stringWithFormat:@"%d",[NSProcessInfo processInfo].processIdentifier];
        
        self.bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        self.appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        self.appBuildVersion = [[[NSBundle mainBundle] infoDictionary]  objectForKey:@"CFBundleVersion"];
        self.appVersionStr = [NSString stringWithFormat:@"%@ (%@)",self.appVersion,self.appBuildVersion];
        
        self.crashFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).lastObject;
        self.crashFilePath = [self.crashFilePath stringByAppendingPathComponent:@"crash_log"];
        [EZDAPMUtil createFolderIfNotExist:self.crashFilePath];
    }
    return self;
}

+ (NSError *)createFolderIfNotExist:(NSString *)folderPath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err = nil;
    
    if(![fileManager fileExistsAtPath:folderPath]){
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&err];
    }
    return err;
}

#pragma mark - getter && setter
- (void)setCurrentVCName:(NSString *)currentVCName{
    _currentVCName = currentVCName;
    self.currentVCAppearTime = [[NSDate date] timeIntervalSince1970];
}

- (NSTimeInterval)currentVCStayTime{
    return [[NSDate date] timeIntervalSince1970] - self.currentVCAppearTime;
}

- (NSTimeInterval)launchedTime{
    return [[NSDate date] timeIntervalSince1970] - EZDAPMLaunchTS;
}

#pragma mark - device info

+ (NSString *)idfaString {
#if TARGET_IPHONE_SIMULATOR
    return @"TARGET_IPHONE_SIMULATOR";
#else
    NSBundle *adSupportBundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/AdSupport.framework"];
    [adSupportBundle load];
    
    if (adSupportBundle == nil) {
        return @"";
    }
    
    Class asIdentifierMClass = NSClassFromString(@"ASIdentifierManager");
    
    if (asIdentifierMClass == nil) {
        return @"";
    }
    
    ASIdentifierManager *asIM = [[asIdentifierMClass alloc] init];
    if (asIM == nil) {
        return @"";
    }
    
    return [asIM.advertisingIdentifier UUIDString];
#endif
}

#pragma mark - hardware state
+ (float)cpuUsage {
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
    
    return tot_cpu*100;
}

+ (int64_t)memoryUsage {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kern = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (kern != KERN_SUCCESS) return -1;
    return info.resident_size * 0.00000057216;//0.0000009536 * .6;
}

+ (CGFloat)getBatteryQuantity{
    return [[UIDevice currentDevice] batteryLevel];
}

+ (long long)getAvailableMemorySize{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if (kernReturn != KERN_SUCCESS)
    {
        return NSNotFound;
    }
    return ((vm_page_size * vmStats.free_count + vm_page_size * vmStats.inactive_count));
}

+ (long long)getTotalDiskSize{
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0)
    {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_blocks);
    }
    return freeSpace;
}

+ (long long)getAvailableDiskSize{
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0)
    {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return freeSpace;
}

+ (NSString *)fileSizeToString:(unsigned long long)fileSize{
    NSInteger KB = 1024;
    NSInteger MB = KB*KB;
    NSInteger GB = MB*KB;
    
    if (fileSize < 10)  {
        return @"0 B";
    }else if (fileSize < KB)    {
        return @"< 1 KB";
    }else if (fileSize < MB)    {
        return [NSString stringWithFormat:@"%.1f KB",((CGFloat)fileSize)/KB];
    }else if (fileSize < GB)    {
        return [NSString stringWithFormat:@"%.1f MB",((CGFloat)fileSize)/MB];
    }else   {
        return [NSString stringWithFormat:@"%.1f GB",((CGFloat)fileSize)/GB];
    }
}

+ (NSString *)getNetworkState{
    NSString *netType = @"UNKNOW";
    switch ([EZDReachability reachability].status) {
        case EZDReachabilityStatusNone:
            netType = @"DISABLE";
            break;
        case EZDReachabilityStatusWWAN:
            goto WWANStateJudge;
            break;
        case EZDReachabilityStatusWiFi:
            netType = @"WIFI";
            break;
        default:
            break;
    }
    goto NetStateEndJudge;
    
WWANStateJudge:
    switch ([EZDReachability reachability].wwanStatus) {
        case EZDReachabilityWWANStatus2G:
            netType = @"2G";
            break;
        case EZDReachabilityWWANStatus3G:
            netType = @"3G";
            break;
        case EZDReachabilityWWANStatus4G:
            netType = @"4G";
            break;
        case EZDReachabilityWWANStatusNone:
            netType = @"WWAN_UNKNOW";
            break;
        default:
            break;
    }
    
NetStateEndJudge:
    return netType;
}

@end
