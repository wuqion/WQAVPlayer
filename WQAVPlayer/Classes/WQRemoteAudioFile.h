//
//  WQRemoteAudioFile.h
//  WQDownLoader
//
//  Created by wuqiong on 2020/4/22.
//  Copyright © 2020 woshisha. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WQRemoteAudioFile : NSObject

//获取缓存地址
+ (NSString *)cacheFilePath:(NSURL * )url;
//判断缓存文件是否存在
+ (BOOL)cacheFileExists:(NSURL *)url;
//获取缓存文件大小
+ (long long)cacheFileSize:(NSURL *)url;

//
+ (NSString *)contentType:(NSURL *)url;



//获取临时文件路径
+ (NSString *)tmpFilePath:(NSURL * )url;
//获取临时文件大小
+ (long long)tmpFileSize:(NSURL *)url;
//判断临时文件是否存在
+ (long long)tmpFileExists:(NSURL *)url;
//移动文件
+ (void)removeTmpToCachePath:(NSURL * )url;
//移除文件
+ (void)clearTmpFile:(NSURL * )url;

@end

NS_ASSUME_NONNULL_END
