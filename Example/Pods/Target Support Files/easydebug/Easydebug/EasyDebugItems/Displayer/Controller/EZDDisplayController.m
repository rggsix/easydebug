//
//  EZDDisplayController.m
//  HoldCoin
//
//  Created by Song on 2018/9/30.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDDisplayController.h"
#import "EZDBaseLogInfoController.h"
#import "EZDFilterController.h"
#import "EZDOptionsController.h"

#import "EZDLogDisplayCell.h"
#import "EZDMessageHUD.h"

#import "EZDDefine.h"

static NSString * const kEZDDisplayControllerDisplayCellID = @"kEZDDisplayControllerDisplayCellID";

@interface EZDDisplayController ()<UITableViewDelegate,UITableViewDataSource,EZDLoggerDelegate>

@property (strong,nonatomic) EZDLogger *logger;
@property (strong,nonatomic) UITableView *logView;

@end

@implementation EZDDisplayController

- (instancetype)initWithLogger:(EZDLogger *)logger{
    if (self = [super init]) {
        self.logger = logger;
        [self.logger addDelegate:self];
    }
    return self;
}

- (void)loadView{
    [super loadView];
    self.logView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.logView.backgroundColor = [UIColor whiteColor];
    self.logView.delegate = self;
    self.logView.dataSource = self;
    [self.logView registerClass:[EZDLogDisplayCell class] forCellReuseIdentifier:kEZDDisplayControllerDisplayCellID];
    [self.view addSubview:self.logView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSAssert(self.logger != nil, @"EZDDisplayController.logger can't be nil!");
    self.navigationItem.title = @"Logs";
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemCancel) target:self action:@selector(navCancelClicked)];
    UIBarButtonItem *clearItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:(UIBarButtonItemStylePlain) target:self action:@selector(navClearClicked)];
    self.navigationItem.leftBarButtonItems = @[cancelItem,clearItem];
    UIBarButtonItem *filterItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:(UIBarButtonItemStylePlain) target:self action:@selector(navFilterClicked)];
    UIBarButtonItem *optionItem = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:(UIBarButtonItemStylePlain) target:self action:@selector(navOptionsClicked)];
    self.navigationItem.rightBarButtonItems = @[optionItem,filterItem];
}

#pragma mark - response func
- (void)navCancelClicked{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)navFilterClicked{
    EZDFilterController *filterController = [[EZDFilterController alloc] initWithLogger:self.logger ConfirmCallback:^{
        [self.logView reloadData];
    }];
    [self.navigationController pushViewController:filterController animated:true];
}

- (void)navClearClicked{
    [self.logger clearLogs];
}

- (void)navOptionsClicked{
    if (![EZDOptions currentOptionInstance]) {
        [EZDMessageHUD showMessageHUDWithText:@"No EZDOptions instance regiested ! use [Eazydebug regiestOptions:] to rigeist a instance and conform <EZDOptionProtocol> !" type:(EZDImageTypeError)];
        return;
    }
    
    EZDOptionsController *optionVC = [[EZDOptionsController alloc] initWithOptionInstace:[EZDOptions currentOptionInstance]];
    [self.navigationController pushViewController:optionVC animated:true];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.logger.logModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EZDLogDisplayCell *cell = [self.logView dequeueReusableCellWithIdentifier:kEZDDisplayControllerDisplayCellID forIndexPath:indexPath];
    cell.rowOfCell = indexPath.row;
    cell.logModel = self.logger.logModels[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    EZDBaseLogInfoController *logInfoVC = [[EZDBaseLogInfoController alloc] initWithLogModel:self.logger.logModels[indexPath.row]];
    [self.navigationController pushViewController:logInfoVC animated:true];
}

#pragma mark - EZDLoggerDelegate
- (void)logger:(EZDLogger *)logger logsDidChange:(NSArray<EZDLoggerModel *> *)chageLogs{
    [self.logView reloadData];
}

@end
