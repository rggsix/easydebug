//
//  EZDLogAbstractCell.m
//  EasyDebug
//
//  Created by songheng on 2020/11/25.
//

#import "EZDLogAbstractCell.h"

#import "DebugCoreCategorys.h"
#import "EasyDebugUtil.h"
#import "EZDLogSearchResult.h"
#import "EasyDebug.h"

@interface EZDLogAbstractCell()

@property (strong,nonatomic) UILabel *dg_contentLabel;
@property (strong,nonatomic) UILabel *typeLabel;
@property (strong,nonatomic) UILabel *timeLabel;

@end

@implementation EZDLogAbstractCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupBaseUI];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.dg_contentLabel.dg_size = [self.dg_contentLabel.text boundingRectWithSize:CGSizeMake(self.contentView.dg_width-36, 60) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:self.dg_contentLabel.font} context:nil].size;
    self.dg_contentLabel.dg_origin = CGPointMake(18, 8);
    
    self.typeLabel.frame = CGRectMake(18, 0, self.contentView.dg_width-36, 14);
    self.typeLabel.dg_maxY = self.contentView.dg_height - 8;
    
    self.timeLabel.frame = CGRectMake(18, 0, self.contentView.dg_width-36, self.timeLabel.dg_height);
    self.timeLabel.dg_maxY = self.typeLabel.dg_maxY;
}

- (void)setupBaseUI{
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.dg_contentLabel = [self newLabelWithFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15]];
    self.dg_contentLabel.textColor = [UIColor colorWithWhite:34.0/255.0 alpha:1];
    self.dg_contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.dg_contentLabel.numberOfLines = 2;

    self.typeLabel = [self newLabelWithFont:[UIFont systemFontOfSize:12 weight:(UIFontWeightSemibold)]];
    self.typeLabel.textColor = [[UIColor systemBlueColor] colorWithAlphaComponent:.7];
    
    self.timeLabel = [self newLabelWithFont:[UIFont fontWithName:@"PingFangSC-Regular" size:10]];
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    
    [self.contentView addSubview:self.dg_contentLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.typeLabel];
}

- (void)setLogModel:(EZDLogModel *)logModel{
    _logModel = logModel;
    
    ///  错误日志标红
    self.dg_contentLabel.textColor = [logModel.contentDic[kDebugLogErrorFlag] boolValue] ? [UIColor systemRedColor] : [UIColor colorWithWhite:34.0/255.0 alpha:1];
    
    if ([logModel isKindOfClass:[EZDLogSearchResult class]]) {
        self.dg_contentLabel.attributedText = [(EZDLogSearchResult *)logModel searchAttrStr];
    } else {
        self.dg_contentLabel.text = logModel.abstractString;
    }
    self.typeLabel.text = logModel.tag;
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
