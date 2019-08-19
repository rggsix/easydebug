//
//  EZDAPMDeviceConsumptionMonitor.m
//  HoldCoin
//
//  Created by Song on 2019/2/12.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDAPMDeviceConsumptionMonitor.h"
#import "EZDAPMBacktrace.h"
#import "EZDAPMUtil.h"
#import "EZDAPMOperationRecorder.h"

static NSTimeInterval EZDAPM_cpuReportMinDur = 10;
static NSTimeInterval EZDAPM_memoryReportMinDur = 10;
static float EZDAPM_cpuHighTriggerValue = 95.;
static int64_t EZDAPM_memMinTriggerValue = 100;
static int64_t EZDAPM_memTriggerStep = 50;

@interface EZDAPMDeviceConsumptionMonitor ()

@property (strong,nonatomic) NSTimer *monitor_timer;
@property (strong,nonatomic) dispatch_queue_t monitor_queue;

@property (assign,nonatomic) NSTimeInterval lastReportCPUTS;
@property (assign,nonatomic) NSTimeInterval lastReportMEMTS;

@property (assign,nonatomic) int64_t nextMemHighTriggerValue;
@property (assign,nonatomic) int64_t lastReportMemValue;

@property (assign,nonatomic) bool isSuspension;

@end

@implementation EZDAPMDeviceConsumptionMonitor

+ (void)startMonitoring{
    [[self shareInstance] monitoring_start];
}

+ (instancetype)shareInstance{
    static EZDAPMDeviceConsumptionMonitor *ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [self new];
        
        NSString *className = NSStringFromClass([self class]);
        ins.monitor_queue = dispatch_queue_create([className cStringUsingEncoding:(NSUTF8StringEncoding)], DISPATCH_QUEUE_SERIAL);
        ins.monitor_timer = [[NSTimer alloc] initWithFireDate:[NSDate distantFuture] interval:.1 target:ins selector:@selector(monitorTimer:) userInfo:nil repeats:true];
        ins.nextMemHighTriggerValue = EZDAPM_memMinTriggerValue;
    });
    return ins;
}

- (void)dealloc{
    [self.monitor_timer invalidate];
    self.monitor_timer = nil;
}

- (void)monitoring_start{
    dispatch_async(self.monitor_queue, ^{
        self.isSuspension = false;
        NSDate *curDate = [NSDate date];
        self.monitor_timer.fireDate = curDate;
        [self.monitor_timer fire];
        
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [runloop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runloop addTimer:self.monitor_timer forMode:NSRunLoopCommonModes];
        [runloop run];
    });
    
    [self startBatteryMonitoring];
}

- (void)monitoring_pause{
    self.isSuspension = true;
    self.monitor_timer.fireDate = [NSDate distantFuture];
    [self pauseBatteryMonitoring];
}

- (void)monitorTimer:(NSTimer *)timer{
    if (self.isSuspension) return;
    
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    
    [self cpuHighUsageJudgeWithTS:curTime];
    [self memoryHighUsageJudgeWithTS:curTime];
}

- (void)startBatteryMonitoring{
    UIDevice *device = [UIDevice currentDevice];
    
    device.batteryMonitoringEnabled = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryLevelChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:device];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateChanged:) name:UIDeviceBatteryStateDidChangeNotification object:device];
}

- (void)pauseBatteryMonitoring{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryStateDidChangeNotification object:nil];
}

- (void)batteryLevelChanged:(NSNotification *)noti{
    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];
    
    float batteryLevel = [myDevice batteryLevel];
    [EZDAPMOperationRecorder recordOperation:[NSString stringWithFormat:@"%f",batteryLevel*100.] operationType:EZDAPMOperationStuck filePath:@""];
}

- (void)batteryStateChanged:(NSNotification *)noti{
    NSString *stateString = @"Unknow";
    switch ([[UIDevice currentDevice] batteryState]) {
        case UIDeviceBatteryStateUnplugged:
            stateString = @"Unplugged";
            break;
        case UIDeviceBatteryStateCharging:
            stateString = @"Charging";
            break;
        case UIDeviceBatteryStateFull:
            stateString = @"Full";
            break;
        default:
            break;
    }
    [EZDAPMOperationRecorder recordOperation:stateString operationType:EZDAPMOperationStuck filePath:@""];
}

- (void)cpuHighUsageJudgeWithTS:(NSTimeInterval)curTS{
    if (curTS - self.lastReportCPUTS < EZDAPM_cpuReportMinDur) return;
    double cpuUsage = [EZDAPMUtil cpuUsage];
    //    NSLog(@"-> %f",cpuUsage);
    if (cpuUsage < EZDAPM_cpuHighTriggerValue) return;
    
    self.lastReportCPUTS = curTS;
    NSString *reportString = [EZDAPMBacktrace getCurrentTraceLog];
    NSString *fileName = [NSString stringWithFormat:@"cpuHighUse_%@_%ld.crash",[EZDAPMUtil shareInstance].mIDFA,(long)self.lastReportCPUTS];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[EZDAPMUtil shareInstance].crashFilePath,fileName];
    [reportString writeToFile:filePath atomically:true encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"cpu high usage! --> %@",filePath);
    [EZDAPMOperationRecorder recordOperation:fileName operationType:EZDAPMOperationCPUHeigh filePath:filePath];
}

- (void)memoryHighUsageJudgeWithTS:(NSTimeInterval)curTS{
    if (curTS - self.lastReportMEMTS < EZDAPM_memoryReportMinDur) return;
    
    double memUsage = [EZDAPMUtil memoryUsage];
    
    if (memUsage < self.nextMemHighTriggerValue) {
        //  If some memory had free , reduce the memory high trigger value .
        if ((self.lastReportMemValue - memUsage) >= EZDAPM_memTriggerStep) {
            self.lastReportMemValue = memUsage;
            self.nextMemHighTriggerValue = memUsage + EZDAPM_memTriggerStep;
            self.nextMemHighTriggerValue = (self.nextMemHighTriggerValue < EZDAPM_memMinTriggerValue) ? EZDAPM_memMinTriggerValue : self.nextMemHighTriggerValue;
        }
        
        return;
    }
    self.lastReportMemValue = memUsage;
    self.nextMemHighTriggerValue += EZDAPM_memTriggerStep;

    self.lastReportMEMTS = curTS;
    NSString *reportString = [EZDAPMBacktrace getCurrentTraceLogWithTraceInfo:false onlyMainThread:false operationPathInfo:true];
    NSString *fileName = [NSString stringWithFormat:@"memHighUse_%@_%ld.crash",[EZDAPMUtil shareInstance].mIDFA,(long)self.lastReportMEMTS];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[EZDAPMUtil shareInstance].crashFilePath,fileName];
    [reportString writeToFile:filePath atomically:true encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"memory high usage! --> %@",filePath);
    [EZDAPMOperationRecorder recordOperation:fileName operationType:EZDAPMOperationMemoryHeigh filePath:filePath];
}

@end
