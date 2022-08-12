//
//  JMLogRecentSearchView.m
//  JMLog
//
//  Created by SonG on 2022/6/30.
//

#import "JMLogRecentSearchView.h"

#import "EasyDebugUtil.h"
#import "DebugCoreCategorys.h"

@implementation JMLogRecentSearchView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"JMLogRecentSearchView"];
        [self addSubview:self.collectionView];
        
        self.recentSearchs = DGNotNullArray([[NSUserDefaults standardUserDefaults] objectForKey:kJMRecentSearchUDK]);
        [self.collectionView reloadData];
    }
    return self;
}

- (void)reload {
    self.recentSearchs = DGNotNullArray([[NSUserDefaults standardUserDefaults] objectForKey:kJMRecentSearchUDK]);
    [self.collectionView reloadData];
}

- (void)recordSearch:(NSString *)searchText {
    NSMutableArray<NSString *> *recents = [DGNotNullArray([[NSUserDefaults standardUserDefaults] objectForKey:kJMRecentSearchUDK]) mutableCopy];
    [recents insertObject:searchText atIndex:0];
    if (recents.count > 10) {
        recents = [[recents subarrayWithRange:NSMakeRange(0, 10)] mutableCopy];
    }
    [[NSUserDefaults standardUserDefaults] setObject:recents forKey:kJMRecentSearchUDK];
    
    [self reload];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recentSearchs.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JMLogRecentSearchView" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    cell.contentView.layer.cornerRadius = 6;
    UILabel *titleLabel = [cell.contentView viewWithTag:65534] ?: [UILabel new];
    titleLabel.tag = 65534;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.text = self.recentSearchs[indexPath.item];
    [titleLabel sizeToFit];
    titleLabel.center = cell.contentView.center;
    titleLabel.dg_x = 10.f;
    [cell.contentView addSubview:titleLabel];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.recentClicked ? self.recentClicked(self.recentSearchs[indexPath.item]) : nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [self.recentSearchs[indexPath.item] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30)
                                                                   options:0
                                                                attributes:nil
                                                                   context:nil].size;
    return CGSizeMake(size.width + 20, 30);
}

@end
