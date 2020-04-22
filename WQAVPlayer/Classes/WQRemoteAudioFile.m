//
//  WQRemoteAudioFile.m
//  WQDownLoader
//
//  Created by wuqiong on 2020/4/22.
//  Copyright © 2020 woshisha. All rights reserved.
//

#import "WQRemoteAudioFile.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES ).firstObject
#define kTempPath NSTemporaryDirectory()
@implementation WQRemoteAudioFile

//下载完成-> cache + 文件名称
+(NSString *)cacheFilePath:(NSURL * )url
{
    return [kCachePath stringByAppendingPathComponent:url.lastPathComponent];
}
+ (NSString *)tmpFilePath:(NSURL * )url{
    return [kTempPath stringByAppendingPathComponent:url.lastPathComponent];
}
+(BOOL)cacheFileExists:(NSURL *)url
{
    NSString * path = [self cacheFilePath:url];
    return [[NSFileManager defaultManager ] fileExistsAtPath:path];
}
+ (long long)cacheFileSize:(NSURL *)url
{
    if (![self cacheFileExists:url]) {
        return 0;
    }
    //获取缓存地址
    NSString * path = [self cacheFilePath:url];
    //计算文件路径对应的文件大小
    NSDictionary * info = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return [info[NSFileSize] longLongValue];
}
+ (long long)tmpFileSize:(NSURL *)url
{
    if (![self tmpFileExists:url]) {
          return 0;
      }
      //获取缓存地址
      NSString * path = [self tmpFilePath:url];
      //计算文件路径对应的文件大小
      NSDictionary * info = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
      return [info[NSFileSize] longLongValue];
}
+ (long long)tmpFileExists:(NSURL *)url
{
    NSString * path = [self tmpFilePath:url];
    return [[NSFileManager defaultManager ] fileExistsAtPath:path];
}
//
+ (NSString *)contentType:(NSURL *)url{
    //获取缓存地址
    NSString * path = [self cacheFilePath:url];
    NSString * pathExtension = path.pathExtension;
    
    CFStringRef contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(__bridge CFStringRef)(pathExtension),NULL);
    NSString * contentType = CFBridgingRelease(contentTypeCF);
    return contentType;
}
+ (void)removeTmpToCachePath:(NSURL * )url
{
    NSString * tmpPath = [self tmpFilePath:url];
    NSString * cachePath = [self cacheFilePath:url];
    [[NSFileManager defaultManager] moveItemAtPath:tmpPath toPath:cachePath error:nil];
}
+ (void)clearTmpFile:(NSURL * )url
{
    NSString * tmpPath =[self tmpFilePath:url];
    BOOL isDirectory = YES;
    BOOL isEx = [[NSFileManager defaultManager]fileExistsAtPath:tmpPath isDirectory:&isDirectory];
    if (isEx && !isDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
    }
}
@end
