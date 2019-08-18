//
//  EZDBaseURLNode.m
//  HoldCoin
//
//  Created by Song on 2019/2/26.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDBaseURLNode.h"

@implementation EZDBaseURLNode
#if EZDDEBUG_SERVER_SUPPORT

+ (NSString *)nodePath{
//    NSLog(@"*********************\nWarning : %@ didn't set nodePath,it will use class name as node path\n*********************\n",[self className]);
    return @"";
}

+ (NSString *)nodeDictPath{
    return [self nodePath];
}

+ (NSString *)_404Path{
    return [[EZDBaseURLNode baseHTMLBundle] pathForResource:@"_404" ofType:@"html"];
}

+ (EZDDebugServerResponse *)respondsForGCDRequest:(GCDWebServerRequest *)request{
    NSString *p = [self pathWithRequest:request];
    if (!p) {
        return [EZDDebugServerResponse r404];
    }
    
    kEZDHTMLContentType contentType = [self contentTypeWithURL:request.URL];
    
    return [EZDDebugServerResponse responseWithPath:p contentType:contentType];
}

+ (NSString *)pathWithRequest:(GCDWebServerRequest *)request{
    NSArray<NSString *> *nodes = [request.URL pathComponents];
    if ([nodes.lastObject isEqualToString:[self nodePath]]) {
        return [[self baseHTMLBundle] pathForResource:@"index" ofType:@"html" inDirectory:[self nodeDictPath]];
    }else{
        NSString *path = [[self baseHTMLBundle] pathForResource:nodes.lastObject ofType:nil inDirectory:[self nodeDictPath]];
        if (!path) {
            path = [[self baseHTMLBundle].bundlePath stringByAppendingPathComponent:[request.URL path]];
        }
        BOOL isDir = false;

        if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
            return [self _404Path];
        }
        
        NSString *indexPath = [path stringByAppendingPathComponent:@"index.html"];
        if (isDir) {
            BOOL hadIndex = [[NSFileManager defaultManager] fileExistsAtPath:indexPath];
            return hadIndex ? indexPath : [self _404Path];
        }
        
        return path;
    }
}

+ (NSBundle *)baseHTMLBundle{
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"EZDDebugServerResource" ofType:@"bundle"]];
}

+ (kEZDHTMLContentType)contentTypeWithURL:(NSURL *)url{
    kEZDHTMLContentType contentType = kEZDHTMLContentTypeTextHTML;
    NSArray *fileComponents = [url.lastPathComponent componentsSeparatedByString:@"."];
    if (fileComponents.count > 1) {
        NSString *fileType = fileComponents.lastObject;
        
        contentType = @{
                        @"css":kEZDHTMLContentTypeTextCSS,
                        @"js":kEZDHTMLContentTypeTextJS,
                        @"html":kEZDHTMLContentTypeTextHTML,
                        @"json":kEZDHTMLContentTypeJson,
                        }[fileType];
    }
    return contentType;
}
#endif

@end