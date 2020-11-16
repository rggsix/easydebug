//
//  EZDFilterController.m
//  HoldCoin
//
//  Created by Song on 2018/10/19.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDFilterController.h"
#import "EZDLogger.h"
#import "EZDFilter.h"
#import "EZDDefine.h"
#import "UIView+EZDAddition_frame.h"

@interface EZDFilterController ()

@property (copy,nonatomic) void(^confirmCallback)(void);
@property (strong,nonatomic) EZDLogger *logger;
@property (strong,nonatomic) UIScrollView *scrollV;
@property (strong,nonatomic) UITextField *inputField;
@property (strong,nonatomic) NSArray<UIButton *> *typeNameItems;

@end

@implementation EZDFilterController

- (instancetype)initWithLogger:(EZDLogger *)logger ConfirmCallback:(void (^)(void))confirmCallback{
    if (self = [super init]) {
        self.logger = logger;
        self.confirmCallback = confirmCallback;
    }
    return self;
}

- (void)loadView{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Filter";
    UIBarButtonItem *clearFilterItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:(UIBarButtonItemStylePlain) target:self action:@selector(navClearClicked)];
    UIBarButtonItem *saveFilterItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemSave) target:self action:@selector(navSaveClicked)];
    self.navigationItem.rightBarButtonItems = @[saveFilterItem,clearFilterItem];
    
    [self setupBaseUI];
}

- (void)setupBaseUI{
    NSMutableArray<UIButton *> *tmpBtnArr = [[NSMutableArray alloc] initWithCapacity:[EZDFilter typeNames].count];
    
    self.scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.ezd_width, self.view.ezd_height)];
    self.scrollV.showsVerticalScrollIndicator = false;
    
    CGFloat btnW = self.view.ezd_width - 36;
    self.inputField = [[UITextField alloc] initWithFrame:CGRectMake(18, 18, btnW, 24)];
    self.inputField.borderStyle = UITextBorderStyleRoundedRect;
    
    __block CGFloat maxY = self.inputField.ezd_maxY;
    
    [self.view addSubview:self.scrollV];
    [self.scrollV addSubview:self.inputField];
    
    //  If which filter item not contain in typeNames, it is from user input.
    [[self.logger.filterItem filterItems] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![[EZDFilter typeNames] containsObject:obj]) {
            self.inputField.text = obj;
            self.inputField.placeholder = obj;
            return;
        }
    }];
    
    [[EZDFilter typeNames] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {        
        UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [btn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        [btn setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected)];
        btn.selected = [[self.logger.filterItem filterItems] containsObject:obj];
        btn.backgroundColor = btn.selected ? [UIColor blackColor] : [UIColor whiteColor];
        btn.layer.cornerRadius = 4;
        btn.layer.masksToBounds = true;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [UIColor grayColor].CGColor;
        [btn addTarget:self action:@selector(typeNameBtnClicked:) forControlEvents:(UIControlEventTouchUpInside)];

        btn.frame = CGRectMake(18, maxY + 18, btnW, 24);
        NSString *title = obj;
        if (!title.length) {
            title = obj;
        }
        [btn setTitle:title forState:(UIControlStateNormal)];
        [btn setTitle:obj forState:(UIControlStateDisabled)];
        [self.scrollV addSubview:btn];
        maxY = btn.ezd_maxY;
        
        [tmpBtnArr addObject:btn];
    }];
    
    self.typeNameItems = tmpBtnArr;
    self.scrollV.contentSize = CGSizeMake(0, maxY + 18);
}

#pragma mark - response func
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:true];
}

- (void)navClearClicked{
    [self.logger.filterItem removeAllFilterItems];
    [self.logger updateLogModelsWithFilter];
    
    [self.navigationController popViewControllerAnimated:true];
    self.confirmCallback ? self.confirmCallback() : nil;
}

- (void)navSaveClicked{
    [self.logger.filterItem removeAllFilterItems];
    [self.typeNameItems enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.selected) {
            [self.logger.filterItem addFilterItemsObject:[obj titleForState:(UIControlStateDisabled)]];
        }
    }];
    [self.logger.filterItem addFilterItemsObject:self.inputField.text];
    
    [self.navigationController popViewControllerAnimated:true];
    
    [self.logger updateLogModelsWithFilter];
    
    self.confirmCallback ? self.confirmCallback() : nil;
}

- (void)typeNameBtnClicked:(UIButton *)typeNameBtn{
    if (typeNameBtn.selected) {
        typeNameBtn.selected = false;
        typeNameBtn.backgroundColor = [UIColor whiteColor];
        [self.logger.filterItem removeFilterItemsObject:[typeNameBtn titleForState:(UIControlStateDisabled)]];
    }else{
        typeNameBtn.selected = true;
        typeNameBtn.backgroundColor = [UIColor blackColor];
        [self.logger.filterItem addFilterItemsObject:[typeNameBtn titleForState:(UIControlStateDisabled)]];
    }
}

@end
