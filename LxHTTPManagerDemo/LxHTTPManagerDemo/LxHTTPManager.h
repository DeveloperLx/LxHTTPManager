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

static NSString * const ROOT_ADDRESS = @"http://";
static NSString * const IMAGE_ROOT_ADDRESS = @"http://";

static NSTimeInterval const REQUEST_TIMEOUT_DURATION = 60;
static NSTimeInterval const JSON_CACHE_DURATION = 7 * 24 * 60 * 60;
static NSTimeInterval const IMAGE_CACHE_DURATION = 7 * 24 * 60 * 60;

typedef void (^ResponseCallback)(NSDictionary * responseDictionary, NSError * error);

@interface LxHTTPManager : NSObject

#pragma mark - request

+ (NSDictionary *)requestDictionary;    //  need custom

+ (NSString *)urlStringForRequestKey:(NSString *)requestKey;
+ (BOOL)isValidForResponseDictionary:(NSDictionary *)responseDictionary;    // need custom for your project.
+ (NSInteger)statusCodeForResponseDictionary:(NSDictionary *)responseDictionary;    // need custom for your project.
+ (NSString *)statusMessageForResponseDictionary:(NSDictionary *)responseDictionary;    // need custom for your project.

+ (AFHTTPRequestOperation *)GET:(NSString *)requestName
                 withParameters:(NSDictionary *)parameters
               responseCallBack:(ResponseCallback)responseCallBack;

+ (AFHTTPRequestOperation *)POST:(NSString *)requestName
                  withParameters:(NSDictionary *)parameters
                responseCallBack:(ResponseCallback)responseCallBack;

#pragma mark - cache

+ (NSString *)generateCacheIdentifierBy:(NSString * (^)(void))makeCacheIdentifier;
+ (BOOL)saveCache:(NSDictionary *)cache withIdentifier:(NSString *)cacheIdentifier;
+ (NSDictionary *)cacheWithIdentifier:(NSString *)cacheIdentifier;

@end

@interface NSObject (jsonString)

@property (nonatomic,readonly) NSString * jsonString;

@end