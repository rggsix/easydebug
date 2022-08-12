//
//  EZDDisplayer.m
//  EasyDebug
//
//  Created by songheng on 2020/11/25.
//

#import "EZDDisplayer.h"

#import "EZDStartupListController.h"

#import "EasyDebugUtil.h"
#import "EasyDebug.h"

#import "DebugCoreCategorys.h"

@interface EZDDisplayer ()

@property (nonatomic, strong) UIButton *consoleEntryBtn;

@property (nonatomic, strong) UIImage *icon;

@property (nonatomic, strong) NSTimer *entrySetupTimer;

@end

@implementation EZDDisplayer

+ (instancetype)shared {
    static EZDDisplayer *displayer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        displayer = [[self alloc] init];
    });
    return displayer;
}

- (void)start {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupBaseUIIfNeed];
        self.consoleEntryBtn.hidden = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardChange:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
    });
}

- (void)stop {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.consoleEntryBtn.hidden = YES;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    });
}

#pragma mark - private
///  将 Log 入口添加到 Window 上, 或 bringToFront
- (void)beginAddWindowLoop {
    self.entrySetupTimer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
            return;
        }
        
        UIWindow *window = [EasyDebugUtil currentWindow];
        if (window && (self.consoleEntryBtn.window != window)) {
            [self.consoleEntryBtn removeFromSuperview];
            [window addSubview:self.consoleEntryBtn];

            self.consoleEntryBtn.dg_origin = CGPointMake(window.dg_width * .06,
                                                         window.dg_height - self.consoleEntryBtn.dg_height * .4);
        } else {
            [window bringSubviewToFront:self.consoleEntryBtn];
        }
    }];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupBaseUIIfNeed{
    if (self.consoleEntryBtn) {
        return;
    }
    self.consoleEntryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.consoleEntryBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.consoleEntryBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    self.consoleEntryBtn.contentHorizontalAlignment = UIControlContentVerticalAlignmentFill;
    
    [self.consoleEntryBtn setImage:[EasyDebugUtil imageNamed:@"debug_entry_icon"] forState:UIControlStateNormal];
    [self.consoleEntryBtn addTarget:self action:@selector(displayerSwitchClicked) forControlEvents:UIControlEventTouchUpInside];
    self.consoleEntryBtn.dg_size = CGSizeMake(60, 60);
    
    [self beginAddWindowLoop];
}

#pragma mark - private funcs
- (void)showStartupListController{
    EZDStartupListController *displayController = [EZDStartupListController new];
    [UIViewController dg_presentController:displayController
                                   needNav:true];
}

#pragma mark - response funcs
- (void)displayerSwitchClicked{
    //  一个弹出的动画，第一次点击按钮会弹出来，但是不会进log页面，再次点击才会进log，防止误触
    static BOOL comeOut = false;
    if (!comeOut) {
        comeOut = true;
        [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.consoleEntryBtn.dg_y -= self.consoleEntryBtn.dg_height * .6;
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.25 animations:^{
                    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
                    CGFloat targetY = self.consoleEntryBtn.dg_y + self.consoleEntryBtn.dg_height * .6;
                    if (targetY < screenH) {
                        self.consoleEntryBtn.dg_y = targetY;
                    } else {
                        self.consoleEntryBtn.dg_y = screenH - self.consoleEntryBtn.dg_height * .6;
                    }
                } completion:^(BOOL finished) {
                    comeOut = false;
                }];
            });
        }];
    }else{
        [self showStartupListController];
    }
}

- (void)keyboardChange:(NSNotification *)note{
    CGRect frame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    if ((frame.size.height > 0) && frame.origin.y < screenH) {
        self.consoleEntryBtn.dg_y = frame.origin.y - 40;
    } else {
        self.consoleEntryBtn.dg_y = screenH - self.consoleEntryBtn.dg_height * .4;
    }
}

@end
