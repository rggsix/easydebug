//
//  EZDDebugServerHandler.m
//  HoldCoin
//
//  Created by Song on 2019/2/26.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDDebugServerHandler.h"
#import "EZDBaseURLNode.h"
#import "NSObject+EZDAddition.h"

static NSMutableDictionary *_c_nodeClasses;

@interface EZDDebugServerHandler ()

@end

#if EZDDEBUG_SERVER_SUPPORT
@implementation EZDDebugServerHandler

+ (NSMutableDictionary *)nodeClasses{
    return _c_nodeClasses;
}

+ (void)setNodeClasses:(NSMutableDictionary *)nodeClasses{
    _c_nodeClasses = nodeClasses;
}

+ (void)regiestURLNodeClass:(Class)urlNodeClass{
    if (!self.nodeClasses) {
        [self setNodeClasses:[NSMutableDictionary new]];
    }
    
    if (![urlNodeClass isSubClassAndNotItSelf:[EZDBaseURLNode class]]) {
        NSAssert(false, @"Regiest %@ URL Node class must be subclass of 'EZDBaseURLNode'!",urlNodeClass);
        return;
    }
    
    NSString *key = [urlNodeClass performSelector:@selector(nodePath)];
    key = key.length ? key : NSStringFromClass([urlNodeClass class]);
    
    Class spClass = urlNodeClass;
    NSMutableArray<Class> *classChain = [NSMutableArray new];
    NSInteger depthOfNode = 0;
    while (![spClass isEqual:[EZDBaseURLNode class]]) {
        depthOfNode++;
        
        NSAssert((depthOfNode < EZDDebugServerMaxPathDeep),@"Debug server regiest node path too deep!");
        
        [classChain insertObject:spClass atIndex:0];
        spClass = [urlNodeClass superclass];
    }
    
    __block NSMutableDictionary *currentNodeClsMap = [self nodeClasses];
    NSInteger classChanLen = classChain.count;
    __block bool ignoreSpCls = false;
    [classChain enumerateObjectsUsingBlock:^(Class  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // Super class must regiest itself, or it won't contain in "_nodeClasses".
        if (ignoreSpCls) {
            obj = [EZDBaseURLNode class];
            ignoreSpCls = false;
        }
        
        Class curNodeCls = [currentNodeClsMap[@"nodeClass"] class];
        if (curNodeCls && ![curNodeCls isEqual:[EZDBaseURLNode class]]) {
            NSAssert(false, @"%@ node had regiested by %@",key,currentNodeClsMap[@"nodeClass"]);
            *stop = true;
            return;
        }
        
        NSMutableDictionary *subNodeDict = currentNodeClsMap[key];
        if (!subNodeDict) {
            subNodeDict = [NSMutableDictionary new];
            currentNodeClsMap[key] = subNodeDict;
        }
        
        subNodeDict[@"nodeClass"] = obj;
        if (!subNodeDict[@"subNode"] && (idx < classChanLen-1)) {
            subNodeDict[@"subNode"] = [NSMutableDictionary new];
            ignoreSpCls = true;
        }
        currentNodeClsMap = subNodeDict;
    }];
}

+ (EZDDebugServerResponse *)responseWithMethod:(NSString *)method GCDRequest:(GCDWebServerRequest *)request {
    NSFileManager *fileM = [NSFileManager defaultManager];
    NSString *path = [NSString stringWithFormat:@"%@%@",[EZDBaseURLNode baseHTMLBundle].bundlePath,request.URL.relativePath];
    bool *isdir = false;
    if ([fileM fileExistsAtPath:path isDirectory:&isdir]) {
        if (!isdir) {
            path = [NSString stringWithFormat:@"%@%@",[EZDBaseURLNode baseHTMLBundle].bundlePath,request.URL.relativeString];
            return [EZDDebugServerResponse responseWithPath:path contentType:[EZDBaseURLNode contentTypeWithURL:request.URL]];
        }
    }
    
    NSMutableArray<NSString *> *nodes = [[request.URL pathComponents] mutableCopy];
    
    if (nodes.count == 1) {
        return EZDDebugServerResponse.index;
    }
    
    __block NSMutableDictionary *curNodeDict = @{@"/":@{@"nodeClass":[EZDBaseURLNode class],@"subNode":[self nodeClasses]}};
    //  remove root node count
    NSInteger nodesDeep = ((NSInteger)nodes.count) - 1;
    __block Class nodeCls = nil;
    __block Class lastNodeCls = nil;
    [nodes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == nodesDeep) {
            lastNodeCls = nodeCls;
            nodeCls = curNodeDict[obj][@"nodeClass"];
            NSString *nodePath = [nodeCls performSelector:@selector(nodePath)];
            //  Check if it is main path resource request.
            if (nodes.count == 2 && ![nodePath isEqualToString:nodes.lastObject]) {
                nodeCls = [EZDBaseURLNode class];
            }
        } else {
            nodeCls = curNodeDict[obj][@"nodeClass"];
            curNodeDict = curNodeDict[obj][@"subNode"];
        }
        
        // File request
        if ((!nodeCls && !curNodeDict)) {
            nodeCls = lastNodeCls;
        } else {
            if (!(nodeCls || curNodeDict)) NSLog(@"Node not found for request %@",request.URL);
//            NSAssert((nodeCls || curNodeDict), @"Node not found for request %@",request.URL);
        }
    }];
    
    if ([nodeCls isSubclassOfClass:[EZDBaseURLNode class]]) {
        EZDDebugServerResponse *response = [nodeCls performSelector:@selector(respondsForGCDRequest:) withObject:request];
        return response;
    }
    
    return [EZDBaseURLNode respondsForGCDRequest:request];
}

#else
@implementation EZDDebugServerHandler

#endif

@end
