//
//  EZDMenuTitleHeaderView.m
//  easydebug_Example
//
//  Created by qingting on 2020/11/13.
//  Copyright © 2020 Song. All rights reserved.
//

#import "EZDMenuTitleHeaderView.h"

@interface EZDMenuTitleHeaderView ()

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation EZDMenuTitleHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.nameLabel = [[UILabel alloc] initWithFrame:self.frame];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    self.nameLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor darkGrayColor];
    [self addSubview:self.nameLabel];
}

- (void)layoutSubviews {
    self.nameLabel.frame = self.bounds;
}

#pragma mark - getter && setter
- (void)setSecTitle:(NSString *)secTitle {
    _secTitle = secTitle;
    self.nameLabel.text = secTitle;
}

@end
