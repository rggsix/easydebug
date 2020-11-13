//
//  EZDMenuViewController.m
//  easydebug_Example
//
//  Created by qingting on 2020/11/13.
//  Copyright © 2020 Song. All rights reserved.
//

#import "EZDMenuViewController.h"

#import "EZDLogListController.h"

#import "EZDMenuViewCollectionViewCell.h"
#import "EZDMenuTitleHeaderView.h"

#import "EZDMenuInfoModel.h"

#import "UIView+EZDAddition_frame.h"

@interface EZDMenuViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) EZDLogger *logger;

@property (nonatomic, strong) NSArray<NSDictionary *> *menuInfos;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation EZDMenuViewController

- (instancetype)initWithLogger:(EZDLogger *)logger {
    if (self = [super init]) {
        self.logger = logger;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.menuInfos = @[
        @{
            @"title":@"Logs",
            @"menu":@[
                    [[EZDMenuInfoModel alloc] initWithTitle:@"Network Log" type:(EZDMenuNetworkLog)],
                    [[EZDMenuInfoModel alloc] initWithTitle:@"Console Log" type:(EZDMenuConsoleLog)],
                    [[EZDMenuInfoModel alloc] initWithTitle:@"AppInfo Log" type:(EZDMenuAppInfoLog)],
                    [[EZDMenuInfoModel alloc] initWithTitle:@"Clear all log" type:(EZDMenuClearalllog)],
        ]},
        
        @{
            @"title":@"APM",
            @"menu":@[
                    [[EZDMenuInfoModel alloc] initWithTitle:@"All APM Info" type:(EZDMenuAllAPMInfo)],
                    
        ]},
        
        @{
            @"title":@"Other",
            @"menu":@[
                    [[EZDMenuInfoModel alloc] initWithTitle:@"Debug options" type:(EZDMenuDebugoptions)],
        ]},
    ];
    
    self.flowLayout = [UICollectionViewFlowLayout new];
    self.flowLayout.itemSize = CGSizeMake(self.view.ezd_width * .4, self.view.ezd_width * .4);
    CGFloat horSecMar = self.view.ezd_width - self.flowLayout.itemSize.width * 2 - 10;
    horSecMar /= 2;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(10, 20, 10, 20);
    self.flowLayout.minimumLineSpacing = 10.f;
    self.flowLayout.minimumLineSpacing = 10.f;
    self.flowLayout.headerReferenceSize = CGSizeMake(self.view.ezd_width, 50);
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    [self.collectionView registerClass:[EZDMenuViewCollectionViewCell class] forCellWithReuseIdentifier:@"EZDMenuViewCollectionViewCell"];
    [self.collectionView registerClass:[EZDMenuTitleHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"EZDMenuTitleHeaderView"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.view addSubview:self.collectionView];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.menuInfos.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray<EZDMenuInfoModel *> *menus = self.menuInfos[section][@"menu"];
    return menus.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.menuInfos[indexPath.section][@"title"];
    EZDMenuTitleHeaderView *header = (EZDMenuTitleHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"EZDMenuTitleHeaderView" forIndexPath:indexPath];
    header.ezd_height = 50;
    header.secTitle = title;
    return header;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EZDMenuViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EZDMenuViewCollectionViewCell" forIndexPath:indexPath];
    NSArray<EZDMenuInfoModel *> *menus = self.menuInfos[indexPath.section][@"menu"];
    cell.model = menus[indexPath.item];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    EZDMenuViewCollectionViewCell *cell = (EZDMenuViewCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    todo : generate sub logger
    switch (cell.model.menuType) {
            //  log
        case EZDMenuNetworkLog:
            [self.navigationController pushViewController:[[EZDLogListController alloc] initWithLogger:_logger] animated:YES];
            break;
        case EZDMenuConsoleLog:
            [self.navigationController pushViewController:[[EZDLogListController alloc] initWithLogger:_logger] animated:YES];
            break;
        case EZDMenuAppInfoLog:
            [self.navigationController pushViewController:[[EZDLogListController alloc] initWithLogger:_logger] animated:YES];
            break;
        case EZDMenuClearalllog:
            [self.logger clearLogs];
            break;
            //  APM
        case EZDMenuAllAPMInfo:

            break;
            //  Other
        case EZDMenuDebugoptions:

            break;
        default:
            break;
    }
}

@end
