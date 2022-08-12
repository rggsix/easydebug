//
//  EZDLogManager+NetworkMonitor.m
//  EasyDebug
//
//  Created by songheng on 2020/12/21.
//

#import "EZDLogManager+NetworkMonitor.h"

#import "EasyDebug.h"
#import "EasyDebugUtil.h"
#import "EZDNetworkMonitor.h"

@implementation EZDLogManager (NetworkMonitor)

- (void)recordNetRequestWithRequest:(NSURLRequest *)request content:(id)content response:(id)response error:(nullable NSError *)error{
    NSDictionary *responseDict = [self handleResponse:response];
    
    BOOL isErrorResponse = NO;
    if (EZDNetworkMonitor.shared.responseJudgeBlock) {
        isErrorResponse = EZDNetworkMonitor.shared.responseJudgeBlock(request, responseDict) == NO;
    }

    NSDictionary *rcontent = @{
                                @"targetURL"       : DGNotNullString(request.URL.absoluteString),
                                @"method"          : DGNotNullString(request.HTTPMethod),
                                @"header"          : DGNotNullDict(request.allHTTPHeaderFields),
                                @"parameter"       : [self handleContent:content request:request],
                                @"response"        : responseDict,
                                kDebugLogErrorFlag :  @(error != nil || isErrorResponse)
    };
    
    [EZDLogManager.shared recordLogWithTag:kDebugNetworkLogTag content:rcontent complete:nil];
}

#pragma mark - private func


#pragma mark - util func
- (NSDictionary *)errorResponseWithError:(NSError *)error {
    NSDictionary *userinfo = [[NSDictionary alloc] initWithDictionary:error.userInfo];
    
    NSDictionary *errorResponseDict = nil;
    
    NSString *htmlstr = nil;
    NSString *errorDesc = @"unknow error.";

    if(userinfo) {
          NSError *innerError = [userinfo valueForKey:@"NSUnderlyingError"];
          if(innerError) {
             NSDictionary *innerUserInfo = [[NSDictionary alloc] initWithDictionary:innerError.userInfo];
             if(innerUserInfo) {
                  if([innerUserInfo objectForKey:@"com.alamofire.serialization.response.error.data"]) {
                       htmlstr = [[NSString alloc] initWithData:[innerUserInfo objectForKey:@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
                      errorDesc = [innerUserInfo objectForKey:NSLocalizedDescriptionKey];
                  }
             }
          } else {
               htmlstr = [[NSString alloc] initWithData:[userinfo valueForKey:@"AFNetworkingOperationFailingURLResponseDataErrorKey"] encoding:NSUTF8StringEncoding];
          }
    }
    
    if (htmlstr.length) {
        NSData *errDesData = [htmlstr dataUsingEncoding:(NSUTF8StringEncoding)];
        NSError *htmlConvertErr = nil;
        NSAttributedString *htmlstr = [[NSAttributedString alloc] initWithData:errDesData options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:&htmlConvertErr];
        if (!htmlConvertErr) {
            errorResponseDict = @{@"desc":DGNotNullString(errorDesc),@"html":DGNotNullString([htmlstr string])};
        }
    }
    
    return errorResponseDict;
}

- (NSDictionary *)handleContent:(id)content request:(NSURLRequest *)request {
    NSDictionary *contentDict = nil;
    if ([content isKindOfClass:[NSDictionary class]]) {
        contentDict = content;
    } else if ([content isKindOfClass:[NSString class]]) {
        NSString *contentStr = (NSString *)content;
        if (contentStr.length) {
            contentDict = [NSJSONSerialization JSONObjectWithData:[contentStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            
            if (!contentDict.allKeys.count && [contentStr containsString:@"="]) {
                NSURLComponents *comp = [NSURLComponents componentsWithString:[NSString stringWithFormat:@"https://x?%@", contentStr]];
                NSMutableDictionary *querys = [NSMutableDictionary dictionaryWithCapacity:comp.queryItems.count];
                [comp.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [querys setObject:DGNotNullString(obj.value) forKey:DGNotNullString(obj.name)];
                }];
                contentDict = [querys copy];
            }
            
            if (!contentDict.allKeys.count) {
                contentDict = @{@"__unknow_content":content};
            }
        } else {
            contentDict = @{};
        }

    } else if(content){
        contentDict = @{@"__unknow_content":DGNotNullString([content description])};
    } else {
        contentDict = @{};
    }
    
    NSMutableDictionary *cptmpdict = [contentDict mutableCopy];
    //  append content from url query
    if (request.URL) {
        NSURLComponents *urlComp = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
        [urlComp.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [cptmpdict setObject:DGNotNullString(obj.value) forKey:DGNotNullString(obj.name)];
        }];
    }
    return [cptmpdict copy];
}

- (NSDictionary *)handleResponse:(id)response {
    NSDictionary *responseDict = nil;
    if ([response isKindOfClass:[NSError class]]) {
        responseDict = [self errorResponseWithError:response];
        
        if (!responseDict.allKeys.count) {
            NSError *err = (NSError *)response;

            responseDict = DGNotNullDict([err userInfo]);
        }
    } else if(![response isKindOfClass:[NSDictionary class]]) {
        if ([response isKindOfClass:[NSString class]]) {
            NSData *data = [(NSString *)response dataUsingEncoding:(NSUTF8StringEncoding)];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json isKindOfClass:[NSDictionary class]]) {
                responseDict = json;
            } else {
                responseDict = @{@"__unknow_type_response":response};
            }
        } else {
            response = DGNotNullString([response description]);
            responseDict = @{@"__unknow_type_response":response};
        }
    } else{
        responseDict = DGNotNullDict(response);
    }
    
    return responseDict;
}

@end
