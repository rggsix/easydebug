//
//  EZDDefine.h
//  HoldCoin
//
//  Created by Song on 2018/9/30.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#ifndef EZDDefine_h
#define EZDDefine_h

#ifndef EZDEBUG_DEBUGLOG
#define EZDEBUG_DEBUGLOG DEBUG
#endif

#define kEZDUserDefaultSuiteName @"framework.eazydebug.kEZDUserDefaultSuiteName"

#define EZDLog(string_) NSString *logstr_ = [NSString stringWithFormat:@"EZDebug -> %@",string_];\
NSLog(@"%@",logstr_)

#define kEZDRegularFontSize(s)        [UIFont fontWithName:@"PingFangSC-Regular" size:s]
#define kEZDSemiboldFontSize(s)        [UIFont fontWithName:@"PingFangSC-Semibold" size:s]

#define EZD_NotNullString(string_) ([string_ isKindOfClass:[NSString class]] && string_.length) ? string_ : @""
#define EZD_NotNullDict(dict_) (dict_&&[dict_ isKindOfClass:[NSDictionary class]]) ? dict_ : @{}
#define EZD_NotNullArray(array_) (array_&&[array_ isKindOfClass:[NSArray class]]) ? array_ : @[]
#define EZD_NotNullObj(obj_) obj_ ? obj_ : @{}

#define EZDNavigationBarHeight (iPhoneX_Series ? 88 : 64)

#define EZDAPMURLProtocolHandledKey @"EZDAPM_URLProtocolHandledKey"

#define dispatch_ezd_sync_safe(queue_,queue_name,block)\
if (!strcmp(dispatch_queue_get_label(queue_),queue_name)) {\
    block();\
} else {\
    dispatch_sync(queue_, block);\
}


#endif /* EZDDefine_h */
