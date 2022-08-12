//
//  JMLogRecentSearchView.h
//  JMLog
//
//  Created by SonG on 2022/6/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const kJMRecentSearchUDK = @"kJMRecentSearchUDK";

@interface JMLogRecentSearchView : UIView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray<NSString *> *recentSearchs;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) void (^recentClicked)(NSString *text);

- (void)reload;

- (void)recordSearch:(NSString *)searchText;

@end

NS_ASSUME_NONNULL_END
