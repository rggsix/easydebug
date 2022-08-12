//
//  EasyDebug.h
//  EasyDebug
//
//  Created by songheng on 2020/11/25.
//

#ifndef EasyDebug_h
#define EasyDebug_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, EasyDebugModule) {
    ///  网络监控
    EasyDebugNetMonitor = 1 << 0,
    ///  性能监控
    EasyDebugPerformance = 1 << 1,
};

/// 内置tags
/// 记录网络请求tag
static NSString * _Nonnull const kDebugNetworkLogTag = @"Network";
/// 记录crash tag
static NSString * _Nonnull const kDebugCrashLogTag = @"Crash";
/// 开关通知
static NSString * _Nonnull const EasyDebugIsOnChangedNotificationName = @"EasyDebugIsOnChanged";

///  Log content 里传 `@{ kDebugLogErrorFlag : @YES }`, 这条 Log 会在 Log list 中标红
static NSString * _Nonnull const kDebugLogErrorFlag = @"__DG_IS_ERROR";

typedef NSString *_Nullable(^DebugLogAbstractProvider)(NSString * _Nullable tag, NSDictionary * _Nonnull content);

NS_ASSUME_NONNULL_BEGIN

@interface EasyDebug : NSObject

///  允许的 Tag, 比如你发布到线上, 只想记录crash, 设置为 `EasyDebug.shared.validTags = @[kDebugCrashLogTag]` 即可
@property(nonatomic, strong, nullable, class) NSArray<NSString *> *validTags;

+ (instancetype)shared;
///  启动(配置) EasyDebug, 主模块是必须配置的, 其他的自选, 见 ``EasyDebugModule``
+ (void)config:(EasyDebugModule)modules;
- (id _Nullable)getSettingValue:(NSString*)key;
- (void)saveSettingValue:(id<NSCoding>)obj forKey:(NSString *)key;

/// 向控制台打印一个log，不会持久化记录，但只会在(-)isOn == true时打印
+ (void)logConsole:(NSString *)log,...NS_FORMAT_FUNCTION(1,2);

/// 记录一个业务逻辑log
+ (void)log:(NSString *)log,...NS_FORMAT_FUNCTION(1,2);

/// 记录一个业务逻辑content
+ (void)logContent:(NSDictionary *)content;

/// 记录一个业务逻辑log，为了方便查找，不建议tag为空
+ (void)logWithTag:(NSString *_Nullable)tag
               log:(NSString *)log,...NS_FORMAT_FUNCTION(2,3);

/// 记录一个业务逻辑content，为了方便查找，不建议tag为空
+ (void)logWithTag:(NSString *_Nullable)tag
           content:(NSDictionary *)content;

/// log a message
+ (void)logMessage:(NSString *)message;
/// log a message
+ (void)logWithTag:(NSString *_Nullable)tag
           message:(NSString *)message;
/// log to console
+ (void)logConsoleMessage:(NSString *)message;

/// EasyDebug开关状态
@property (nonatomic, assign) BOOL isOn;
/// 是否第一次使用（本地未存储开关状态）
@property (nonatomic, assign, readonly) BOOL isFirstUsing;

///  生成log缩略内容回调，EasyDebug内置生成逻辑(比如Network log就是URL, 详见DebugLogContentModel)。 此回调返回字符串将替换内置生成逻辑
- (void)registerAbstractProviderForTag:(NSString*)tag provider:(DebugLogAbstractProvider)provider;
- (DebugLogAbstractProvider _Nullable)getAbstractProviderForTag:(NSString*)tag;

@end

NS_ASSUME_NONNULL_END

#endif /* EasyDebug_h */

