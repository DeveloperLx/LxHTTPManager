//
//  LxHTTPManager.m
//  LxHTTPManagerDemo
//
//  Created by DeveloperLx on 15/8/15.
//  Copyright (c) 2015年 DeveloperLx. All rights reserved.
//

#import "LxHTTPManager.h"

@implementation LxHTTPManager

+ (AFHTTPRequestOperationManager *)sharedOperationManager   //  仅能用来处理返回json字符串的请求
{
    static AFHTTPRequestOperationManager * sharedOperationManager = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        
        sharedOperationManager = [[AFHTTPRequestOperationManager alloc]init];
        sharedOperationManager.requestSerializer.timeoutInterval = REQUEST_TIMEOUT_DURATION;
        
        AFJSONResponseSerializer * responseSerializer = [AFJSONResponseSerializer serializer];
        responseSerializer.removesKeysWithNullValues = YES;
        responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        sharedOperationManager.responseSerializer = responseSerializer;
    });
    return sharedOperationManager;
}

+ (AFNetworkReachabilityStatus)checkNetworkReachability
{
    AFNetworkReachabilityStatus networkReachabilityStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    
    switch (networkReachabilityStatus) {
        case AFNetworkReachabilityStatusUnknown: {
            PRINTF(@"网络未知状态");
            break;
        }
        case AFNetworkReachabilityStatusNotReachable: {
            PRINTF(@"网络未连接");
            break;
        }
        case AFNetworkReachabilityStatusReachableViaWWAN: {
            PRINTF(@"网络通过蜂窝连接");
            break;
        }
        case AFNetworkReachabilityStatusReachableViaWiFi: {
            PRINTF(@"网络通过wifi连接");
            break;
        }
        default: {
            break;
        }
    }
    
    return networkReachabilityStatus;
}

+ (NSString *)urlStringForRequestKey:(NSString *)requestKey
{
    NSString * urlString = [ROOT_ADDRESS stringByAppendingPathComponent:requestKey];
    
    NSCAssert([NSURL URLWithString:urlString], @"无法获取正确的URL地址！");
    
    return urlString;
}

+ (BOOL)isValidForResponseDictionary:(NSDictionary *)responseDictionary
{
    return YES;
}

+ (NSInteger)statusCodeForResponseDictionary:(NSDictionary *)responseDictionary
{
    return 0;
}

+ (NSString *)statusMessageForResponseDictionary:(NSDictionary *)responseDictionary
{
    return @"";
}

+ (AFHTTPRequestOperation *)GET:(NSString *)requestKey
                     parameters:(NSDictionary *)parameters
               progressCallBack:(ProgressCallBack)progressCallBack
               responseCallBack:(ResponseCallback)responseCallBack
{
    if ([LxHTTPManager checkNetworkReachability] == AFNetworkReachabilityStatusNotReachable) {
        return nil;
    }
    
    NSString * urlString = [LxHTTPManager urlStringForRequestKey:requestKey];
    
    PRINTF(@"-------Request begin-------"); //
    
    AFHTTPRequestOperation * requestOperation =
    [[LxHTTPManager sharedOperationManager]
     GET:urlString
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         [LxHTTPManager dealWithSuccessOperation:operation
                                  responseObject:responseObject
                                responseCallBack:responseCallBack];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         [LxHTTPManager dealWithFailureOperation:operation
                                           error:error
                                responseCallBack:responseCallBack];
     }];
    
    requestOperation.downloadProgressBlock = ^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        [LxHTTPManager dealWithProgressWithBytesRead:bytesRead
                                      totalBytesRead:totalBytesRead
                            totalBytesExpectedToRead:totalBytesExpectedToRead
                                    progressCallBack:progressCallBack];
    };
    
    return requestOperation;
}

+ (AFHTTPRequestOperation *)POST:(NSString *)requestKey
                      parameters:(NSDictionary *)parameters
                progressCallBack:(ProgressCallBack)progressCallBack
                responseCallBack:(ResponseCallback)responseCallBack
{
    if ([LxHTTPManager checkNetworkReachability] == AFNetworkReachabilityStatusNotReachable) {
        return nil;
    }
    
    NSString * urlString = [LxHTTPManager urlStringForRequestKey:requestKey];
    
    PRINTF(@"-------Request begin-------"); //
    
    AFHTTPRequestOperation * requestOperation =
    [[LxHTTPManager sharedOperationManager]
     POST:urlString
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         [LxHTTPManager dealWithSuccessOperation:operation
                                  responseObject:responseObject
                                responseCallBack:responseCallBack];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         [LxHTTPManager dealWithFailureOperation:operation
                                           error:error
                                responseCallBack:responseCallBack];
     }];
    
    requestOperation.downloadProgressBlock = ^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        [LxHTTPManager dealWithProgressWithBytesRead:bytesRead
                                      totalBytesRead:totalBytesRead
                            totalBytesExpectedToRead:totalBytesExpectedToRead
                                    progressCallBack:progressCallBack];
    };
    
    return requestOperation;
}

+ (AFHTTPRequestOperation *)uploadData:(NSData *)data
                                    to:(NSString *)requestkey
                            parameters:(NSDictionary *)parameters
                              fileName:(NSString *)fileName
                              mimeType:(NSString *)mimeType
                      progressCallBack:(ProgressCallBack)progressCallBack
                      responseCallBack:(ResponseCallback)responseCallBack
{
    if ([LxHTTPManager checkNetworkReachability] == AFNetworkReachabilityStatusNotReachable) {
        return nil;
    }
    
    NSString * urlString = [LxHTTPManager urlStringForRequestKey:requestkey];
    
    urlString = [LxHTTPManager buildCompleteGetUrlStringWithBaseUrlString:urlString
                                                               parameters:parameters];
    
    AFHTTPRequestOperation * requestOperation =
    [[LxHTTPManager sharedOperationManager]
     POST:urlString
     parameters:nil
     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         [formData appendPartWithFileData:data name:@"file[]" fileName:fileName mimeType:mimeType];
     } success:^(AFHTTPRequestOperation *operation, id responseObject) {
         [LxHTTPManager dealWithSuccessOperation:operation
                                  responseObject:responseObject
                                responseCallBack:responseCallBack];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [LxHTTPManager dealWithFailureOperation:operation
                                           error:error
                                responseCallBack:responseCallBack];
     }];
    
    requestOperation.uploadProgressBlock = ^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        [LxHTTPManager dealWithProgressWithBytesRead:bytesWritten
                                      totalBytesRead:totalBytesWritten
                            totalBytesExpectedToRead:totalBytesExpectedToWrite
                                    progressCallBack:progressCallBack];
    };
    
    return requestOperation;
}

+ (AFHTTPRequestOperation *)updateMultipartData:(NSString *)requestkey
                                     parameters:(NSDictionary *)parameters
                               constructingBody:(ConstructingBodyCallBack)constructingBody
                               progressCallBack:(ProgressCallBack)progressCallBack
                               responseCallBack:(ResponseCallback)responseCallBack
{
    if ([LxHTTPManager checkNetworkReachability] == AFNetworkReachabilityStatusNotReachable) {
        return nil;
    }
    
    NSString * urlString = [LxHTTPManager urlStringForRequestKey:requestkey];
    
    urlString = [LxHTTPManager buildCompleteGetUrlStringWithBaseUrlString:urlString
                                                               parameters:parameters];
    
    AFHTTPRequestOperation * requestOperation =
    [[LxHTTPManager sharedOperationManager]
     POST:urlString
     parameters:parameters
     constructingBodyWithBlock:constructingBody
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         [LxHTTPManager dealWithSuccessOperation:operation
                                  responseObject:responseObject
                                responseCallBack:responseCallBack];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [LxHTTPManager dealWithFailureOperation:operation
                                           error:error
                                responseCallBack:responseCallBack];
     }];
    
    requestOperation.uploadProgressBlock = ^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        [LxHTTPManager dealWithProgressWithBytesRead:bytesWritten
                                      totalBytesRead:totalBytesWritten
                            totalBytesExpectedToRead:totalBytesExpectedToWrite
                                    progressCallBack:progressCallBack];
    };
    
    return requestOperation;
}

+ (AFHTTPRequestOperation *)downloadFrom:(NSString *)requestkey
                              parameters:(NSDictionary *)parameters
                             toLocalPath:(NSString *)localPath
                        progressCallBack:(ProgressCallBack)progressCallBack
                        responseCallBack:(ResponseCallback)responseCallBack
{
    if ([LxHTTPManager checkNetworkReachability] == AFNetworkReachabilityStatusNotReachable) {
        return nil;
    }
    
    NSString * urlString = [LxHTTPManager urlStringForRequestKey:requestkey];
    
    urlString = [LxHTTPManager buildCompleteGetUrlStringWithBaseUrlString:urlString
                                                               parameters:parameters];
    
    NSMutableURLRequest * downloadRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:downloadRequest];
    
    AFHTTPRequestOperation * downloadOperation = [[AFHTTPRequestOperation alloc]initWithRequest:downloadRequest];
    
    unsigned long long downloadedPartFileSize = 0;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        
        PRINTF(@"LxHTTPManager: 曾下载过该文件");
        
        NSError * error = nil;
        
        NSDictionary * fileAttributes = [[NSFileManager defaultManager]attributesOfItemAtPath:localPath error:&error];
        downloadedPartFileSize = [fileAttributes fileSize];
        NSString * headerRangeFieldValue = [NSString stringWithFormat:@"bytes=%llu-", downloadedPartFileSize];
        [downloadRequest setValue:headerRangeFieldValue forHTTPHeaderField:@"Range"];
    }
    
    downloadOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:localPath append:YES];
    
    downloadOperation.downloadProgressBlock = ^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        [LxHTTPManager dealWithProgressWithBytesRead:bytesRead
                                      totalBytesRead:totalBytesRead
                            totalBytesExpectedToRead:totalBytesExpectedToRead
                                    progressCallBack:progressCallBack];
    };
    
    [downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LxHTTPManager dealWithSuccessOperation:operation
                                 responseObject:responseObject
                               responseCallBack:responseCallBack];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LxHTTPManager dealWithFailureOperation:operation
                                          error:error
                               responseCallBack:responseCallBack];
    }];
    
    [downloadOperation start];
    
    return downloadOperation;
}

+ (void)dealWithSuccessOperation:(AFHTTPRequestOperation *)operation
                  responseObject:(id)responseObject
                responseCallBack:(ResponseCallback)responseCallBack
{
    PRINTF(@"LxHTTPManager: URL: %@", operation.request.URL);    //
    
    [LxHTTPManager judgeAndPrintPostParameters:operation];
    
    if ([responseObject isKindOfClass:[NSDictionary class]] == NO) {
        
        NSError * error = [NSError errorWithDomain:@"RESPONSE_TYPE_ERROR_DOMAIN" code:-NSIntegerMax userInfo:@{NSLocalizedDescriptionKey:@"返回的响应非字典类型"}];
        responseCallBack(nil, error);
        return;
    }
    
    PRINTF(@"LxHTTPManager: responseString: %@", operation.responseString);    //
    
    NSDictionary * responseDictionary = (NSDictionary *)responseObject;
    
    NSInteger statusCode = [LxHTTPManager statusCodeForResponseDictionary:responseDictionary];
    NSString * statusMessage = [LxHTTPManager statusMessageForResponseDictionary:responseDictionary];
    
    if ([LxHTTPManager isValidForResponseDictionary:responseDictionary]) {
        PRINTF(@"---------Request success---------"); //
        responseCallBack(responseDictionary, nil);
    }
    else {
        NSError * error = [NSError errorWithDomain:@"HTTP_REQUEST_ERROR_DOMAIN" code:statusCode userInfo:@{NSLocalizedDescriptionKey:statusMessage}];
        PRINTF(@"---------Request error---------"); //
        responseCallBack(responseDictionary, error);
    }
}

+ (void)dealWithFailureOperation:(AFHTTPRequestOperation *)operation
                           error:(NSError *)error
                responseCallBack:(ResponseCallback)responseCallBack
{
    PRINTF(@"LxHTTPManager: URL: %@", operation.request.URL);    //
    
    [LxHTTPManager judgeAndPrintPostParameters:operation];
    
    PRINTF(@"LxHTTPManager: error: %@", error);    //
    PRINTF(@"---------Request failed---------"); //
    responseCallBack(nil, error);
}

+ (void)dealWithProgressWithBytesRead:(NSUInteger)bytesRead
                       totalBytesRead:(long long)totalBytesRead
             totalBytesExpectedToRead:(long long)totalBytesExpectedToRead
                     progressCallBack:(ProgressCallBack)progressCallBack
{
    PRINTF(@"LxHTTPManager: progress: >%zi< %zi/%zi", bytesRead, totalBytesRead, totalBytesExpectedToRead);    //
    progressCallBack((NSInteger)bytesRead, (NSInteger)totalBytesRead, (NSInteger)totalBytesExpectedToRead);
}

+ (NSString *)buildCompleteGetUrlStringWithBaseUrlString:(NSString *)baseUrlString
                                              parameters:(NSDictionary *)parameters
{
    NSMutableArray * keyValuePairsArray = [NSMutableArray array];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [keyValuePairsArray addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    }];
    
    NSString * keyValuePairsString = [keyValuePairsArray componentsJoinedByString:@"&"];
    keyValuePairsString = [keyValuePairsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString * completeGetUrlString = [NSString stringWithFormat:@"%@?%@", baseUrlString, keyValuePairsString];
    
    NSCAssert([NSURL URLWithString:completeGetUrlString], @"%@ 不是一个合法的URL字符串", completeGetUrlString);
    
    return completeGetUrlString;
}

+ (NSDictionary *)judgeAndPrintPostParameters:(AFHTTPRequestOperation *)requestOperation
{
    if ([requestOperation.request.HTTPMethod isEqualToString:@"POST"]) {
        
        NSMutableDictionary * mutableParameters = [NSMutableDictionary dictionary];
        
        NSString * parametersString = [[NSString alloc]initWithData:requestOperation.request.HTTPBody encoding:NSUTF8StringEncoding];
        
        NSArray * parameterStringArray = [parametersString componentsSeparatedByString:@"&"];
        for (NSString * parameterString in parameterStringArray) {
            
            NSArray * keyValueArray = [parameterString componentsSeparatedByString:@"="];
            [mutableParameters setValue:keyValueArray.lastObject forKey:keyValueArray.firstObject];
        }
        
        NSError * error = nil;
        
        NSData * parametersJsonData = [NSJSONSerialization dataWithJSONObject:mutableParameters options:NSJSONWritingPrettyPrinted error:&error];
        NSString * parametersJson = [[NSString alloc]initWithData:parametersJsonData encoding:NSUTF8StringEncoding];
        
        PRINTF(@"LxHTTPManager: request parameters: %@", parametersJson);    //
        
        return [NSDictionary dictionaryWithDictionary:mutableParameters];
    }
    else {
        return nil;
    }
}

#pragma mark - cache

+ (NSString *)cachesDirectory
{
    NSString * cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    
    BOOL isDirectory = NO;
    BOOL directoryExists = [[NSFileManager defaultManager] fileExistsAtPath:cachesDirectory isDirectory:&isDirectory];
    
    NSError * error;
    if (isDirectory == NO || directoryExists == NO) {
        BOOL createDirectorySuccess = [[NSFileManager defaultManager]createDirectoryAtPath:cachesDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (createDirectorySuccess) {
            PRINTF(@"LxHTTPManager: 创建缓存目录成功：%@", error);
            return nil;
        }
        else {
            PRINTF(@"LxHTTPManager: 创建缓存目录失败：%@", error);
            return nil;
        }
    }
    else {
        PRINTF(@"LxHTTPManager: 创建缓存目录已存在");
    }
    
    return cachesDirectory;
}

+ (NSString *)generateCacheIdentifierBy:(NSString * (^)(void))makeCacheIdentifier
{
    NSString * cacheIdentifier = makeCacheIdentifier();
    NSCAssert(cacheIdentifier.length > 0, @"LxHTTPManager: 未能生成合法的缓存标示符");
    return cacheIdentifier;
}

+ (NSString *)cachePathWithIdentifier:(NSString *)cacheIdentifier
{
    NSString * cachePath = [LxHTTPManager cachesDirectory];
    cachePath = [cachePath stringByAppendingPathComponent:cacheIdentifier];
    
    BOOL isDirectory = NO;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDirectory];
    
    if (fileExists == NO || isDirectory) {
        
        BOOL createFileSuccess = [[NSFileManager defaultManager]createFileAtPath:cachePath contents:nil attributes:nil];
        if (createFileSuccess == NO) {
            PRINTF(@"LxHTTPManager: 创建缓存文件失败"); //
            return nil;
        }
        else {
            PRINTF(@"LxHTTPManager: 创建缓存文件成功"); //
        }
    }
    else {
        PRINTF(@"LxHTTPManager: 缓存文件之前已存在"); //
    }
    
    return cachePath;
}

+ (BOOL)saveCache:(NSDictionary *)cache withIdentifier:(NSString *)cacheIdentifier
{
    NSCAssert([cache isKindOfClass:[NSDictionary class]], @"LxHTTPManager: 缓存对象不是字典类型");
    
    NSString * cachePath = [LxHTTPManager cachePathWithIdentifier:cacheIdentifier];
    
    BOOL saveSuccess = [cache writeToFile:cachePath atomically:YES];
    if (saveSuccess) {
        PRINTF(@"LxHTTPManager: 储存缓存记录成功"); //
        return saveSuccess;
    }
    else {
        PRINTF(@"LxHTTPManager: 储存缓存记录失败"); //
        return saveSuccess;
    }
}

+ (NSDictionary *)cacheWithIdentifier:(NSString *)cacheIdentifier
{
    NSString * cachePath = [LxHTTPManager cachePathWithIdentifier:cacheIdentifier];
    NSDictionary * cache = [NSDictionary dictionaryWithContentsOfFile:cachePath];
    if (cache) {
        PRINTF(@"LxHTTPManager: 并不存在缓存");
    }
    NSError * error = nil;
    NSDictionary * cacheFileAttributes = [[NSFileManager defaultManager]attributesOfItemAtPath:cachePath error:&error];
    if (error) {
        
        PRINTF(@"LxHTTPManager: 缓存已过期");
    }
    else if ([[NSDate date]timeIntervalSince1970] - [cacheFileAttributes.fileModificationDate timeIntervalSince1970] > JSON_CACHE_DURATION) {
        
        PRINTF(@"LxHTTPManager: 缓存已过期");
        
        BOOL removeCacheSuccess = [[NSFileManager defaultManager]removeItemAtPath:cachePath error:&error];
        if (removeCacheSuccess) {
            PRINTF(@"LxHTTPManager: 移除已过期的缓存成功");
        }
        else {
            PRINTF(@"LxHTTPManager: 移除已过期的缓存失败");
        }
        return nil;
    }
    else {
        
    }
    
    return cache;
}

@end