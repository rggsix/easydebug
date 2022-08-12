//
//  EZDLogSearchListController.m
//  EasyDebug
//
//  Created by songheng on 2021/1/8.
//

#import "EZDLogSearchListController.h"

#import "EZDLogInfoController.h"

#import "EZDLogAbstractCell.h"

#import "EasyDebugUtil.h"

@interface EZDLogSearchListController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) EZDLogDataSource *dataSource;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation EZDLogSearchListController

- (instancetype)initWithDataSource:(EZDLogDataSource *)dataSource {
    if (self = [super init]) {
        self.dataSource = dataSource;
    }
    return self;
}

- (void)loadView{
    [super loadView];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[EZDLogAbstractCell class] forCellReuseIdentifier:@"DebugLogAbstractCell"];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView reloadData];

    self.navigationItem.title = @"搜索结果";
    
    self.navigationItem.leftItemsSupplementBackButton = YES;
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:(UIBarButtonItemStylePlain) target:self action:@selector(closeItemClicked)];
    self.navigationItem.leftBarButtonItems = [DGNotNullArray(self.navigationItem.leftBarButtonItems) arrayByAddingObject:closeItem];
}

#pragma mark - response func
- (void)closeItemClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.searchLogs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EZDLogAbstractCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DebugLogAbstractCell" forIndexPath:indexPath];
    cell.logModel = self.dataSource.searchLogs[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    EZDLogInfoController *logInfoVC = [[EZDLogInfoController alloc] initWithLogModel:self.dataSource.searchLogs[indexPath.row]];
    [self.navigationController pushViewController:logInfoVC animated:true];
}

@end
