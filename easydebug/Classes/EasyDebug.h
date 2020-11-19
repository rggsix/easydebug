//
//  EasyDebug.h
//  easydebug
//
//  Created by Song on 2018/8/21.
//

#import <Foundation/Foundation.h>
#import "EZDOptions.h"
#import "EZDDefine.h"

@class EZDDisplayer;
@class EZDLogger;

typedef NSString * _Nonnull const kEZDLogLevel;

//  --------------  Log level  --------------
///  DEBUG : 开发调试用的log
static kEZDLogLevel kEZDLogLevelDebug = @"[D]";
///  INFO : 程序的业务逻辑过程
static kEZDLogLevel kEZDLogLevelInfo = @"[I]";
///  WARN : 潜在问题，不影响运行
static kEZDLogLevel kEZDLogLevelWarning = @"[W]";
///  ERROR : 严重错误，不影响运行
static kEZDLogLevel kEZDLogLevelError = @"[E]";
///  FATAL : 已经影响运行，会导致crash
static kEZDLogLevel kEZDLogLevelFatal = @"[F]";


//  --------------  Log method  --------------

/**
 记录一个业务逻辑log
 BLL : Bussiness logic layer
 
 @param log log描述，不建议为空
 */
void EZDBLLLog(NSString * _Nonnull log,...);

/**
 记录一个业务逻辑log
 
 @param tag log相关tag，方便进行过滤，如果无需要可以不写
 @param level log等级，可为空，默认为Info等级
 @param param log具体参数，可为空
 @param log log描述，不建议为空
 */
void EZDBLLLog_D(NSString * _Nullable tag,
                 kEZDLogLevel level,
                 NSDictionary *_Nullable param,
                 NSString * _Nonnull log,...);

/**
 注册Debug option handler，这个类需要继承自 EZDOptions
 @see EZDOptions
 
 @param optionHandleClass -> 自定义的 debug option 类，自行在内部返回"optionItems"列表，并在didOperaionOptionCell:atRow:callback:中执行具体操作
 
 */
void EZDRegiestDebugOptions(Class _Nonnull optionHandleClass);

/**
 设置控制台显示的Log等级，低于这个等级的将不显示
 */
void EZDSetConsoleDisplayLogLevel(kEZDLogLevel level);
