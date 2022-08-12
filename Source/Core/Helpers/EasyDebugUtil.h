//
//  EasyDebugUtil.h
//  EasyDebug
//
//  Created by songheng on 2020/11/25.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


static NSString * _Nonnull const kDebugSettingFileName = @"debugSettingFile";

#define DGIsNotNull(string_) ([string_ isKindOfClass:[NSString class]] && string_.length > 0)
#define DGNotNullString(string_) ([string_ isKindOfClass:[NSString class]] && string_.length) ? string_ : @""
#define DGNotNullDict(dict_) (dict_&&[dict_ isKindOfClass:[NSDictionary class]]) ? dict_ : @{}
#define DGNotNullArray(array_) (array_&&[array_ isKindOfClass:[NSArray class]]) ? array_ : @[]

//  ----------------- UI 相关 -----------------

#define kJMStatusBarHeight     (kJMISFullScreen ? kJMSafeAreaTop : 20)

#define kJMISFullScreen \
({BOOL kISFullScreen = NO;\
if (@available(iOS 11.0, *)) {\
kISFullScreen = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom > 0.0;\
}\
(kISFullScreen);})

#define kJMNavigationBarHeight 44

#define kJMSafeAreaTop \
({CGFloat kSafeAreaTop = 0;\
if (@available(iOS 11.0, *)) {\
kSafeAreaTop = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;\
}\
(kSafeAreaTop);})

NS_ASSUME_NONNULL_BEGIN

@interface EasyDebugUtil : NSObject

+ (void)exchangeOriginMethod:(SEL)originSEL newMethod:(SEL)newSEL mclass:(Class)mclass;
+ (void)exchangeClassOriginMethod:(SEL)originSEL newMethod:(SEL)newSEL mclass:(Class)mclass;

+ (void)executeMain:(void(^)(void))block;

+ (UIWindow *)currentWindow;
+ (NSString *)appShortInfo;
+ (UIImage*)imageNamed:(NSString*)name;

+ (NSData*_Nullable)getDataFromFileOfPath:(NSString*)path;
+ (BOOL)verifyArchivable:(id)obj;
+ (NSDictionary*_Nullable)getDicFromFileOfPath:(NSString*)path;
+ (void)createFileIfNotExistsAtPath:(NSString*)path;
+ (BOOL)saveData:(NSData*)data toPath:(NSString*)path;
+ (BOOL)saveDic:(NSDictionary*)dic toPath:(NSString*)path;
+ (BOOL)createFolder:(NSString *)path;
+ (BOOL)folderExistsAtPath:(NSString *)path;
+ (BOOL)fileExistsAtPath:(NSString *)path;
+ (BOOL)deleteFileOfPath:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
