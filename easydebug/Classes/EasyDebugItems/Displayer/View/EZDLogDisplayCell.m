//
//  EZDLogDisplayCell.m
//  HoldCoin
//
//  Created by Song on 2018/10/8.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDLogDisplayCell.h"

#import "UIView+EZDAddition_frame.h"

#import "EZDDefine.h"

@interface EZDLogDisplayCell()

@property (strong,nonatomic) UILabel *typeLabel;
@property (strong,nonatomic) UILabel *abstractLabel;
@property (strong,nonatomic) UILabel *timeLabel;

@end

@implementation EZDLogDisplayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupBaseUI];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.typeLabel.frame = CGRectMake(18, 8, self.contentView.ezd_width-36, self.typeLabel.ezd_height);
    
    self.abstractLabel.ezd_size = [self.abstractLabel.text boundingRectWithSize:CGSizeMake(self.contentView.ezd_width-36, 38) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:self.abstractLabel.font} context:nil].size;
    self.abstractLabel.ezd_origin = CGPointMake(18, self.typeLabel.ezd_maxY+3);
    
    self.timeLabel.frame = CGRectMake(18, 0, self.contentView.ezd_width-36, self.timeLabel.ezd_height);
    self.timeLabel.ezd_maxY = self.contentView.ezd_height - 8;
}

- (void)setupBaseUI{
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.typeLabel = [self newLabelWithFont:kEZDRegularFontSize(15)];
    self.typeLabel.textColor = [UIColor colorWithWhite:34.0/255.0 alpha:1];

    self.abstractLabel = [self newLabelWithFont:kEZDRegularFontSize(12)];
    self.abstractLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.abstractLabel.textColor = [UIColor colorWithWhite:34.0/255.0 alpha:1];
    self.abstractLabel.numberOfLines = 2;
    
    self.timeLabel = [self newLabelWithFont:kEZDRegularFontSize(10)];
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    
    [self.contentView addSubview:self.typeLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.abstractLabel];
}

- (void)setLogModel:(EZDLoggerModel *)logModel{
    _logModel = logModel;
    self.typeLabel.text = [NSString stringWithFormat:@"%ld - %@", (long)self.rowOfCell, self.logModel.displayTypeName];
    self.abstractLabel.text = logModel.abstractString;
    self.timeLabel.text = logModel.dateDes;
}

- (UILabel *)newLabelWithFont:(UIFont *)font{
    UILabel *label = [UILabel new];
    label.font = font;
    label.text = @" ";
    [label sizeToFit];
    return label;
}

@end
