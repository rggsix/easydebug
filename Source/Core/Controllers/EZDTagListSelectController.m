//
//  EZDTagListSelectController.m
//  EasyDebug
//
//  Created by songheng on 2020/11/30.
//

#import "EZDTagListSelectController.h"

#import "EZDLogListController.h"

#import "EasyDebugUtil.h"

#import "EZDLogDataSource.h"

@interface EZDTagListSelectController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray<NSString *> *tags;
@property (nonatomic, copy) void (^callback)(NSString *tag);

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation EZDTagListSelectController

- (instancetype)initWithTags:(NSArray<NSString *> *)tags callback:(void (^)(NSString * _Nonnull))callback {
    if (self = [super init]) {
        NSArray<NSString *> *alltags = [tags sortedArrayUsingSelector:@selector(compare:)];
        self.tags = [@[@"所有日志", @"无tag日志"] arrayByAddingObjectsFromArray:alltags];
        self.callback = callback;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}

- (void)setupUI {
    self.navigationItem.leftItemsSupplementBackButton = YES;
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:(UIBarButtonItemStylePlain) target:self action:@selector(closeItemClicked)];
    self.navigationItem.leftBarButtonItems = [DGNotNullArray(self.navigationItem.leftBarButtonItems) arrayByAddingObject:closeItem];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

#pragma mark - respond func
- (void)closeItemClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = self.tags[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tag;
    if (indexPath.row == 0) {
        tag = @"";
    } else if (indexPath.row == 1) {
        tag = kDebugNoTagKey;
    } else {
        tag = self.tags[indexPath.row];
    }
    self.callback ? self.callback(tag) : nil;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
