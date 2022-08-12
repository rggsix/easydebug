//
//  MainViewController.m
//  QTConfig
//
//  Created by songheng on 2020/11/2.
//

#import "MainViewController.h"
#import <Masonry/Masonry.h>

#import "EasyDebug.h"
#import "EZDCrashMonitor.h"
#import "EZDPerformance.h"

#import <AFNetworking.h>

@interface MainViewController ()

@property (nonatomic, assign) CGFloat       currentY;
@property (nonatomic, strong) UIScrollView  *scroll;
@property (nonatomic, strong) UITextView    *textView;

@end


@implementation MainViewController

- (instancetype)init {
    if (self = [super init]) {
        self.currentY = 30;
    }
    return self;
}

- (UIColor*)colorFromRGB:(uint)rgbValue{
    return [self colorFromRGBA:rgbValue alpha:1];
}

- (UIColor*)colorFromRGBA:(uint)rgbValue alpha:(CGFloat)alpha{
    return [UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((CGFloat)((rgbValue & 0x00FF00) >> 8))/255.0
                            blue:((CGFloat)(rgbValue & 0x0000FF))/255.0
                           alpha:alpha];
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [EasyDebug logWithTag:@"Test->MyTag" log:@"viewDidLoad ... "];
    
    self.title = @"EasyDebug Test";
    self.view.backgroundColor = UIColor.whiteColor;
    _scroll = [[UIScrollView alloc] init];
    _scroll.alwaysBounceVertical = true;
    [self.view addSubview:_scroll];
    [_scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self addLabel:@"打开Log："];
    UISwitch *swcDebug = [self addSwitchWithSelector:@selector(logOn:)];
    swcDebug.on = EasyDebug.shared.isOn;
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0.5f * [self screenWidth], self.currentY - 55, 120, 40)];
    _textView.layer.borderColor = UIColor.blackColor.CGColor;
    _textView.layer.borderWidth = 0.5f;
    _textView.layer.cornerRadius = 5;
    _textView.clipsToBounds = YES;
    _textView.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    _textView.text = @"测试Keyboard";
    [self.scroll addSubview:_textView];
    
    [self addBtn:@"make log" selector:@selector(makeLog)];
    [self addBtn:@"URLSession request" selector:@selector(sessionDataTaskRequest)];
    [self addBtn:@"Download request" selector:@selector(sessionDownloadTaskRequest)];
    [self addBtn:@"AFN request" selector:@selector(afnRequest)];
    [self addBtn:@"make NSException crash" selector:@selector(NSExceptionCrashNow)];
    [self addBtn:@"make signal crash" selector:@selector(signalCrashNow:)];
    [self addBtn:@"子线程crash" selector:@selector(queueCrashNow)];

    _scroll.contentSize = CGSizeMake(0, self.currentY);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (CGFloat)screenWidth{
    return [UIScreen mainScreen].bounds.size.width;
}

- (UIButton*)buttonWithTitle:(NSString*)title
                        font:(UIFont*)font
                  titleColor:(UIColor*)titleColor
                     bgColor:(UIColor*)bgColor
                cornerRadius:(CGFloat)cornerRadius
                 borderColor:(UIColor*)borderColor
                 borderWidth:(CGFloat)borderWidth {
    
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState: UIControlStateNormal];
    button.titleLabel.font = font;
    button.backgroundColor = bgColor;
    if(cornerRadius > 0){
        button.layer.cornerRadius = cornerRadius;
    }
    if(![borderColor isEqual:UIColor.clearColor]){
        button.layer.borderWidth = borderWidth;
        button.layer.borderColor = borderColor.CGColor;
    }
    return button;
}

-(UIButton *)addBtn:(NSString*)text selector:(SEL)selector{
    UIButton *btn = [self buttonWithTitle:text font:[UIFont fontWithName:@"PingFangSC-Regular" size:12] titleColor:UIColor.blackColor bgColor:UIColor.clearColor cornerRadius:5 borderColor:UIColor.blackColor borderWidth:0.5];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0.5 * ([self screenWidth] - 200), self.currentY, 220, 40);
    [self.scroll addSubview:btn];
    self.currentY += 50;
    return btn;
}

- (UISwitch *)addSwitchWithSelector:(SEL)selector{
    UISwitch *swc = [UISwitch new];
    [swc addTarget:self action:selector forControlEvents:(UIControlEventValueChanged)];
    swc.frame = CGRectMake(0.5 * ([self screenWidth] - 200), self.currentY, swc.frame.size.width, swc.frame.size.height);
    [self.scroll addSubview:swc];
    self.currentY += 50;
    return swc;
}

- (void)addLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0.5 * ([self screenWidth] - 200), self.currentY, 220, 40);
    label.text = text;
    label.textColor = [UIColor blackColor];
    [self.scroll addSubview:label];
    self.currentY += 50;
}

#pragma mark - Actions
- (void)logOn:(UISwitch *)swc {
    EasyDebug.shared.isOn = swc.on;
    [self.textView resignFirstResponder];
}

- (void)makeLog {
    [EasyDebug logWithTag:@"Test->TestTag" log:@"SEL name : %@", NSStringFromSelector(_cmd)];
    [EasyDebug logWithTag:@"Test->tag1" content:@{@"pk":@"pv"}];
    [EasyDebug log:@"我是一条无Tag的log"];
}

- (void)sessionDataTaskRequest {
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlstr = @"https://getman.cn/echo";
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"DELETE";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{@"sessionRequest":@"v1",@"p2":@{@"sp1":@"sv1"}} options:0 error:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [EasyDebug logWithTag:@"Test->NSURLSession" log:@"netRequestURLSession : %@ , error : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], error];
    }];
    [task resume];
}

- (void)sessionDownloadTaskRequest {
    //  应该只有datatask被拦截，download不应该被拦截
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlstr = @"https://getman.cn/echo";
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{@"sessionRequest":@"我是download task, 如果我被拦截了，说明出问题了"} options:0 error:nil];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [EasyDebug logWithTag:@"Test->NSURLSession" log:@"download task不会被拦截"];
    }];
    [task resume];
}

- (void)afnRequest {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:@"https://getman.cn/echo" parameters:@{@"afnRequest":@"v1",@"p2":@"v2"} headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [EasyDebug logWithTag:@"Test->AFRequest" log:@"responseObject : %@", responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [EasyDebug logWithTag:@"Test->AFRequest" log:@"error : %@", error];
        }];
}

- (void)NSExceptionCrashNow {
    id obj = nil;
    [[@[] mutableCopy] addObject:obj];
}

- (void)signalCrashNow:(id)sender {
//    [EasyDebug logConsole:@"%@", [EZDBackTrace dg_backtraceOfCurrentThread]];
//    [EasyDebug logConsole:@"%@", [NSThread callStackSymbols]];
//    float a = 0;
//    float b = 0.0f;
//    printf("%f", a/b);
//    abort();
//    raise(SIGBUS);
    [self signalCrashWithErrorAddress:sender];
}

- (void)queueCrashNow {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        abort();
    });
}

#pragma mark - private func
- (void)signalCrashWithErrorAddress:(id)sender{
    //    char *s = "hello world";
    //    [EasyDebug logWithTag:@"Test->signalCrashWithErrorAddress" log:@"%p %p", &s, s, *s];
    //    *s = 'H';
}

@end
