//
//  EZDOptionsController.m
//  HoldCoin
//
//  Created by Song on 2018/10/19.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDOptionsController.h"
#import "EZDOptions.h"
#import "EZDOptionsCell.h"
#import "EZDDebugServer.h"
#import "EZDMessageHUD.h"

#import "UIView+EZDAddition_frame.h"

static NSString *kEZDOptionsCellReuseID = @"kEZDOptionsCellReuseID";

#pragma mark -
#pragma mark - EZDOptionsPickerReuseView

@interface EZDOptionsPickerReuseView : UIView
@property (strong,nonatomic) UILabel *contentLabel;
@end

@implementation EZDOptionsPickerReuseView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.contentLabel = [[UILabel alloc] init];
        self.contentLabel.frame = self.bounds;
        self.contentLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.contentLabel];
    }
    return self;
}

@end

@interface EZDOptionsController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@property (strong,nonatomic) EZDOptions *optionObj;

@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) UIPickerView *pickerView;
@property (strong,nonatomic) UIControl *pickerCoverControl;
@property (strong,nonatomic) UIButton *pickerDoneBtn;

@property (strong,nonatomic) NSArray<NSString *> *pickerViewData;
@property (nonatomic, copy) NSString *alertInputValue;

@property (nonatomic, copy) void(^alertConfirmCallBack)(void);
@property (nonatomic, copy) void(^alertCancelCallBack)(void);
@property (nonatomic, copy) void(^pickerSelectCallback)(NSInteger selectIndex);

@end

@implementation EZDOptionsController

- (instancetype)initWithOptionInstace:(EZDOptions *)ins{
    if (self = [super init]) {
        self.optionObj = ins;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupBaseUI];
}

- (void)setupBaseUI{
    self.navigationItem.title = @"Options";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.ezd_width, self.view.ezd_height)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[EZDOptionsCell class] forCellReuseIdentifier:kEZDOptionsCellReuseID];
    
    UIBarButtonItem *serverButton = [[UIBarButtonItem alloc] initWithTitle:@"Server" style:(UIBarButtonItemStylePlain) target:self action:@selector(navServerClicked)];
    self.navigationItem.rightBarButtonItems = @[serverButton];
}

#pragma mark - private func
- (void)showAlertWithMessage:(NSString *)message needInput:(BOOL)need confirm:(void(^)(void))confirmCallBack cancel:(void(^)(void))cancelCallBack{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    if (need) {
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *textfield = [alertView textFieldAtIndex:0];
        textfield.placeholder = @"请输入内容";
    }
    self.alertConfirmCallBack = confirmCallBack;
    self.alertCancelCallBack = cancelCallBack;
    [alertView show];
}

- (void)resetPickerView{
    self.pickerCoverControl.hidden = false;
    self.pickerView.hidden = false;
    self.pickerDoneBtn.hidden = false;
    [self.pickerView reloadAllComponents];
}

- (void)didOperationNormalCellWithCell:(EZDOptionsCell *)cell item:(EZDOptionItem *)item{
    [self.optionObj didOperaionOptionCell:item atRow:cell.indexOfCell callback:^(EZDOptionItem *handledItem) {
        cell.optionItem = handledItem;
    }];
}

- (void)didOperationSwitchCellWithCell:(EZDOptionsCell *)cell item:(EZDOptionItem *)item{
    if ([item isKindOfClass:[EZDOptionSwitchItem class]]) {
        [(EZDOptionSwitchItem *)item setIsOn:!([(EZDOptionSwitchItem *)item isOn])];
        [self.optionObj didOperaionOptionCell:item atRow:cell.indexOfCell callback:^(EZDOptionItem *handledItem) {
            cell.optionItem = handledItem;
        }];
    }
}

- (void)didOperationAlertCellWithCell:(EZDOptionsCell *)cell item:(EZDOptionItem *)item{
    if (![item isKindOfClass:[EZDOptionAlertItem class]]) {
        return;
    }
    EZDOptionAlertItem *alertItem = (EZDOptionAlertItem *)item;
    __weak typeof(self) weakSelf = self;
    [self showAlertWithMessage:alertItem.messageString needInput:alertItem.messageString.length>0 confirm:^{
        alertItem.alertInputString = self.alertInputValue;
        alertItem.isConfirm = true;
        weakSelf.alertInputValue = @"";
        [weakSelf.optionObj didOperaionOptionCell:item atRow:cell.indexOfCell callback:^(EZDOptionItem *handledItem) {
            cell.optionItem = handledItem;
        }];
    } cancel:^{
        alertItem.alertInputString = self.alertInputValue;
        alertItem.isConfirm = false;
        weakSelf.alertInputValue = @"";
        [weakSelf.optionObj didOperaionOptionCell:item atRow:cell.indexOfCell callback:^(EZDOptionItem *handledItem) {
            cell.optionItem = handledItem;
        }];
    }];
}

- (void)didOperationPickerCellWithCell:(EZDOptionsCell *)cell item:(EZDOptionItem *)item{
    if (![item isKindOfClass:[EZDOptionPikerItem class]]) {
        return;
    }
    EZDOptionPikerItem *pickerItem = (EZDOptionPikerItem *)item;
    self.pickerViewData = pickerItem.pickerOptions;
    __weak typeof(self) weakSelf = self;
    self.pickerSelectCallback = ^(NSInteger selectIndex) {
        NSString *result = pickerItem.pickerOptions[selectIndex];
        pickerItem.seletedOption = result;
        [weakSelf.optionObj didOperaionOptionCell:item atRow:cell.indexOfCell callback:^(EZDOptionItem *handledItem) {
            cell.optionItem = handledItem;
        }];
    };
    [self resetPickerView];
}

#pragma mark - response func
- (void)pickerDoneBtnClicked{
    self.pickerCoverControl.hidden = true;
    self.pickerView.hidden = true;
    self.pickerDoneBtn.hidden = true;
    self.pickerSelectCallback ? self.pickerSelectCallback([self.pickerView selectedRowInComponent:0]) : nil;
}

- (void)pickerCoverControlClicked{
    self.pickerCoverControl.hidden = true;
    self.pickerView.hidden = true;
    self.pickerDoneBtn.hidden = true;
}

- (void)navServerClicked {
//    [EZDDebugServer startServerWithPort:9988];
    NSString *urlstr = [EZDDebugServer serverURL];
    [UIPasteboard generalPasteboard].string = urlstr;
    if (urlstr.length) {
        [EZDMessageHUD showMessageHUDWithText:@"Server url copied to pasteboard!" type:(EZDImageTypeCorrect)];
    } else {
        [EZDMessageHUD showMessageHUDWithText:@"Server didn't start!" type:(EZDImageTypeError)];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.optionObj optionItems].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EZDOptionsCell *cell = [tableView dequeueReusableCellWithIdentifier:kEZDOptionsCellReuseID forIndexPath:indexPath];
    cell.indexOfCell = indexPath.row;
    cell.optionItem = [self.optionObj optionItems][indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EZDOptionItem *item = [self.optionObj optionItems][indexPath.row];
    EZDOptionsCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    switch (item.itemType) {
        case EZDOperationItemTypeNormal:
            [self didOperationNormalCellWithCell:cell item:item];
            break;
        case EZDOperationItemTypeSwitch:
            [self didOperationSwitchCellWithCell:cell item:item];
            break;
        case EZDOperationItemTypeAlert:
            [self didOperationAlertCellWithCell:cell item:item];
            break;
        case EZDOperationItemTypePicker:
            [self didOperationPickerCellWithCell:cell item:item];
            break;
        default:
            break;
    }
}

#pragma mark - picker view datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.pickerViewData.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 20;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    if (!view) {
        view = [[EZDOptionsPickerReuseView alloc] initWithFrame:CGRectMake(0, pickerView.ezd_width, pickerView.ezd_width, 20)];
    }
    [(EZDOptionsPickerReuseView *)view contentLabel].text = self.pickerViewData[row];
    return view;
}

#pragma mark - UIAlertViewDelegate
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView textFieldAtIndex:0]) {
        self.alertInputValue = [alertView textFieldAtIndex:0].text;
    }
    
    if (buttonIndex) {
        self.alertConfirmCallBack ? self.alertConfirmCallBack() : nil;
    } else{
        self.alertCancelCallBack ? self.alertCancelCallBack() : nil;
    }
}
#pragma clang diagnostic pop

#pragma mark - lazy load
- (UIPickerView *)pickerView{
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.ezd_height-162, self.view.ezd_width, 162)];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_pickerView];
        
        self.pickerDoneBtn = [[UIButton alloc] init];
        [self.pickerDoneBtn setTitle:@"Done" forState:(UIControlStateNormal)];
        [self.pickerDoneBtn sizeToFit];
        self.pickerDoneBtn.ezd_width *= 1.5;
        self.pickerDoneBtn.ezd_y = _pickerView.ezd_y + 5;
        self.pickerDoneBtn.ezd_maxX = _pickerView.ezd_width - 5;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerDoneBtnClicked)];
        [self.pickerDoneBtn addGestureRecognizer:tapGes];
        [self.pickerDoneBtn setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
        [self.view addSubview:self.pickerDoneBtn];
        
        self.pickerCoverControl = [[UIControl alloc] initWithFrame:self.view.bounds];
        self.pickerCoverControl.backgroundColor = [UIColor clearColor];
        [self.view insertSubview:self.pickerCoverControl belowSubview:_pickerView];
        [self.pickerCoverControl addTarget:self action:@selector(pickerCoverControlClicked) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _pickerView;
}


@end
