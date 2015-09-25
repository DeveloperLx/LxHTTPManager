//
//  LxHTTPManager.h
//  LxHTTPManagerDemo
//
//  Created by DeveloperLx on 15/8/15.
//  Copyright (c) 2015年 DeveloperLx. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#pragma mark - RequestKey

#define stringify    __STRING
#define DECLARE_STRING_CONST(str) static NSString * const str = @stringify(str)
#define PRINTF(fmt, ...)    printf("%s\n",[[NSString stringWithFormat:fmt,##__VA_ARGS__]UTF8String])

DECLARE_STRING_CONST(REQUEST_LOGIN);
DECLARE_STRING_CONST(REQUEST_THIRD_LOGIN);
DECLARE_STRING_CONST(REQUEST_REGISTER);
DECLARE_STRING_CONST(REQUEST_PHONE_VERIFY_CODE);
DECLARE_STRING_CONST(REQUEST_CHANGE_USERNAME);
DECLARE_STRING_CONST(REQUEST_CHANGE_PASSWORD);
DECLARE_STRING_CONST(REQUEST_USER_DETAIL);
DECLARE_STRING_CONST(REQUEST_FRIEND_LIST);

#pragma mark - constants

typedef NS_ENUM(NSUInteger, LxDataUpdateStrategy) {
    LxDataUpdateStrategyAdd,
    LxDataUpdateStrategyReload,
};
//  NSInteger _currentPage;
//  LxDataUpdateStrategy _needUpdateStrategy;
//  BOOL _hasNextPage;
//  NSTimeInterval _lastUpdateTimeStamp;

static NSString * const ROOT_ADDRESS = @"http://...";
static NSString * const IMAGE_ROOT_ADDRESS = @"http://...";

static NSTimeInterval const REQUEST_TIMEOUT_DURATION = 60;
static NSTimeInterval const JSON_CACHE_DURATION = 7 * 24 * 60 * 60;
static NSTimeInterval const IMAGE_CACHE_DURATION = 7 * 24 * 60 * 60;

typedef void (^ResponseCallback)(NSDictionary * responseDictionary, NSError * error);
typedef void (^ProgressCallBack)(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead);
typedef void (^ConstructingBodyCallBack)(id<AFMultipartFormData> formData);

@interface LxHTTPManager : NSObject

#pragma mark - request

+ (NSDictionary *)requestDictionary;    //  need custom

+ (NSString *)urlStringForRequestKey:(NSString *)requestKey;
+ (BOOL)isValidForResponseDictionary:(NSDictionary *)responseDictionary;    // need custom for your project.
+ (NSInteger)statusCodeForResponseDictionary:(NSDictionary *)responseDictionary;    // need custom for your project.
+ (NSString *)statusMessageForResponseDictionary:(NSDictionary *)responseDictionary;    // need custom for your project.

+ (AFHTTPRequestOperation *)GET:(NSString *)requestKey
                     parameters:(NSDictionary *)parameters
               progressCallBack:(ProgressCallBack)progressCallBack
               responseCallBack:(ResponseCallback)responseCallBack;

+ (AFHTTPRequestOperation *)POST:(NSString *)requestKey
                      parameters:(NSDictionary *)parameters
                progressCallBack:(ProgressCallBack)progressCallBack
                responseCallBack:(ResponseCallback)responseCallBack;

+ (AFHTTPRequestOperation *)uploadData:(NSData *)data
                                    to:(NSString *)requestkey
                            parameters:(NSDictionary *)parameters
                              fileName:(NSString *)fileName
                              mimeType:(NSString *)mimeType
                      progressCallBack:(ProgressCallBack)progressCallBack
                      responseCallBack:(ResponseCallback)responseCallBack;

+ (AFHTTPRequestOperation *)updateMultipartData:(NSString *)requestkey
                                     parameters:(NSDictionary *)parameters
                               constructingBody:(ConstructingBodyCallBack)constructingBody
                               progressCallBack:(ProgressCallBack)progressCallBack
                               responseCallBack:(ResponseCallback)responseCallBack;

+ (AFHTTPRequestOperation *)downloadFrom:(NSString *)requestkey
                              parameters:(NSDictionary *)parameters
                             toLocalPath:(NSString *)localPath
                        progressCallBack:(ProgressCallBack)progressCallBack
                        responseCallBack:(ResponseCallback)responseCallBack;

#pragma mark - cache

+ (NSString *)generateCacheIdentifierBy:(NSString * (^)(void))makeCacheIdentifier;
+ (BOOL)saveCache:(NSDictionary *)cache withIdentifier:(NSString *)cacheIdentifier;
+ (NSDictionary *)cacheWithIdentifier:(NSString *)cacheIdentifier;

@end