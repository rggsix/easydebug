//
//  EZDLogListController.m
//  EasyDebug
//
//  Created by songheng on 2020/11/25.
//

#import "EZDLogListController.h"

#import "EZDLogInfoController.h"
#import "EZDTagListSelectController.h"
#import "EZDLogSearchListController.h"

#import "EZDLogAbstractCell.h"
#import "JMLogRecentSearchView.h"

#import "EZDLogDataSource.h"
#import "EasyDebugUtil.h"
#import "DebugCoreCategorys.h"

static NSString * const kDebugDisplayCellID = @"kDebugDisplayCellID";
static NSString * const kJMLastLogListFilterTag = @"kJMLastLogListFilterTag";

@interface EZDLogListController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) EZDLogDataSource *dataSource;

@property (nonatomic, strong) UIBarButtonItem *byTagItem;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (strong,nonatomic) UITableView *tableView;
@property (nonatomic, strong) JMLogRecentSearchView *recentSearchView;

@end

@implementation EZDLogListController

- (instancetype)initWithOnceStart:(EZDOnceStart *)onceStart{
    if (self = [super init]) {
        if (@available(iOS 13.0, *)) {
            self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        }
        
        //  读取log数据
        [onceStart queryLogModelsIfNeed];
        self.dataSource = [[EZDLogDataSource alloc] initWithLogs:onceStart.originLogs];
        NSString *lastTag = [[NSUserDefaults standardUserDefaults] stringForKey:kJMLastLogListFilterTag];
        if (DGIsNotNull(lastTag)) {
            [self.dataSource filterLogsWithTag:lastTag];
        }
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
    [self.tableView registerClass:[EZDLogAbstractCell class] forCellReuseIdentifier:kDebugDisplayCellID];
    [self.view addSubview:self.tableView];
    
    self.recentSearchView = [[JMLogRecentSearchView alloc] initWithFrame:CGRectMake(0, 0, self.view.dg_width, 44)];
    __weak typeof(self) selfWeak = self;
    self.recentSearchView.recentClicked = ^(NSString *text) {
        [selfWeak searchWithText:text];
    };
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.dg_width, 44)];
    self.searchBar.searchBarStyle = UISearchBarStyleDefault;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.delegate = self;
    self.searchBar.inputAccessoryView = self.recentSearchView;
    self.tableView.tableHeaderView = self.searchBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView reloadData];

    self.navigationItem.title = @"日志";
    
    self.navigationItem.leftItemsSupplementBackButton = YES;
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:(UIBarButtonItemStylePlain) target:self action:@selector(closeItemClicked)];
    self.navigationItem.leftBarButtonItems = [DGNotNullArray(self.navigationItem.leftBarButtonItems) arrayByAddingObject:closeItem];

    self.byTagItem = [[UIBarButtonItem alloc] initWithTitle:@"筛选" style:(UIBarButtonItemStylePlain) target:self action:@selector(navByTagClicked)];
    self.navigationItem.rightBarButtonItems = @[self.byTagItem];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BOOL isHasFilterTag = DGIsNotNull([[NSUserDefaults standardUserDefaults] stringForKey:kJMLastLogListFilterTag]);
    self.byTagItem.title = isHasFilterTag ? @"筛选(✅)" : @"筛选";
    self.byTagItem.tintColor = isHasFilterTag ? [UIColor systemGreenColor] : [UIColor systemBlueColor];
}

#pragma mark - private func
- (void)searchWithText:(NSString *)searchText {
    self.searchBar.text = @"";
    [self.searchBar endEditing:YES];
    
    [self.dataSource searchLogsWithKey:searchText];
    EZDLogSearchListController *searchVC = [[EZDLogSearchListController alloc] initWithDataSource:self.dataSource];
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark - response func
- (void)closeItemClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)navByTagClicked{
    __weak typeof(self) weakSelf = self;
    EZDTagListSelectController *tagVC = [[EZDTagListSelectController alloc] initWithTags:self.dataSource.tags callback:^(NSString * _Nonnull tag) {
        [[NSUserDefaults standardUserDefaults] setObject:tag forKey:kJMLastLogListFilterTag];
        [weakSelf.dataSource filterLogsWithTag:tag];
        [weakSelf.tableView reloadData];
        [weakSelf.tableView scrollsToTop];
    }];
    [self.navigationController pushViewController:tagVC animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.logs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EZDLogAbstractCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kDebugDisplayCellID forIndexPath:indexPath];
    cell.logModel = self.dataSource.logs[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    EZDLogInfoController *logInfoVC = [[EZDLogInfoController alloc] initWithLogModel:self.dataSource.logs[indexPath.row]];
    [self.navigationController pushViewController:logInfoVC animated:true];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchText = searchBar.text;
    if (!DGIsNotNull(searchText)) {
        return;
    }

    //  记录最近搜索
    [self.recentSearchView recordSearch:searchText];
    //  搜索
    [self searchWithText:searchText];
}

@end
