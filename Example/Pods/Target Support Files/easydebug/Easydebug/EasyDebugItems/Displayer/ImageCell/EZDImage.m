//
//  EZDBaseImage.m
//  HoldCoin
//
//  Created by Song on 2018/10/18.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDImage.h"

@interface EZDImage()

@property (strong,nonatomic) NSMutableDictionary<NSNumber *,UIImage *> *images;

@end

@implementation EZDImage

+ (instancetype)shareIns{
    static EZDImage *ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[EZDImage alloc] init];
    });
    return ins;
}

+ (UIImage *)imageWithType:(EZDImageType)type{
    EZDImage *ins = [self shareIns];
    UIImage *image = [ins images][@(type)];
    if (!image) {
        image = [self createImageWithType:type];
    }
    return image;
}

+ (UIImage *)createImageWithType:(EZDImageType)type{
    UIImage *resultImage = nil;
    CGFloat width = [UIScreen mainScreen].bounds.size.width*.5;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, width), 0, 1);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    switch (type) {
        case EZDImageTypeError:
            resultImage = [self errorImageWithContext:ctx w:width h:width];
            break;
        case EZDImageTypeRollback:
            resultImage = [self rollbackImageWithContext:ctx w:width h:width];
            break;
        case EZDImageTypeCorrect:
            resultImage = [self correctImageWithContext:ctx w:width h:width];
        default:
            break;
    }
    UIGraphicsEndImageContext();
    return resultImage;
}

+ (UIImage *)errorImageWithContext:(CGContextRef)ctx w:(CGFloat)w h:(CGFloat)h{
    CGContextSetLineWidth(ctx, 10);
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextMoveToPoint(ctx, w*.1, h*.1);
    CGContextAddLineToPoint(ctx, w*.9, h*.9);
    CGContextMoveToPoint(ctx, w*.9, h*.1);
    CGContextAddLineToPoint(ctx, w*.1, h*.9);
    CGContextStrokePath(ctx);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    EZDImage *ins = [self shareIns];
    [[ins images] setObject:img forKey:@(EZDImageTypeError)];
    return img;
}

+ (UIImage *)rollbackImageWithContext:(CGContextRef)ctx w:(CGFloat)w h:(CGFloat)h{
    CGContextSetLineWidth(ctx, 10);
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextMoveToPoint(ctx, w*.2, h*.2);
    CGContextAddLineToPoint(ctx, w*.2, h*.8);
    CGContextAddLineToPoint(ctx, w*.8, h*.8);
    CGContextAddLineToPoint(ctx, w*.8, h*.2);
    CGContextMoveToPoint(ctx, w*.65, h*.3);
    CGContextAddLineToPoint(ctx, w*.8, h*.2);
    CGContextAddLineToPoint(ctx, w*.95, h*.3);
    CGContextStrokePath(ctx);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    EZDImage *ins = [self shareIns];
    [[ins images] setObject:img forKey:@(EZDImageTypeError)];
    return img;
}

+ (UIImage *)correctImageWithContext:(CGContextRef)ctx w:(CGFloat)w h:(CGFloat)h{
    CGContextSetLineWidth(ctx, 10);
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextMoveToPoint(ctx, w*.2, h*.6);
    CGContextAddLineToPoint(ctx, w*.4, h*.85);
    CGContextAddLineToPoint(ctx, w*.85, h*.2);
    CGContextStrokePath(ctx);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    EZDImage *ins = [self shareIns];
    [[ins images] setObject:img forKey:@(EZDImageTypeError)];
    return img;
}

@end
