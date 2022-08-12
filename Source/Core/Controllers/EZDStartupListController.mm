//
//  EZDStartupListController.m
//  EasyDebug
//
//  Created by songheng on 2020/11/27.
//

#import "EZDStartupListController.h"

#import "EZDLogDay.h"

#import "EZDLogManager.h"
#import "EZDOnceStart.h"
#import "EasyDebug.h"
#import "EasyDebugUtil.h"
#import "EZDLogListController.h"


@interface EZDStartupListController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<EZDLogDay *> *days;

@end

@implementation EZDStartupListController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        if (@available(iOS 13.0, *)) {
            self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        } 
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    
    [EZDLogManager.shared loadLogDayList:^(NSArray<EZDLogDay *> * _Nonnull logDays) {
        self.days = logDays;
        [self.tableView reloadData];
    }];
}

- (void)setupUI {
    self.navigationItem.leftItemsSupplementBackButton = YES;
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:(UIBarButtonItemStylePlain) target:self action:@selector(closeItemClicked)];
    self.navigationItem.leftBarButtonItems = [DGNotNullArray(self.navigationItem.leftBarButtonItems) arrayByAddingObject:closeItem];
    
    UIBarButtonItem *clearItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:(UIBarButtonItemStylePlain) target:self action:@selector(clearAllLogs)];
    self.navigationItem.rightBarButtonItem = clearItem;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"UITableViewHeaderFooterView"];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.days.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.days[section].starts.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.days[section].dateString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    EZDOnceStart *start = self.days[indexPath.section].starts[indexPath.row];
    NSString *text = start.dateString;
    UIColor *color = UIColor.blackColor;
    if (start.isCurrentStartup) {
        color = UIColor.systemBlueColor;
        text = [text stringByAppendingString:@" (本次启动)"];
    }
    
    cell.textLabel.text = text;
    cell.textLabel.textColor = color;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EZDOnceStart *start = self.days[indexPath.section].starts[indexPath.row];

    EZDLogListController *vc = [[EZDLogListController alloc] initWithOnceStart:start];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete){
        EZDOnceStart *start = self.days[indexPath.section].starts[indexPath.row];
        
        [EZDLogManager.shared deleteStart:start complete:^{
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationLeft)];
        }];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark - response func
- (void)closeItemClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clearAllLogs {
    //  清空历史的
    [EZDLogManager.shared deleteAllStarts:^{
        [self.tableView reloadData];
    }];
}

@end
