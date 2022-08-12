//
//  EasyDebugUtil.m
//  EasyDebug
//
//  Created by songheng on 2020/11/25.
//

#import "EasyDebugUtil.h"
#import "EasyDebug.h"
#import <objc/runtime.h>


static NSString *_buildVersion = nil;
static NSString *_appVersion = nil;
static NSString *_appDisplayName = nil;

@implementation EasyDebugUtil

+ (void)exchangeOriginMethod:(SEL)originSEL newMethod:(SEL)newSEL mclass:(Class)mclass{
    Method originalMethod = class_getInstanceMethod(mclass, originSEL);
    Method newMethod = class_getInstanceMethod(mclass, newSEL);
    
    BOOL ret = class_addMethod(mclass,originSEL,
                    method_getImplementation(newMethod),
                    method_getTypeEncoding(newMethod));
    
    if (ret) {
        class_replaceMethod(mclass,originSEL,
                            method_getImplementation(newMethod),
                            method_getTypeEncoding(newMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

+ (void)exchangeClassOriginMethod:(SEL)originSEL newMethod:(SEL)newSEL
                           mclass:(Class)mclass{
    Class bclass = object_getClass(mclass);
    
    Method originalMethod = class_getClassMethod(bclass, originSEL);
    Method newMethod = class_getClassMethod(bclass, newSEL);
    
    BOOL ret = class_addMethod(bclass,originSEL,
                               method_getImplementation(newMethod),
                               method_getTypeEncoding(newMethod));
    
    if (ret) {
        class_replaceMethod(bclass,originSEL,
                            method_getImplementation(newMethod),
                            method_getTypeEncoding(newMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

+ (void)executeMain:(void(^)(void))block {
    if (NSThread.isMainThread){
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

+ (NSString*)iosRawVersion{
    return [UIDevice currentDevice].systemVersion;
}

+ (NSString*)buildVersion{
    if (_buildVersion) {
        return _buildVersion;
    }
    _buildVersion = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    return _buildVersion;
}

+ (NSString*)appVersion{
    if (_appVersion) {
        return _appVersion;
    }
    _appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: @"";
    return _appVersion;
}

+ (NSString*)appDisplayName{
    if (_appDisplayName) {
        return _appDisplayName;
    }
    _appDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (DGIsNotNull(_appDisplayName)) {
      return _appDisplayName;
    }
    _appDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey] ?: @"";
    return _appDisplayName;
}

+ (UIWindow *)currentWindow{
    __block UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (![window isKeyWindow]) {
        [[[UIApplication sharedApplication] windows] enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKeyWindow]) {
                window = obj;
                *stop = YES;
            }
        }];
    }
    return window;
}

+ (NSString *)appShortInfo {
    NSString *appInfo = [NSString stringWithFormat:@"App : %@ %@(%@)\nDevice : %@\nOS Version : %@ %@\n",
                         [self appDisplayName],
                         [self appVersion],
                         [self buildVersion],
                         [UIDevice currentDevice].model,
                         [UIDevice currentDevice].systemName,
                         [self iosRawVersion]];
    return appInfo;
}

+(NSBundle*)resourceBundle{
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent:@"/EasyDebug.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    if(!bundle){
        //在pod代码所在项目本地测试时
        bundle = [NSBundle mainBundle];
    }
    return bundle;
}

+(UIImage*)imageNamed:(NSString*)name{
    NSBundle *bundle = [self resourceBundle];
    UIImage *image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}

#pragma mark - File Operations

+ (NSData*_Nullable)getDataFromFileOfPath:(NSString*)path{
    if ([self fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        return data;
    }
    return nil;
}

+ (NSDictionary*_Nullable)getDicFromFileOfPath:(NSString*)path{
    NSData *data = [self getDataFromFileOfPath:path];
    if (data == nil) {
        return nil;
    }
    NSDictionary* dic = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    return dic;
}

+ (void)createFileIfNotExistsAtPath:(NSString*)path{
    if ([self fileExistsAtPath:path]) {
        return;
    }
    NSString *folderPath = [path stringByDeletingLastPathComponent];
    [self createFolder:folderPath];
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
}

+ (BOOL)saveData:(NSData*)data toPath:(NSString*)path{
    [self createFileIfNotExistsAtPath:path];
    return [data writeToFile:path atomically:YES];
}

+ (BOOL)saveDic:(NSDictionary*)dic toPath:(NSString*)path{
    if ([self verifyArchivable:dic]) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
        return [self saveData:data toPath:path];
    }
    return NO;
}

+ (BOOL)verifyArchivable:(id)obj {
    __block BOOL valid = YES;
    if ([obj isKindOfClass:[NSArray class]]) {
        [(NSArray *)obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![self verifyArchivable:obj]) {
                valid = NO;
                *stop = YES;
            }
        }];
        return valid;
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        [(NSDictionary *)obj enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            BOOL keyValid = [self verifyArchivable:key];
            BOOL valueValid = [self verifyArchivable:obj];
            if (!keyValid || !valueValid) {
                valid = NO;
                *stop = YES;
            }
        }];
        return valid;
    } else {
        return [(NSObject *)obj conformsToProtocol:NSProtocolFromString(@"NSCoding")];
    }
}

+ (BOOL)createFolder:(NSString *)path {
    //当文件夹不存在的时候再创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                                   attributes:nil error:nil];
    }
    else{
        return NO;
    }
}

+ (BOOL)folderExistsAtPath:(NSString *)path {
    BOOL isD;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isD]) {
        if (isD) {
            return YES;
        }
        else{
            return NO;
        }
    }
    return NO;
}

+ (BOOL)fileExistsAtPath:(NSString *)path {
    BOOL isD;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isD]) {
        if (isD) {
            return NO;
        }
        else{
            return YES;
        }
    }
    return NO;
}

+ (BOOL)deleteFileOfPath:(NSString*)path{
    if (![self fileExistsAtPath:path]) {
        return YES;
    }
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if (success) {
        return YES;
    }
    else {
        if (error) {
            NSLog(@"Could not delete file -:%@\n", [error localizedDescription]);
        }
        return NO;
    }
}

@end
