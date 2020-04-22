//
//  WQAudioDownLoader.m
//  WQDownLoader
//
//  Created by wuqiong on 2020/4/22.
//  Copyright © 2020 woshisha. All rights reserved.
//

#import "WQAudioDownLoader.h"
#import "WQRemoteAudioFile.h"

@interface WQAudioDownLoader ()<NSURLSessionDataDelegate>

@property(nonatomic, strong)NSURLSession * session;
@property(nonatomic, strong)NSOutputStream * outputStream;
//当前下载的路径
@property(nonatomic, strong)NSURL * url;




@end

@implementation WQAudioDownLoader


- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration ] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)downLoaderWith:(NSURL *)url offset:(long long)offset
{
    self.url = url;
    self.offset = offset;
    [self cannelAndClean];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:(NSURLRequestReloadIgnoringLocalCacheData) timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask * task = [self.session dataTaskWithRequest:request];
    [task resume];
}
- (void)cannelAndClean
{
    [self.session invalidateAndCancel];
    self.session = nil;
    //清除本地的临时缓存
    [WQRemoteAudioFile clearTmpFile:self.url];
    self.loadedSize = 0;
}
#pragma  mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSHTTPURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    //读出文件大小（播放器用）
    self.totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString * contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length !=0) {
        self.totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    //文件类型(播放器用)
    self.mimeType = response.MIMEType;
    
    //打开输出流
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:[WQRemoteAudioFile tmpFilePath:response.URL] append:YES];
    [self.outputStream open];
    completionHandler(NSURLSessionResponseAllow);
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveData:(NSData *)data
{
    self.loadedSize += data.length;
    NSLog(@"已经现在：%d",self.loadedSize);
    [self.outputStream write:data.bytes maxLength:data.length];
    if ([self.delegate respondsToSelector:@selector(downLoading)]) {
        [self.delegate downLoading];
    }
}
- (void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    //暂时忽略者-999
    
    if (error == nil ) {
         NSLog(@"下载完成");
        if ([WQRemoteAudioFile tmpFileSize:task.response.URL] == self.totalSize) {
            //移动数据 ：临时文件-》cache文件
            [WQRemoteAudioFile removeTmpToCachePath:task.response.URL];
        }
    }else{
        NSLog(@"用错误%@",error);
    }
}
@end
