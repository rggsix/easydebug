//
//  NSObject+EZDAddition.m
//  HoldCoin
//
//  Created by Song on 2018/10/18.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "NSObject+EZDAddition.h"
#import "EZDDefine.h"
#import <objc/message.h>

@implementation NSObject (EZDDescription)

- (void)ezd_printAllPropertys{
    unsigned int count;
    const char *clasName = object_getClassName(self);
    NSMutableString *string = [NSMutableString stringWithFormat:@"<%s: %p>:[ \n",clasName, self];
    Class clas = NSClassFromString([NSString stringWithCString:clasName encoding:NSUTF8StringEncoding]);
    Ivar *ivars = class_copyIvarList(clas, &count);
    for (int i = 0; i < count; i++) {
        @autoreleasepool {
            Ivar ivar = ivars[i];
            const char *name = ivar_getName(ivar);
            NSString *type = [NSString stringWithCString:ivar_getTypeEncoding(ivar) encoding:NSUTF8StringEncoding];
            NSString *key = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            @try {
                id value = [self valueForKey:key];
                if ([[type uppercaseString] isEqualToString:@"B"]) {
                    value = (value == 0 ? @"NO" : @"YES");
                }
                [string appendFormat:@"\t%@: %@\n",key, value];
            } @catch (NSException *exception) {
                NSLog(@"ezd_printAllPropertys fail : %@", exception);
            }
        }
    }
    [string appendFormat:@"]"];
    NSLog(@"%@ porperty list : %@",self,string);
}

- (void)ezd_printAllMethod {
    unsigned int outCount;

    Method *methodList = class_copyMethodList(self.class, &outCount);
    for (int i=0;i<outCount;i++,methodList++){
        NSLog(@"%i SEL : %@ , typeEncode : %s",i,
                NSStringFromSelector(method_getName(*methodList)),method_getTypeEncoding(*methodList));
        struct objc_method_description *des = method_getDescription(*methodList);
        NSLog(@"%i des_name : %@ , des_type : %s",i,NSStringFromSelector(des->name),des->types);
    }
}

- (NSString *)ezd_description{
    NSString *jsonStr = [self ezd_JSONString];
    if (!jsonStr.length) {
        jsonStr = [self description];
    }
    return jsonStr;
}

- (NSString *)ezd_JSONString
{
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    } else if ([self isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:(NSData *)self encoding:NSUTF8StringEncoding];
    } else if ([[self class] isSubclassOfClass:[NSNumber class]]){
        return [self description];
    } else if ([self isKindOfClass:[NSError class]]) {
        return [self description];
    } 
    
    NSString *desStr = [self description];
    @try {
        id dataObj = self;
        if ([self respondsToSelector:@selector(yy_modelToJSONObject)]) {
            dataObj = [self performSelector:@selector(yy_modelToJSONObject)];
        }
        desStr = [[[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dataObj options:(NSJSONWritingPrettyPrinted) error:nil] encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    } @catch (NSException *exception) {
        
    } @finally {
        return desStr;
    }
}

+ (bool)isSubClassAndNotItSelf:(Class)cls{
    return [self isSubclassOfClass:cls] && ![self isEqual:cls];
}

@end
