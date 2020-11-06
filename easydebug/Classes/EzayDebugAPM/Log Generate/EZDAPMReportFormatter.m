//
//  EZDAPMReportFormatter.m
//  HoldCoin
//
//  Created by Song on 2019/1/24.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDAPMReportFormatter.h"
#import "EZDAPMUtil.h"
#import "EZDAPMOperationRecorder.h"
#import "BSBacktraceLogger.h"

@implementation EZDAPMReportFormatter

static NSInteger binaryImageSort(id binary1, id binary2, void *context) {
    uint64_t addr1 = [binary1 imageBaseAddress];
    uint64_t addr2 = [binary2 imageBaseAddress];
    
    if (addr1 < addr2)
        return NSOrderedAscending;
    else if (addr1 > addr2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

+ (NSString *)reportStringWithTraceInfo:(bool)traceInfo onlyMainThread:(bool)onlyMainThread operationInfo:(bool)operationInfo{
    NSMutableString *text = [self generateBaseSystemInfo:[NSMutableString string]];
    
    if (traceInfo) {
        [self generateBacktraceInfo:text onlyMainThread:onlyMainThread];
    }
    
    if (operationInfo) {
        [self generateUserOperationPath:text];
    }
    
    return [text copy];
}

+ (NSMutableString *)generateBaseSystemInfo:(NSMutableString *)text{
    EZDAPMUtil *util = [EZDAPMUtil shareInstance];
    [text appendFormat:@"Incident Identifier: %@\n\
CrashReporter Key:   TODO\n\
App Lauched Duration:   %f\n\
Last View Controller:  %@\n\
Current View Controller:  %@\n\
Current VC Stay Duration:  %f\n\
Process:         %@ [%@]\n\
Version:         %@\n\
Build Version:   %@\n\
Phone Type:       %@\n\
\n\
Date/Time:       %@\n\
OS Version:      %@\n\n",
     util.mIDFA,util.launchedTime , util.lastVCName, util.currentVCName,
       util.currentVCStayTime, util.processName, util.processID,
       util.appVersion, util.appBuildVersion, util.phoneType,[NSDate date] ,util.osVersion];
    
    [text appendFormat:@"Battery Quantity:  %.2f%%\n\
CPU Usage: %.2f%%\n\
Memory Usage: %lld M\n\
Total Disk Size:   %@\n\
Avilable Disk Size:    %@\n\
Network State: %@\n\n",
     [EZDAPMUtil getBatteryQuantity], [EZDAPMUtil cpuUsage], [EZDAPMUtil memoryUsage],
     [EZDAPMUtil fileSizeToString:[EZDAPMUtil getTotalDiskSize]],
     [EZDAPMUtil fileSizeToString:[EZDAPMUtil getAvailableDiskSize]],
     [EZDAPMUtil getNetworkState]];
    
    return text;
}

+ (NSMutableString *)generateBacktraceInfo:(NSMutableString *)text onlyMainThread:(bool)onlyMainThread{
    [text appendFormat:@"\n|---------------Tread Info---------------|\n\n%@",onlyMainThread ? [BSBacktraceLogger bs_backtraceOfMainThread] : [BSBacktraceLogger bs_backtraceOfAllThread]];
    return text;
}

+ (NSMutableString *)generateUserOperationPath:(NSMutableString *)text{
    [text appendFormat:@"\n|---------------Operation Info---------------|\n\n%@",[EZDAPMOperationRecorder currentOperationPathInfo]];
    return text;
}

#pragma mark - PLCrashReportFormatter
+ (NSString *)plframe_reportStringWithReport:(PLCrashReport *)report traceInfo:(bool)traceInfo operationInfo:(bool)operationInfo{
//    return [PLCrashReportTextFormatter stringValueForCrashReport:report withTextFormat:0];
    
    NSMutableString* text = [NSMutableString string];
    boolean_t lp64 = true; // quiesce GCC uninitialized value warning

    {
        NSString *hardwareModel = @"???";
        if (report.hasMachineInfo && report.machineInfo.modelName != nil)
            hardwareModel = report.machineInfo.modelName;
        
        NSString *incidentIdentifier = @"???";
        if (report.uuidRef != NULL) {
            incidentIdentifier = (NSString *) CFBridgingRelease(CFUUIDCreateString(NULL, report.uuidRef));
        }
        
        [text appendFormat: @"Incident Identifier: %@\n", incidentIdentifier];
        [text appendFormat: @"CrashReporter Key:   TODO\n"];
        [text appendFormat: @"Hardware Model:      %@\n", hardwareModel];
        [text appendFormat: @"Last View Controller:  %@\n",[EZDAPMUtil shareInstance].lastVCName];
        [text appendFormat: @"Current View Controller:  %@\n",[EZDAPMUtil shareInstance].currentVCName];
    }
    
    /* Application and process info */
    {
        NSString *unknownString = @"???";
        
        NSString *processName = unknownString;
        NSString *processId = unknownString;
        NSString *processPath = unknownString;
        NSString *parentProcessName = unknownString;
        NSString *parentProcessId = unknownString;
        
        /* Process information was not available in earlier crash report versions */
        if (report.hasProcessInfo) {
            /* Process Name */
            if (report.processInfo.processName != nil)
                processName = report.processInfo.processName;
            
            /* PID */
            processId = [[NSNumber numberWithUnsignedInteger: report.processInfo.processID] stringValue];
            
            /* Process Path */
            if (report.processInfo.processPath != nil)
                processPath = report.processInfo.processPath;
            
            /* Parent Process Name */
            if (report.processInfo.parentProcessName != nil)
                parentProcessName = report.processInfo.parentProcessName;
            
            /* Parent Process ID */
            parentProcessId = [[NSNumber numberWithUnsignedInteger: report.processInfo.parentProcessID] stringValue];
        }
        
        [text appendFormat: @"Process:         %@ [%@]\n", processName, processId];
        [text appendFormat: @"Path:            %@\n", processPath];
        [text appendFormat: @"Identifier:      %@\n", report.applicationInfo.applicationIdentifier];
        [text appendFormat: @"Version:         %@\n", [EZDAPMUtil shareInstance].appVersionStr];
        [text appendFormat: @"Phone Type:       %@\n", [EZDAPMUtil shareInstance].phoneType];
        [text appendFormat: @"Parent Process:  %@ [%@]\n", parentProcessName, parentProcessId];
    }
    
    [text appendString: @"\n"];
    
    /* System info */
    {
        NSString *osBuild = @"???";
        if (report.systemInfo.operatingSystemBuild != nil)
            osBuild = report.systemInfo.operatingSystemBuild;
        
        [text appendFormat: @"Date/Time:       %@\n", [NSDate date]];
        [text appendFormat: @"OS Version:      iOS %@ (%@)\n", [EZDAPMUtil shareInstance].osVersion, osBuild];
        [text appendFormat: @"Report Version:  104\n"];
    }
    
    [text appendString: @"\n"];
    
    /* Exception code */
    [text appendFormat: @"Exception Type:  %@\n", report.signalInfo.name];
    [text appendFormat: @"Exception Codes: %@ at 0x%" PRIx64 "\n", report.signalInfo.code, report.signalInfo.address];
    
    for (PLCrashReportThreadInfo *thread in report.threads) {
        if (thread.crashed) {
            [text appendFormat: @"Crashed Thread:  %ld\n", (long) thread.threadNumber];
            break;
        }
    }
    
    [text appendString: @"\n"];
    
    /* Uncaught Exception */
    if (report.hasExceptionInfo) {
        [text appendFormat: @"Application Specific Information:\n"];
        [text appendFormat: @"*** Terminating app due to uncaught exception '%@', reason: '%@'\n",
         report.exceptionInfo.exceptionName, report.exceptionInfo.exceptionReason];
        
        [text appendString: @"\n"];
    }
    
    /* If an exception stack trace is available, output an Apple-compatible backtrace. */
    if (report.exceptionInfo != nil && report.exceptionInfo.stackFrames != nil && [report.exceptionInfo.stackFrames count] > 0) {
        PLCrashReportExceptionInfo *exception = report.exceptionInfo;
        
        /* Create the header. */
        [text appendString: @"Last Exception Backtrace:\n"];
        
        /* Write out the frames. In raw reports, Apple writes this out as a simple list of PCs. In the minimally
         * post-processed report, Apple writes this out as full frame entries. We use the latter format. */
        for (NSUInteger frame_idx = 0; frame_idx < [exception.stackFrames count]; frame_idx++) {
            PLCrashReportStackFrameInfo *frameInfo = [exception.stackFrames objectAtIndex: frame_idx];
            [text appendString: [self formatStackFrame: frameInfo frameIndex: frame_idx report: report lp64: lp64]];
        }
        [text appendString: @"\n"];
    }
    
    /* Threads */
    
    PLCrashReportThreadInfo *crashed_thread = nil;
    NSInteger maxThreadNum = 0;
    
    if (!traceInfo) goto OperationPathInfoGen;
    for (PLCrashReportThreadInfo *thread in report.threads) {
        if (thread.crashed) {
            [text appendFormat: @"Thread %ld Crashed:\n", (long) thread.threadNumber];
            crashed_thread = thread;
        } else {
            [text appendFormat: @"Thread %ld:\n", (long) thread.threadNumber];
        }
        for (NSUInteger frame_idx = 0; frame_idx < [thread.stackFrames count]; frame_idx++) {
            PLCrashReportStackFrameInfo *frameInfo = [thread.stackFrames objectAtIndex: frame_idx];
            [text appendString: [self formatStackFrame: frameInfo frameIndex: frame_idx report: report lp64: lp64]];
        }
        [text appendString: @"\n"];
        
        /* Track the highest thread number */
        maxThreadNum = MAX(maxThreadNum, thread.threadNumber);
    }
    
    /* Registers */
    if (crashed_thread != nil) {
        [text appendFormat: @"Thread %ld crashed :\n", (long) crashed_thread.threadNumber];
        
        int regColumn = 0;
        for (PLCrashReportRegisterInfo *reg in crashed_thread.registers) {
            NSString *reg_fmt;
            
            /* Use 32-bit or 64-bit fixed width format for the register values */
            if (lp64)
                reg_fmt = @"%6s: 0x%016" PRIx64 " ";
            else
                reg_fmt = @"%6s: 0x%08" PRIx64 " ";
            
            /* Remap register names to match Apple's crash reports */
            NSString *regName = reg.registerName;
            if (report.machineInfo != nil && report.machineInfo.processorInfo.typeEncoding == PLCrashReportProcessorTypeEncodingMach) {
                PLCrashReportProcessorInfo *pinfo = report.machineInfo.processorInfo;
                cpu_type_t arch_type = pinfo.type & ~CPU_ARCH_MASK;
                
                /* Apple uses 'ip' rather than 'r12' on ARM */
                if (arch_type == CPU_TYPE_ARM && [regName isEqual: @"r12"]) {
                    regName = @"ip";
                }
            }
            [text appendFormat: reg_fmt, [regName UTF8String], reg.registerValue];
            
            regColumn++;
            if (regColumn == 4) {
                [text appendString: @"\n"];
                regColumn = 0;
            }
        }
        
        if (regColumn != 0)
            [text appendString: @"\n"];
        
        [text appendString: @"\n"];
    }
    
    /* Images. The iPhone crash report format sorts these in ascending order, by the base address */
    [text appendString: @"Binary Images:\n"];
    for (PLCrashReportBinaryImageInfo *imageInfo in [report.images sortedArrayUsingFunction: binaryImageSort context: nil]) {
        NSString *uuid;
        /* Fetch the UUID if it exists */
        if (imageInfo.hasImageUUID)
            uuid = imageInfo.imageUUID;
        else
            uuid = @"???";
        
        /* Determine the architecture string */
        NSString *archName = @"???";
        if (imageInfo.codeType != nil && imageInfo.codeType.typeEncoding == PLCrashReportProcessorTypeEncodingMach) {
            switch (imageInfo.codeType.type) {
                case CPU_TYPE_ARM:
                    /* Apple includes subtype for ARM binaries. */
                    switch (imageInfo.codeType.subtype) {
                        case CPU_SUBTYPE_ARM_V6:
                            archName = @"armv6";
                            break;
                            
                        case CPU_SUBTYPE_ARM_V7:
                            archName = @"armv7";
                            break;
                            
                        case CPU_SUBTYPE_ARM_V7S:
                            archName = @"armv7s";
                            break;
                            
                        default:
                            archName = @"arm-unknown";
                            break;
                    }
                    break;
                    
                case CPU_TYPE_ARM64:
                    /* Apple includes subtype for ARM64 binaries. */
                    switch (imageInfo.codeType.subtype) {
                        case CPU_SUBTYPE_ARM_ALL:
                            archName = @"arm64";
                            break;
                            
                        case CPU_SUBTYPE_ARM_V8:
                            archName = @"armv8";
                            break;
                            
                        default:
                            archName = @"arm64-unknown";
                            break;
                    }
                    break;
                    
                case CPU_TYPE_X86:
                    archName = @"i386";
                    break;
                    
                case CPU_TYPE_X86_64:
                    archName = @"x86_64";
                    break;
                    
                case CPU_TYPE_POWERPC:
                    archName = @"powerpc";
                    break;
                    
                default:
                    // Use the default archName value (initialized above).
                    break;
            }
        }
        
        /* Determine if this is the main executable */
        NSString *binaryDesignator = @" ";
        if ([imageInfo.imageName isEqual: report.processInfo.processPath])
            binaryDesignator = @"+";
        
        /* base_address - terminating_address [designator]file_name arch <uuid> file_path */
        NSString *fmt = nil;
        if (lp64) {
            fmt = @"%18#" PRIx64 " - %18#" PRIx64 " %@%@ %@  <%@> %@\n";
        } else {
            fmt = @"%10#" PRIx64 " - %10#" PRIx64 " %@%@ %@  <%@> %@\n";
        }
        
        [text appendFormat: fmt,
         imageInfo.imageBaseAddress,
         imageInfo.imageBaseAddress + (MAX(1, imageInfo.imageSize) - 1), // The Apple format uses an inclusive range
         binaryDesignator,
         [imageInfo.imageName lastPathComponent],
         archName,
         uuid,
         imageInfo.imageName];
    }
    
OperationPathInfoGen:
    if (!operationInfo) goto CrashLogEndGen;
    [text appendFormat:@"\n\nUser Operation Path: \n%@",[EZDAPMOperationRecorder currentOperationPathInfo]];
    
CrashLogEndGen:
    return text;
//    return [PLCrashReportTextFormatter stringValueForCrashReport:report withTextFormat:(PLCrashReportTextFormatiOS)];
}

+ (NSString *) formatStackFrame: (PLCrashReportStackFrameInfo *) frameInfo
                     frameIndex: (NSUInteger) frameIndex
                         report: (PLCrashReport *) report
                           lp64: (BOOL) lp64
{
    /* Base image address containing instrumention pointer, offset of the IP from that base
     * address, and the associated image name */
    uint64_t baseAddress = 0x0;
    uint64_t pcOffset = 0x0;
    NSString *imageName = @"\?\?\?";
    NSString *symbolString = nil;
    
    PLCrashReportBinaryImageInfo *imageInfo = [report imageForAddress: frameInfo.instructionPointer];
    if (imageInfo != nil) {
        imageName = [imageInfo.imageName lastPathComponent];
        baseAddress = imageInfo.imageBaseAddress;
        pcOffset = frameInfo.instructionPointer - imageInfo.imageBaseAddress;
    }
    
    /* If symbol info is available, the format used in Apple's reports is Sym + OffsetFromSym. Otherwise,
     * the format used is imageBaseAddress + offsetToIP */
    if (frameInfo.symbolInfo != nil) {
        NSString *symbolName = frameInfo.symbolInfo.symbolName;
        
        /* Apple strips the _ symbol prefix in their reports. Only OS X makes use of an
         * underscore symbol prefix by default. */
        if ([symbolName rangeOfString: @"_"].location == 0 && [symbolName length] > 1) {
            switch (report.systemInfo.operatingSystem) {
                case PLCrashReportOperatingSystemMacOSX:
                case PLCrashReportOperatingSystemiPhoneOS:
                case PLCrashReportOperatingSystemiPhoneSimulator:
                    symbolName = [symbolName substringFromIndex: 1];
                    break;
                    
                default:
                    NSLog(@"Symbol prefix rules are unknown for this OS!");
                    break;
            }
        }
        
        
        uint64_t symOffset = frameInfo.instructionPointer - frameInfo.symbolInfo.startAddress;
        symbolString = [NSString stringWithFormat: @"%@ + %" PRId64, symbolName, symOffset];
    } else {
        symbolString = [NSString stringWithFormat: @"0x%" PRIx64 " + %" PRId64, baseAddress, pcOffset];
    }
    
    /* Note that width specifiers are ignored for %@, but work for C strings.
     * UTF-8 is not correctly handled with %s (it depends on the system encoding), but
     * UTF-16 is supported via %S, so we use it here */
    return [NSString stringWithFormat: @"%-4ld%-35S 0x%0*" PRIx64 " %@\n",
            (long) frameIndex,
            (const uint16_t *)[imageName cStringUsingEncoding: NSUTF16StringEncoding],
            lp64 ? 16 : 8, frameInfo.instructionPointer,
            symbolString];
}

- (NSData *)formatReport:(PLCrashReport *)report error:(NSError *__autoreleasing *)outError{
    return [[EZDAPMReportFormatter plframe_reportStringWithReport:report traceInfo:true operationInfo:true] dataUsingEncoding:(NSUTF8StringEncoding)];
}

@end
