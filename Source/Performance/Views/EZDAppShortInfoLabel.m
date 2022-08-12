//
//  EZDAppShortInfoLabel.m
//  EasyDebug
//
//  Created by songheng on 2020/11/25.
//

#import "EZDAppShortInfoLabel.h"
#import "EasyDebug.h"
#import "EasyDebugUtil.h"

#define kDebugAppShortInfoLabelSize CGSizeMake(90, 54)

@interface EZDAppShortInfoLabel()

@end

@implementation EZDAppShortInfoLabel

#pragma mark - life circle
- (instancetype)initWithFrame:(CGRect)frame {
    frame.size = kDebugAppShortInfoLabelSize;
    
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 5;
        self.numberOfLines = 3;
        self.clipsToBounds = YES;
        self.textAlignment = NSTextAlignmentLeft;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.700];
        self.textColor = [UIColor whiteColor];
        self.alpha = .6;
        
        UIFont *font = [UIFont fontWithName:@"Menlo" size:14];
        if (!font) {
            font = [UIFont fontWithName:@"Courier" size:14];
        }
        self.font = font;
    }
    return self;
}

- (void)updateWithFPS:(uint)fps cpu:(uint)cpu mem:(uint)mem {
    if (!self.superview) {
        //  等主线程忙完再加label
        dispatch_async(dispatch_get_main_queue(), ^{
            [[EasyDebugUtil currentWindow] addSubview:self];
        });
    }
    
    NSUInteger len_f = [NSString stringWithFormat:@"%d", fps].length;
    NSUInteger len_c = [NSString stringWithFormat:@"%d", cpu].length;
    NSUInteger len_m = [NSString stringWithFormat:@"%d", mem].length;
    CGFloat progress = fps / 60.0;
    
    UIColor *color1 = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1];
    UIColor *color2 = [UIColor colorWithHue:0.27 * ((200-cpu)*.005 - 0.2) saturation:1 brightness:0.9 alpha:1];
    UIColor *color3 = [UIColor colorWithHue:0.27 * ((500-mem)*.002 - 0.2) saturation:1 brightness:0.9 alpha:1];
    
    NSMutableAttributedString *text = nil;
    text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" FPS : %d\n CPU : %d\n MEM : %d",fps, cpu, mem]];
    
    NSInteger textIndex = 7;// " FPS : ".length == 7
    
    [text addAttribute:NSForegroundColorAttributeName value:color1 range:NSMakeRange(textIndex, len_f)];
    textIndex = textIndex + len_f + 1; // 空格、 换行符占1
    
    [text addAttribute:NSForegroundColorAttributeName value:color2 range:NSMakeRange(textIndex + 7, len_c)];
    textIndex = textIndex + 7 + len_c + 1; // 空格、 换行符占1
    
    [text addAttribute:NSForegroundColorAttributeName value:color3 range:NSMakeRange(textIndex + 6, len_m)];
    textIndex = textIndex + 6 + len_m + 1; // 空格、 换行符占1
    
    self.attributedText = text;
}

@end
