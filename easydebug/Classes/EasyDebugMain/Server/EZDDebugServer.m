//
//  EZDDebugServer.m
//  HoldCoin
//
//  Created by Song on 2019/2/20.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDDebugServer.h"
#import "EZDDebugServerHandler.h"
#import "EZDMessageHUD.h"

#import "EZDDefine.h"

#if EZDDEBUG_SERVER_SUPPORT

#import "GCDWebServer.h"
#import "GCDWebUploader.h"
#import "GCDWebServerDataResponse.h"
#import "GCDWebServerMultiPartFormRequest.h"

static EZDDebugServer *server = nil;

@interface EZDDebugServer ()<GCDWebUploaderDelegate>

@property (strong,nonatomic) GCDWebServer *httpServer;
@property (strong,nonatomic) GCDWebUploader *uploadServer;
@property (strong,nonatomic) NSUserActivity *userActivity;
@property (strong,nonatomic) NSMapTable<NSString *,id<EZDDebugServerHandler>> *handlers;

@end

@implementation EZDDebugServer

+ (instancetype)startServerWithPort:(uint16_t)port{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        server = [EZDDebugServer new];
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        documentsPath = [documentsPath stringByAppendingPathComponent:@"uploadFile"];
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:nil];
        server.httpServer = [[GCDWebServer alloc] init];
        [GCDWebServer setLogLevel:4];
        
        server.uploadServer = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
        server.uploadServer.delegate = server;
        
        server.handlers = [NSMapTable strongToWeakObjectsMapTable];
        
        __weak typeof(server) weakServer= server;
        [server.httpServer addDefaultHandlerForMethod:@"GET" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
            return [weakServer handleRequest:request];
        }];
        
        [server.httpServer addDefaultHandlerForMethod:@"PUT" requestClass:[GCDWebServerMultiPartFormRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
            return [weakServer handleRequest:request];
        }];
        
        [server.httpServer addDefaultHandlerForMethod:@"POST" requestClass:[GCDWebServerMultiPartFormRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
            return [weakServer handleRequest:request];
        }];
    });
    [server startServerWithPort:port];
    return server;
}

- (void)dealloc{
    [self.httpServer stop];
}

- (void)startServerWithPort:(uint16_t)port{
    bool ret = [self.httpServer startWithPort:port bonjourName:nil];
    bool upret = [self.uploadServer startWithPort:port+1 bonjourName:nil];
    if (ret && upret) {
//        NSLog(@"Debug server launch at %@",self.httpServer.serverURL);
        [EZDMessageHUD showMessageHUDWithText:[NSString stringWithFormat:@"Debug server : %@",self.httpServer.serverURL] type:(EZDImageTypeCorrect)];
        NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:@"com.debugserver.easydebug.rggcomming"];
        userActivity.webpageURL = self.httpServer.serverURL;
        [userActivity becomeCurrent];
        self.userActivity = userActivity;
    } else {
        NSLog(@"Launch debug server failed");
    }
}

- (void)stopServer{
    [self.httpServer stop];
}

- (void)printFliesOfPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *myDirectoryEnumerator = [fileManager enumeratorAtPath:path];
    NSString *cp = nil;
    
    while (cp = [myDirectoryEnumerator nextObject]) {
        if ([cp containsString:@".html"]) {
            NSLog(@"-----AAA-----%@", cp);
        }
    }
}

+ (NSString *)serverURL{
    return server.httpServer.serverURL.absoluteString;
}

+ (NSString *)uploadServerURL{
    return server.uploadServer.serverURL.absoluteString;
}

- (GCDWebServerResponse *)handleRequest:(GCDWebServerRequest *)request{
    GCDWebServerResponse *response = [self uploadFile:request];
    
    if (response) return response;
        
    return [EZDDebugServerHandler responseWithMethod:request.method GCDRequest:request].GCDDataResponse;
}

- (GCDWebServerResponse*)uploadFile:(GCDWebServerMultiPartFormRequest*)request {
    NSArray<NSString *> *nodes = [request.URL pathComponents];
    if (![request.method isEqualToString:@"PUT"]
        || ![self.handlers objectForKey:nodes.lastObject]) {
        return nil;
    }
    
    NSString *contentType = @"application/json";
    
    GCDWebServerMultiPartFile *file = [request firstFileForControlName:nodes.lastObject];
    NSString* relativePath = [[request firstArgumentForControlName:@"path"] string];
    
    GCDWebServerResponse *response = [GCDWebServerDataResponse responseWithJSONObject:@{@"status":@(1)} contentType:contentType];
    
    id<EZDDebugServerHandler> bhandler = [self.handlers objectForKey:nodes.lastObject];
    [bhandler serverDidRecieveFileUploadWithPath:request.path filePath:relativePath fileContent:[NSData dataWithContentsOfURL:relativePath]];
    
    return response;
}

+ (void)addHandlerForUploadPath:(NSString *)uploadPath handler:(id<EZDDebugServerHandler>)handler{
    NSAssert(server, @"Server didnt start!");
    NSAssert(uploadPath.length, @"Path can't be null!");
    NSAssert(handler, @"Handler cant be null!");
    id exhandler = [server.handlers objectForKey:uploadPath];
    NSAssert(!exhandler, @"Observer path regiested by %@",handler);
    
    server.uploadServer.title = uploadPath;
    [server.handlers setObject:handler forKey:uploadPath];
}

+ (void)removeHandler:(id<EZDDebugServerHandler>)handler{
    
}

#pragma mark - GCDWebUploaderDelegate
- (void)webUploader:(GCDWebUploader *)uploader didUploadFileAtPath:(NSString *)path{
    id<EZDDebugServerHandler> bhandler = [self.handlers objectForKey:uploader.title];
    [bhandler serverDidRecieveFileUploadWithPath:uploader.title filePath:path fileContent:[NSData dataWithContentsOfFile:path]];
}

@end

#else

@implementation EZDDebugServer

+ (instancetype)startServerWithPort:(uint16_t)port{return nil;}
+ (NSString *)serverURL {return nil;}
+ (NSString *)uploadServerURL {
    return nil;
}
- (void)startServerWithPort:(uint16_t)port{}
- (void)stopServer{}
+ (void)addHandlerForUploadPath:(NSString *)uploadPath handler:(id<EZDDebugServerHandler>)handler{}
+ (void)removeHandler:(id<EZDDebugServerHandler>)handler{}


@end

#endif
