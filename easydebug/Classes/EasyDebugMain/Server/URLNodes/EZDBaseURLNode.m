//
//  EZDBaseURLNode.m
//  HoldCoin
//
//  Created by Song on 2019/2/26.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDBaseURLNode.h"

#if EZDDEBUG_SERVER_SUPPORT
@implementation EZDBaseURLNode

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
    NSBundle *curBundle = [NSBundle bundleForClass:[self
                                      class]];
    NSURL *bundleURL = [curBundle URLForResource:@"easydebug_asset" withExtension:@"bundle" subdirectory:@"EZDDebugServerResources"];
    return [NSBundle bundleWithURL:bundleURL];
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

@end

#else

@implementation EZDBaseURLNode

+ (NSString *)nodePath{return @"";}

+ (NSString *)nodeDictPath{return @"";}

+ (NSString *)_404Path{return @"";}

+ (EZDDebugServerResponse *)respondsForGCDRequest:(GCDWebServerRequest *)request{return nil;}

+ (NSString *)pathWithRequest:(GCDWebServerRequest *)request{return @"";}

+ (NSBundle *)baseHTMLBundle{return nil;}

+ (kEZDHTMLContentType)contentTypeWithURL:(NSURL *)url{return 0;}

@end

#endif

