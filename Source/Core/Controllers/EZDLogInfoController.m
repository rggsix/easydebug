//
//  EZDLogInfoController.m
//  EasyDebug
//
//  Created by songheng on 2020/11/25.
//

#import "EZDLogInfoController.h"

#import <SafariServices/SafariServices.h>

#import "EZDLogModel.h"
#import "DebugCoreCategorys.h"
#import "EasyDebugUtil.h"

#import "JMLogRecentSearchView.h"

@interface EZDLogInfoController () <UISearchBarDelegate, UITextViewDelegate>

@property (strong,nonatomic) EZDLogModel *logModel;

@property (strong,nonatomic) UITextView *contentTextView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) JMLogRecentSearchView *recentSearchView;

@property (nonatomic, strong, nullable) NSTextCheckingResult *searchResult;

@end

@implementation EZDLogInfoController

- (instancetype)initWithLogModel:(EZDLogModel *)logModel{
    if (self = [super init]) {
        if (@available(iOS 13.0, *)) {
            self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        }
        self.logModel = logModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNav];
    [self setupUI];
}

- (void)setupNav {
    //  双行title
    if (self.logModel.tag.length) {
        NSString *dateStr = [NSDate dateWithTimeIntervalSince1970:self.logModel.timeStamp].dg_stringWithISOFormat;
        NSString *title = [NSString stringWithFormat:@"%@\n%@", self.logModel.tag,dateStr];
        NSRange dateStrRange = [title rangeOfString:dateStr];
        NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title];
        [attrTitle setAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor], NSFontAttributeName:[UIFont systemFontOfSize:12]} range:dateStrRange];
        UILabel *titleLb = [[UILabel alloc] init];
        titleLb.attributedText = attrTitle;
        titleLb.textAlignment = NSTextAlignmentCenter;
        titleLb.numberOfLines = 2;
        [titleLb sizeToFit];
        self.navigationItem.titleView = titleLb;
    }
    
    //  关闭按钮
    self.navigationItem.leftItemsSupplementBackButton = YES;
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:(UIBarButtonItemStylePlain) target:self action:@selector(closeItemClicked)];
    self.navigationItem.leftBarButtonItems = [DGNotNullArray(self.navigationItem.leftBarButtonItems) arrayByAddingObject:closeItem];
    //  copy按钮
    self.automaticallyAdjustsScrollViewInsets = false;
    UIBarButtonItem *copyItem = [[UIBarButtonItem alloc] initWithTitle:@"复制" style:(UIBarButtonItemStylePlain) target:self action:@selector(copyItemClicked)];
    //  分享按钮
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:(UIBarButtonItemStylePlain) target:self action:@selector(shareItemClicked)];
    self.navigationItem.rightBarButtonItems = @[copyItem, shareItem];
}

- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (!self.logModel.contentDic.allKeys.count) {
        UILabel *noContentLabel = [UILabel new];
        noContentLabel.text = @"No Log Content";
        [noContentLabel sizeToFit];
        [self.view addSubview:noContentLabel];
        return;
    }
    
    self.contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, kJMNavigationBarHeight + kJMStatusBarHeight + 101, self.view.dg_width, self.view.dg_height - kJMNavigationBarHeight - kJMStatusBarHeight - kJMSafeAreaTop - 100)];
    self.contentTextView.backgroundColor = [UIColor whiteColor];
    self.contentTextView.editable = false;
    self.contentTextView.font = [UIFont systemFontOfSize:14];
    self.contentTextView.textContainerInset = UIEdgeInsetsMake(0, 6, 0, 6);
    self.contentTextView.showsVerticalScrollIndicator = YES;
    self.contentTextView.layer.borderWidth = 1.5;
    self.contentTextView.layer.cornerRadius = 4;
    self.contentTextView.layer.borderColor = [UIColor darkTextColor].CGColor;
    self.contentTextView.layer.masksToBounds = YES;
    self.contentTextView.delegate = self;
    
    self.contentTextView.attributedText = [self attributedTextForLog];
    
    self.recentSearchView = [[JMLogRecentSearchView alloc] initWithFrame:CGRectMake(0, 0, self.view.dg_width, 44)];
    __weak typeof(self) selfWeak = self;
    self.recentSearchView.recentClicked = ^(NSString *text) {
        [selfWeak searchWithText:text isNext:YES];
    };
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, kJMNavigationBarHeight + kJMStatusBarHeight, self.view.dg_width, 100)];
    self.searchBar.searchBarStyle = UISearchBarStyleDefault;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.delegate = self;
    self.searchBar.scopeButtonTitles = @[@"上一个", @"EasyDebug", @"下一个"];
    self.searchBar.showsScopeBar = YES;
    self.searchBar.selectedScopeButtonIndex = 1;
    self.searchBar.inputAccessoryView = self.recentSearchView;
    [self.searchBar sizeToFit];
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.contentTextView];
}

#pragma mark - Respond func
- (void)copyItemClicked{
    UIPasteboard *pbd = [UIPasteboard generalPasteboard];
    pbd.string = [self genStrinContent];
}

- (void)shareItemClicked {
    NSArray<NSString *> *items = @[
        [self genStrinContent]
    ];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    // iPad上的处理
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        activityVC.popoverPresentationController.sourceView = self.view; // 或者指定某个按钮/视图
        activityVC.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2, 1, 1); // 设置弹出框的位置和大小
    }
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)closeItemClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private func
- (void)searchWithText:(NSString *)searchText isNext:(BOOL)isNext {
    self.searchBar.text = searchText;
    [self.searchBar endEditing:YES];
    [self.contentTextView becomeFirstResponder];
    
    NSString *contentText = self.contentTextView.attributedText.string;
    
    NSRegularExpression *re = [[NSRegularExpression alloc] initWithPattern:searchText options:(NSRegularExpressionCaseInsensitive | NSRegularExpressionAllowCommentsAndWhitespace) error:nil];
    NSArray<NSTextCheckingResult *> *matchResults = [re matchesInString:contentText
                                                                options:NSMatchingReportCompletion | NSMatchingWithTransparentBounds
                                                                  range:NSMakeRange(0, contentText.length)];

    //  检查是不是正在搜索这个词
    if (self.searchResult != nil) {
        //  清空之前的搜索词高亮
        [self.contentTextView setSelectedRange:NSMakeRange(NSNotFound, 0)];
        
        BOOL isSameSearch = NO;
        for (NSTextCheckingResult *result in matchResults) {
            if (NSEqualRanges(result.range, self.searchResult.range) == NO) continue;
            
            isSameSearch = YES;
            break;
        }
        //  如果要搜索新词, 清空当前 searchResult
        self.searchResult = isSameSearch ? self.searchResult : nil;
    }
    
    //  新搜索, 直接返回第一个
    if (self.searchResult == nil) {
        self.searchResult = matchResults.firstObject;
    }
    //  重复搜索同一个内容
    else {
        //  匹配下一个 searchResult
        [matchResults enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //  查找中..
            if (NSEqualRanges(obj.range, self.searchResult.range) == NO) return;
            
            NSInteger resultIdx = idx + (isNext ? 1 : -1);
            
            self.searchResult = matchResults[resultIdx % matchResults.count];
            if (resultIdx >= matchResults.count) {
                [self toastWithText:@"到最后一个了!"];
            }
            
            *stop = YES;
        }];
    }

    if (self.searchResult == nil) {
        [self toastWithText:@"没有匹配到内容!"];
    } else {
        [UIView animateWithDuration:0.15 animations:^{
            [self.contentTextView scrollRangeToVisible:self.searchResult.range];
            [self.contentTextView setSelectedRange:self.searchResult.range];
        }];
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchText = searchBar.text;
    if (DGIsNotNull(searchText) == NO) {
        return;
    }
    
    //  记录最近搜索
    [self.recentSearchView recordSearch:searchText];

    [self searchWithText:searchText isNext:YES];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    //  中间有一个用于重置的 scope, 哈哈
    if (searchBar.selectedScopeButtonIndex == 1) return;
    [UIView animateWithDuration:0.2 animations:^{
        [searchBar setSelectedScopeButtonIndex:1];
    }];
    
    [self searchWithText:searchBar.text isNext:(selectedScope == 2)];
}

#pragma mark - UITextViewDelegate
///  点击log高亮链接了
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:URL];
    safariVC.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:safariVC animated:YES completion:nil];
    return NO;
}

#pragma mark - util func
- (void)toastWithText:(NSString *)text {
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:18 weight:(UIFontWeightBold)];
    [label sizeToFit];
    label.center = self.view.center;
    [self.view addSubview:label];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [label removeFromSuperview];
    });
}

- (NSMutableAttributedString *)attributedTextForLog {
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    //调整行间距
    paragraphStyle.lineSpacing = 3.5;
    NSDictionary *attriDict = @{
        NSParagraphStyleAttributeName : paragraphStyle,
        NSFontAttributeName           : [UIFont systemFontOfSize:15]
    };
    NSString *jsonStr = [self.logModel.contentDic dg_JSONDescription];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:jsonStr attributes:attriDict];
    
    //  把Key高亮，方便查看
    [self highlightKeyInDict:self.logModel.contentDic
            originJSONString:jsonStr
             attributeString:attrStr];
    
    //  高亮链接
    [self highlightLink:attrStr];
    
    return attrStr;
}

- (void)highlightKeyInDict:(NSDictionary *)content
          originJSONString:(NSString *)jsonStr
           attributeString:(NSMutableAttributedString *)attrStr {
    [content.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *keyStr = [NSString stringWithFormat:@"\"%@\" : ", obj];
        NSRange range = [jsonStr rangeOfString:keyStr];
        
        //  继续向内查找
        id value = content[obj];
        //  A. 是字典
        if ([value isKindOfClass:[NSDictionary class]]) {
            [self highlightKeyInDict:value
                    originJSONString:jsonStr
                     attributeString:attrStr];
        }
        //  B. 是数组
        else if ([value isKindOfClass:[NSArray class]]) {
            for (id subvalue in (NSArray *)value) {
                if ([subvalue isKindOfClass:[NSDictionary class]] == NO) continue;
                
                [self highlightKeyInDict:subvalue
                        originJSONString:jsonStr
                         attributeString:attrStr];
            }
        }
        
        //  没找到
        if (range.location == NSNotFound) return;
        range.length -= 4;
        range.location += 1;

        [attrStr setAttributes:@{
            NSForegroundColorAttributeName : [UIColor systemBlueColor],
            NSFontAttributeName            : [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold],
            NSBackgroundColorAttributeName : [[UIColor yellowColor] colorWithAlphaComponent:.1]
        } range:range];
    }];
}

- (void)highlightLink:(NSMutableAttributedString *)attrStr {
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];

    // 检测并高亮链接
    NSArray<NSTextCheckingResult *> *matches = [detector matchesInString:attrStr.string options:0 range:NSMakeRange(0, attrStr.length)];

    for (NSTextCheckingResult *match in matches) {
        // 设置链接样式
        [attrStr addAttribute:NSLinkAttributeName value:match.URL range:match.range];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:match.range];
        // 如果需要，你还可以设置其他样式，比如下划线等
        [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:match.range];
    }
}

- (NSString *)genStrinContent {
    NSString *dateStr = [NSDate dateWithTimeIntervalSince1970:self.logModel.timeStamp].dg_stringWithISOFormat;
    return [NSString stringWithFormat:
                      @"[日志类型]：%@\n\[日志时间]：%@\n\n\[日志内容]：\n%@",
                      self.logModel.tag,
                      dateStr,
                      self.contentTextView.text];
}

@end
