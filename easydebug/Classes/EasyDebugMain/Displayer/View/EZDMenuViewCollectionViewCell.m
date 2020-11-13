//
//  EZDMenuViewCollectionViewCell.m
//  easydebug_Example
//
//  Created by qingting on 2020/11/13.
//  Copyright © 2020 Song. All rights reserved.
//

#import "EZDMenuViewCollectionViewCell.h"

@interface EZDMenuViewCollectionViewCell ()

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation EZDMenuViewCollectionViewCell

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
    self.nameLabel.layer.borderColor = [UIColor grayColor].CGColor;
    self.nameLabel.layer.borderWidth = 1.f;
    self.nameLabel.layer.cornerRadius = 4.f;
    [self addSubview:self.nameLabel];
}

- (void)layoutSubviews {
    self.nameLabel.frame = self.contentView.bounds;
}

#pragma mark - getter && setter
- (void)setModel:(EZDMenuInfoModel *)model {
    _model = model;
    
    self.nameLabel.text = model.title;
}

@end
