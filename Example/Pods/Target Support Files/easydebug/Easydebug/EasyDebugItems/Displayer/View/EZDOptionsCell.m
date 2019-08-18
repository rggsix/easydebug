//
//  EZDOptionsCell.m
//  HoldCoin
//
//  Created by Song on 2018/10/20.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDOptionsCell.h"

@interface EZDOptionsCell ()

@property (nonatomic, strong) UISwitch *swicher;

@end

@implementation EZDOptionsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.swicher = [[UISwitch alloc] init];
        self.swicher.centerY = self.height *.5;
        self.swicher.x = kScreenWidth - self.swicher.width - 18;
        [self.contentView addSubview:self.swicher];
        self.swicher.userInteractionEnabled = false;
        self.swicher.hidden = true;
    }
    return self;
}

- (void)setOptionItem:(EZDOptionItem *)optionItem{
    _optionItem = optionItem;
    
    self.textLabel.text = optionItem.title;
    if (optionItem.itemType != EZDOperationItemTypeSwitch && ![optionItem isKindOfClass:[EZDOptionSwitchItem class]]) {
        self.swicher.hidden = true;
    }else{
        self.swicher.hidden = false;
        [self.swicher setOn:[(EZDOptionSwitchItem *)optionItem isOn]];
    }
}

@end
