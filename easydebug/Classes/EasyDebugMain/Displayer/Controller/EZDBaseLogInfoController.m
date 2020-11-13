//
//  EZDBaseLogInfoController.m
//  HoldCoin
//
//  Created by Song on 2018/10/17.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDBaseLogInfoController.h"
#import "EZDLoggerModel.h"
#import "UIView+EZDAddition_frame.h"
#import "EZDDefine.h"
#import "NSObject+EZDAddition.h"
#import "EZDMessageHUD.h"
#import "EZDSystemUtil.h"

@interface EZDBaseLogInfoController ()

@property (strong,nonatomic) EZDLoggerModel *logModel;
@property (copy,nonatomic) NSString *searchingContent;
@property (assign,nonatomic) NSInteger curSearchPos;

@property (strong,nonatomic) NSArray<UIButton *> *itemArr;
@property (strong,nonatomic) NSMutableArray<NSTextCheckingResult *> *searchMatches;
@property (strong,nonatomic) UIButton *lastSelectItem;
@property (strong,nonatomic) UIScrollView *sectionsItemBackView;
@property (strong,nonatomic) UITextField *searchFeild;
@property (strong,nonatomic) UITextView *contentTextView;

@end

@implementation EZDBaseLogInfoController

- (instancetype)initWithLogModel:(EZDLoggerModel *)logModel{
    if (self = [super init]) {
        self.logModel = logModel;
    }
    return self;
}

- (void)loadView{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setupBaseUI{
    self.automaticallyAdjustsScrollViewInsets = false;
    
    UIBarButtonItem *copyItem = [[UIBarButtonItem alloc] initWithTitle:@"Copy" style:(UIBarButtonItemStylePlain) target:self action:@selector(copyItemClicked)];
    self.navigationItem.rightBarButtonItems = @[copyItem];
    
    if (!self.logModel.parameter.allKeys.count) {
        UILabel *noContentLabel = [UILabel new];
        noContentLabel.text = @"No Log Content";
        [noContentLabel sizeToFit];
        [self.view addSubview:noContentLabel];
        return;
    }
    
    self.sectionsItemBackView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, [EZDSystemUtil navigationBarHeight], self.view.ezd_width, 38)];
    self.sectionsItemBackView.showsHorizontalScrollIndicator = false;
    self.sectionsItemBackView.bounces = true;
    __block CGFloat curX = 3;
    CGFloat sectionItemH = self.sectionsItemBackView.ezd_height - 6;
    
    [self.view addSubview:self.sectionsItemBackView];
    
    NSMutableArray<UIButton *> *tmpItems = [NSMutableArray arrayWithCapacity:self.logModel.parameter.allKeys.count+1];
    
   UIButton *totalItem = [self itemWithKey:@"Total data" value:self.logModel.parameter index:0];
    totalItem.backgroundColor = [UIColor blackColor];
    [totalItem setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    self.lastSelectItem = totalItem;
    curX += totalItem.ezd_width + 3;
    [self.sectionsItemBackView addSubview:totalItem];
    [tmpItems addObject:totalItem];
    
    [self.logModel.parameter.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *item = [self itemWithKey:self.logModel.parameter.allKeys[idx] value:obj index:idx+1];
        item.frame = CGRectMake(curX, 3, item.ezd_width + 15, sectionItemH);
        curX += item.ezd_width + 3;
        [self.sectionsItemBackView addSubview:item];
        [tmpItems addObject:item];
    }];
    self.itemArr = [tmpItems copy];
    
    self.sectionsItemBackView.contentSize = CGSizeMake(curX + 3, 0);
    
    UIButton *searchNextButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [searchNextButton setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
    [searchNextButton setTitle:@"Next" forState:(UIControlStateNormal)];
    [searchNextButton addTarget:self action:@selector(searchNextButtonClicked) forControlEvents:(UIControlEventTouchUpInside)];
    searchNextButton.frame = CGRectMake(self.view.ezd_width - 50 - 3, self.sectionsItemBackView.ezd_maxY, 50, 28);
    searchNextButton.layer.cornerRadius = 3;
    searchNextButton.layer.borderWidth = 1;
    searchNextButton.titleLabel.font = kEZDRegularFontSize(14);
    searchNextButton.layer.borderColor = [UIColor grayColor].CGColor;
    searchNextButton.layer.masksToBounds = true;
    
    UIButton *searchPreButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [searchPreButton setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
    [searchPreButton setTitle:@"Pre" forState:(UIControlStateNormal)];
    searchPreButton.frame = CGRectMake(searchNextButton.ezd_x - 50 - 3, self.sectionsItemBackView.ezd_maxY, 50, 28);
    [searchPreButton addTarget:self action:@selector(searchPreButtonClicked) forControlEvents:(UIControlEventTouchUpInside)];
    searchPreButton.layer.cornerRadius = 3;
    searchPreButton.titleLabel.font = kEZDRegularFontSize(14);
    searchPreButton.layer.borderWidth = 1;
    searchPreButton.layer.borderColor = [UIColor grayColor].CGColor;
    searchPreButton.layer.masksToBounds = true;
    
    self.searchFeild = [[UITextField alloc] initWithFrame:CGRectMake(6, self.sectionsItemBackView.ezd_maxY, self.view.ezd_width - 9 - searchNextButton.ezd_width - searchPreButton.ezd_width - 6, 28)];
    self.searchFeild.font = kEZDRegularFontSize(14);
    self.searchFeild.layer.cornerRadius = 4;
    self.searchFeild.layer.masksToBounds = true;
    self.searchFeild.layer.borderColor = [UIColor grayColor].CGColor;
    self.searchFeild.layer.borderWidth = 1;
    self.searchFeild.placeholder = @"Search";
    
    self.contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.searchFeild.ezd_maxY, self.view.ezd_width, self.view.ezd_height - self.searchFeild.ezd_maxY)];
    self.contentTextView.backgroundColor = [UIColor whiteColor];
    self.contentTextView.editable = false;
    self.contentTextView.font = kEZDRegularFontSize(12);
    self.contentTextView.attributedText = [[NSMutableAttributedString alloc] initWithString:[self.logModel.parameter ezd_description]];
    
    [self.view addSubview:self.searchFeild];
    [self.view addSubview:searchNextButton];
    [self.view addSubview:searchPreButton];
    [self.view addSubview:self.contentTextView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = self.logModel.displayTypeName;
    if (!self.navigationItem.title.length) {
        self.navigationItem.title = @"Unknown Log Info";
    }
    
    [self setupBaseUI];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

#pragma mark - UI func
- (void)copyItemClicked{
    UIPasteboard *pbd = [UIPasteboard generalPasteboard];
    pbd.string = self.contentTextView.text;
    [EZDMessageHUD showMessageHUDWithText:@"Copied!" type:(EZDImageTypeCorrect)];
}

- (void)showSearchRollback{
    [EZDMessageHUD showMessageHUDWithText:@"" type:(EZDImageTypeRollback)];
}

- (void)showSearchNotFound{
    [EZDMessageHUD showMessageHUDWithText:@"" type:(EZDImageTypeError)];
}

- (void)setupSearchRects{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:self.contentTextView.attributedText];
    [attr removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, self.contentTextView.attributedText.length)];
    [self.searchMatches removeAllObjects];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.searchFeild.text options:(NSRegularExpressionCaseInsensitive) error:nil];
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:self.contentTextView.text options:0 range:NSMakeRange(0, self.contentTextView.text.length)];
    self.searchMatches = [matches mutableCopy];
    if (!matches.count) {
        [self showSearchNotFound];
        self.searchingContent = @"";
    }
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [attr addAttribute:NSBackgroundColorAttributeName value:[UIColor grayColor] range:obj.range];
    }];
    self.contentTextView.attributedText = attr;
}

- (void)animSearchIndex:(NSInteger)index{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:self.contentTextView.attributedText];
    if (self.curSearchPos >= 0 && self.curSearchPos < self.searchMatches.count) {
        [attr addAttribute:NSBackgroundColorAttributeName value:[UIColor grayColor] range:self.searchMatches[self.curSearchPos].range];
    }
    self.curSearchPos = index;
    [attr addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:self.searchMatches[index].range];
    self.contentTextView.attributedText = attr;
    
    [self.contentTextView scrollRangeToVisible:self.searchMatches[index].range];
}

#pragma mark - private func
- (UIButton *)itemWithKey:(NSString *)key value:(NSDictionary *)value index:(NSInteger)index{
    UIButton *item = [UIButton buttonWithType:(UIButtonTypeCustom)];
    item.backgroundColor = [UIColor whiteColor];
    [item setTitle:key forState:(UIControlStateNormal)];
    [item setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    item.layer.cornerRadius = 4;
    item.layer.masksToBounds = true;
    item.layer.borderColor = [UIColor grayColor].CGColor;
    item.layer.borderWidth = 1;
    item.tag = index;
    [item sizeToFit];
    [item addTarget:self action:@selector(sectionsItemDidClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    return item;
}

///  -1 -> last , 1 -> next
- (void)goSearchPositionWithModify:(NSInteger)moffset{
    if (!self.searchMatches.count) {
        return;
    }
    NSInteger index = self.curSearchPos + moffset;
    if (index >= ((NSInteger)self.searchMatches.count)) {
        index -= self.searchMatches.count;
        [self showSearchRollback];
    }else if (index < 0){
        index = self.searchMatches.count-1;
        [self showSearchRollback];
    }
    [self animSearchIndex:index];
}

#pragma mark - response func
- (void)searchNextButtonClicked{
    if (!self.searchFeild.text.length) return;
    if (![self.searchFeild.text isEqualToString:self.searchingContent]) {
        self.searchingContent = self.searchFeild.text;
        self.curSearchPos = -1;
        [self setupSearchRects];
    }
    
    [self goSearchPositionWithModify:1];
}

- (void)searchPreButtonClicked{
    if (!self.searchFeild.text.length) return;
    if (![self.searchFeild.text isEqualToString:self.searchingContent]) {
        self.searchingContent = self.searchFeild.text;
        self.curSearchPos = 1;
        [self setupSearchRects];
    }
    
    NSInteger offset = -1;
    [self goSearchPositionWithModify:offset];
}

- (void)sectionsItemDidClicked:(UIButton *)item{
    self.searchFeild.text = @"";
    [self.searchMatches removeAllObjects];

    item.backgroundColor = [UIColor blackColor];
    [item setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [self.lastSelectItem setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    self.lastSelectItem.backgroundColor = [UIColor whiteColor];
    self.lastSelectItem = item;
    NSString *baseString = item.tag ? [self.logModel.parameter.allValues[item.tag-1] ezd_description] : [self.logModel.parameter ezd_description];
    self.contentTextView.attributedText = [[NSMutableAttributedString alloc] initWithString:baseString];
    [self.contentTextView scrollsToTop];
    self.curSearchPos = 0;
    self.searchingContent = @"";
}

@end
