//
//  LxHTTPManager.m
//  LxHTTPManagerDemo
//
//  Created by DeveloperLx on 15/8/15.
//  Copyright (c) 2015年 DeveloperLx. All rights reserved.
//

#import "LxHTTPManager.h"

@implementation LxHTTPManager

+ (NSDictionary *)requestDictionary
{
    static NSDictionary * requestDictionary = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        
        requestDictionary = @{
                              REQUEST_LOGIN : @"login.php",
                              REQUEST_THIRD_LOGIN : @"third_login.php",
                              REQUEST_REGISTER : @"register.php",
                              REQUEST_PHONE_VERIFY_CODE : @"phone_veridy_core.php",
                              REQUEST_CHANGE_USERNAME : @"change_username.php",
                              REQUEST_CHANGE_PASSWORD : @"change_password.php",
                              REQUEST_USER_DETAIL : @"user_detail.php",
                              REQUEST_FRIEND_LIST : @"friend_list.php"
                              // ......
                              };
    });
    return requestDictionary;
}

+ (AFHTTPRequestOperationManager *)sharedOperationManager
{
    static AFHTTPRequestOperationManager * sharedOperationManager = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        
        sharedOperationManager = [[AFHTTPRequestOperationManager alloc]init];
        sharedOperationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        sharedOperationManager.requestSerializer.timeoutInterval = REQUEST_TIMEOUT_DURATION;
    });
    return sharedOperationManager;
}

+ (NSString *)urlStringForRequestKey:(NSString *)requestKey
{
    NSString * urlString = [[LxHTTPManager requestDictionary] valueForKey:requestKey];
    
    urlString = [ROOT_ADDRESS stringByAppendingPathComponent:urlString];
    
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
               responseCallBack:(ResponseCallback)responseCallBack
{
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
    
    return requestOperation;
}

+ (AFHTTPRequestOperation *)POST:(NSString *)requestKey
                      parameters:(NSDictionary *)parameters
                responseCallBack:(ResponseCallback)responseCallBack
{
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
    
    return requestOperation;
}

+ (AFHTTPRequestOperation *)uploadData:(NSData *)data
                                    to:(NSString *)requestkey
                            parameters:(NSDictionary *)parameters
                              fileName:(NSString *)fileName
                              mimeType:(NSString *)mimeType
                      responseCallBack:(ResponseCallback)responseCallBack
{
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
    return requestOperation;
}

+ (AFHTTPRequestOperation *)downloadFrom:(NSString *)requestkey
                              parameters:(NSDictionary *)parameters
                             toLocalPath:(NSString *)localPath
                        progressCallBack:(ProgressCallBack)progressCallBack
                        responseCallBack:(ResponseCallback)responseCallBack
{
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
        
        progressCallBack((NSInteger)bytesRead, (NSInteger)totalBytesRead, (NSInteger)totalBytesExpectedToRead);
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
    
    if ([responseObject isKindOfClass:[NSDictionary class]] == NO) {
        
        NSError * error = [NSError errorWithDomain:@"RESPONSE_TYPE_ERROR_DOMAIN" code:-NSIntegerMax userInfo:@{NSLocalizedDescriptionKey:@"返回的响应非字典类型"}];
        responseCallBack(nil, error);
        return;
    }
    
    NSDictionary * responseDictionary = (NSDictionary *)responseObject;
    PRINTF(@"LxHTTPManager: jsonString: %@", responseDictionary.jsonString);    //
    
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
    PRINTF(@"LxHTTPManager: error: %@", error);    //
    PRINTF(@"---------Request failed---------"); //
    responseCallBack(nil, error);
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

@implementation NSObject (jsonString)

- (NSString *)jsonString
{
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError * error = nil;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            return error.description;
        }
        else if (jsonData) {
            return [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        else {
            return @"Can't express with a json string!";
        }
    }
    else {
        return @"Can't express with a json string!";
    }
    return nil;
}

@end