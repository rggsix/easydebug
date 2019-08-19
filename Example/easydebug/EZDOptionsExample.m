//
//  EZDOptionsExample.m
//  easydebug_Example
//
//  Created by EDZ on 2019/8/19.
//  Copyright © 2019 Song. All rights reserved.
//

#import "EZDOptionsExample.h"

@implementation EZDOptionsExample

//  Add this to make sure debug code only in development environment.
#if EZDEBUG_DEBUGLOG

- (NSArray<EZDOptionItem *> *)optionItems{
    bool sthIsOn = [self.userDefaultOptions boolForKey:kEZDOptionSomethingSwitchKey];
    
    return @[
             // 0
             [[EZDOptionPikerItem alloc] initWithTitle:@"Exchange base URL for App" pickerOptions:@[
                                                                                           @"https://dev_url",
                                                                                           @"https://release_url",
                                                                                           ]],
             [[EZDOptionAlertItem alloc] initWithTitle:@"In put url direct" messageString:@"Simple : https://192.168.1.13/"],
             [[EZDOptionSwitchItem alloc] initWithTitle:@"Open or close sth" isOn:sthIsOn],
             [[EZDOptionNormalItem alloc] initWithTitle:@"Do sth now"],
             ];
}

- (void)didOperaionOptionCell:(EZDOptionItem *)optionItem atRow:(NSInteger)row callback:(void (^)(EZDOptionItem *))callback{
    switch (row) {
        case 0:
            [self needChangeApiServerWithItem:(EZDOptionPikerItem *)optionItem];
            break;
        case 1:
            [self needChangeApiServerSelfHelpWithItem:(EZDOptionAlertItem *)optionItem];
            break;
        case 2:
            [self closeSomeThing:(EZDOptionSwitchItem *)optionItem];
            break;
        case 3:
            [self nowDoSomething];
            break;
        default:
            break;
    }
    callback ? callback(optionItem) : nil;
}

- (void)needChangeApiServerWithItem:(EZDOptionPikerItem *)item{
//    NSString *selectURL = item.seletedOption;
//    [self changeBaseURLWithURLString:selectURL];
}

- (void)needChangeApiServerSelfHelpWithItem:(EZDOptionAlertItem *)item{
    if (!item.isConfirm) {
        return;
    }
//    NSString *selectURL = item.alertInputString;
//    [self changeBaseURLWithURLString:selectURL];
}

- (void)closeSomeThing:(EZDOptionSwitchItem *)item{
    bool sthOn = [self.userDefaultOptions boolForKey:kEZDOptionSomethingSwitchKey];
    item.isOn = !sthOn;
    [self.userDefaultOptions setBool:!sthOn forKey:kEZDOptionSomethingSwitchKey];
    [self.userDefaultOptions synchronize];
}

- (void)nowDoSomething{
    
}

#endif

@end
