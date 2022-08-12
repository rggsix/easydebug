//
//  EasyDebug.m
//  EasyDebug
//
//  Created by songheng on 2020/11/25.
//

#import "EasyDebug.h"
#import "EZDDisplayer.h"
#import "EasyDebugUtil.h"
#import "EZDLogManager.h"
#import <objc/runtime.h>

static NSString *kDebugIsOnKey = @"kDebugIsOnKey";

@interface EasyDebug ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, DebugLogAbstractProvider> *abstractProviderMap;
@property (nonatomic, copy) NSString *settingFilePath;

@end

@implementation EasyDebug

static NSArray<NSString *> *_EasyDebug_validTags;

+ (instancetype)shared{
    static EasyDebug *ins;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[self alloc] init];
    });
    return ins;
}

- (instancetype)init {
    if (self = [super init]) {
        self.abstractProviderMap = [[NSMutableDictionary alloc] init];
        NSString *folderPath = [self appSupportPath:@"EasyDebug"];
        [EasyDebugUtil createFolder:folderPath];
        _settingFilePath = [folderPath stringByAppendingPathComponent:kDebugSettingFileName];
        if(![EasyDebugUtil fileExistsAtPath:_settingFilePath]){
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [EasyDebugUtil saveDic:dic toPath:_settingFilePath];
        }
    }
    return self;
}

- (NSString *)appSupportPath:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:filename];
}

- (id _Nullable)getSettingValue:(NSString*)key{
    @synchronized (self.class) {
        NSDictionary *dic = [EasyDebugUtil getDicFromFileOfPath:_settingFilePath];
        if (dic) {
            return dic[key];
        }
        else {
            return nil;
        }
    }
}

- (void)saveSettingValue:(id<NSCoding>)obj forKey:(NSString *)key{
    BOOL notValidObject = (obj && ![EasyDebugUtil verifyArchivable:obj]);
    if (notValidObject) {
        NSLog(@"[xStore] %@ failed : %@ -> %@", NSStringFromSelector(_cmd), key, obj);
        return;
    }

    @synchronized (self.class) {
        NSMutableDictionary *dic = (NSMutableDictionary*)[EasyDebugUtil getDicFromFileOfPath:_settingFilePath];
        if (!dic) {
            dic = [NSMutableDictionary new];
        }
        if (obj) {
            dic[key] = obj;
        } else {
            [dic removeObjectForKey:key];
        }
        [EasyDebugUtil saveDic:dic toPath:_settingFilePath];
    }
}

#pragma mark - interface

+ (void)config:(EasyDebugModule)modules{
    [self.shared config:modules];
}

+ (void)logConsole:(NSString *)log,... {
    va_list va;
    va_start(va, log);
    NSString *format = DGNotNullString(log);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:va];
    va_end(va);
    [[EasyDebug shared] logConsole:str];
}

+ (void)log:(NSString *)log, ... {
    va_list va;
    va_start(va, log);
    NSString *format = DGNotNullString(log);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:va];
    va_end(va);
    
    [[EasyDebug shared] logWithTag:nil content:@{@"_log":DGNotNullString(str)}];
}

+ (void)logWithTag:(NSString *)tag log:(NSString *)log, ... {
    va_list va;
    va_start(va, log);
    NSString *format = DGNotNullString(log);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:va];
    va_end(va);

    [[EasyDebug shared] logWithTag:tag content:@{@"_log":DGNotNullString(str)}];
}

+ (void)logContent:(NSDictionary *)content {
    [[EasyDebug shared] logWithTag:nil content:content];
}

+ (void)logWithTag:(NSString *)tag content:(NSDictionary *)content {
    [[EasyDebug shared] logWithTag:tag content:content];
}

+ (void)logMessage:(NSString *)message; {
    [[EasyDebug shared] logWithTag:nil content:@{@"_log":DGNotNullString(message)}];
}

+ (void)logWithTag:(NSString *_Nullable)tag
           message:(NSString *)message {
    [[EasyDebug shared] logWithTag:tag content:@{@"_log":DGNotNullString(message)}];
}

+ (void)logConsoleMessage:(NSString *)message {
    [[EasyDebug shared] logConsole:DGNotNullString(message)];
}

- (void)setIsOn:(BOOL)isOn {
    if (self.isOn == isOn) {
        return;
    }
    _isOn = isOn;
    //  保存开关状态到本地
    [self saveSettingValue:@(isOn) forKey:kDebugIsOnKey];
    if (isOn) {
        [self start];
    } else {
        [self stop];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:EasyDebugIsOnChangedNotificationName object:nil];
}

/// 是否第一次使用（本地未存储开关状态）
- (BOOL) isFirstUsing {
    NSNumber *lastOn = [self getSettingValue:kDebugIsOnKey];
    return lastOn == nil;
}

- (void)registerAbstractProviderForTag:(NSString*)tag provider:(DebugLogAbstractProvider)provider{
    if (provider && DGIsNotNull(tag)) {
        self.abstractProviderMap[tag] = provider;
    }
}

- (DebugLogAbstractProvider _Nullable)getAbstractProviderForTag:(NSString*)tag{
    if(!tag){
        return nil;
    }
    return self.abstractProviderMap[tag];
}

#pragma mark - private

- (void)config:(EasyDebugModule)modules {
    [self loadLastIsOnStatus];
    
    if (modules & EasyDebugNetMonitor) {
        Class cls = NSClassFromString(@"EZDNetworkMonitor");
        if(cls && [cls respondsToSelector:@selector(config)]){
            [cls performSelector:@selector(config)];
        }
    }
    
    if (modules & EasyDebugPerformance) {
        Class cls = NSClassFromString(@"EZDPerformance");
        if(cls && [cls respondsToSelector:@selector(config)]){
            [cls performSelector:@selector(config)];
        }
    }
}

- (void)start {
    [[EZDDisplayer shared] start];
}

- (void)stop {
    [[EZDDisplayer shared] stop];
}

- (void)loadLastIsOnStatus {
    //  尝试去store取之前设置的结果
    NSNumber *lastOn = [self getSettingValue:kDebugIsOnKey];
    //  同步到属性
    self.isOn = lastOn.boolValue;
}

- (void)logWithTag:(NSString *)tag
           content:(NSDictionary *)content {
    if (self.isOn) {
        [EZDLogManager.shared recordLogWithTag:tag content:content complete:nil];
    }
}

- (void)logConsole:(NSString*)log{
    if (self.isOn){
        NSLog(@"%@", log);
    }
}

+ (void)setValidTags:(NSArray<NSString *> *)validTags {
    _EasyDebug_validTags = validTags;
}

+ (NSArray<NSString *> *)validTags {
    return _EasyDebug_validTags;
}

@end
