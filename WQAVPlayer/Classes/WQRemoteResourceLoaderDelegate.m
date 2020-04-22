//
//  WQRemoteResourceLoaderDelegate.m
//  WQDownLoader
//
//  Created by wuqiong on 2020/4/22.
//  Copyright © 2020 woshisha. All rights reserved.
//

#import "WQRemoteResourceLoaderDelegate.h"
#import "WQRemoteAudioFile.h"
#import "WQAudioDownLoader.h"
#import "NSURL+SZ.h"

@interface WQRemoteResourceLoaderDelegate ()<WQAudioDownLoaderDelegate>

@property(nonatomic, strong)WQAudioDownLoader * downLoader;
@property(nonatomic, strong)NSMutableArray    * loadingRequests;

@end


@implementation WQRemoteResourceLoaderDelegate
- (WQAudioDownLoader *)downLoader
{
    if (!_downLoader) {
        _downLoader = [WQAudioDownLoader new];
        _downLoader.delegate = self;
    }
    return _downLoader;
}
- (NSMutableArray *)loadingRequests
{
    if (!_loadingRequests) {
        _loadingRequests = [NSMutableArray new];
    }
    return _loadingRequests;
}

//当外界，需要播放一段音频资源的时候，会调用一个请求，给这个对象
//这个对象会根据请求信息，抛数据给外界
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
     NSLog(@"%@",loadingRequest);
     NSLog(@"%@",[WQRemoteAudioFile tmpFilePath:loadingRequest.request.URL]);
    //查找本地缓存。如果有直接用缓存向外界数据缓存
    //1.拿到路径
    NSURL * url =loadingRequest.request.URL;
    NSURL *httpURL = [url httpURL];
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    long long currentOffset = loadingRequest.dataRequest.currentOffset;
    if (requestOffset != currentOffset) {
        requestOffset = currentOffset;
    }
    
    if ([WQRemoteAudioFile cacheFileExists:url]) {//存在本地缓存
        [self handleLoadingRequest:loadingRequest];
        return YES;
    }
    //记录所有的请求
    [self.loadingRequests addObject:loadingRequest];
    //大步骤下载
    //2.判断当前有没有下载，如果没有，开启下载， return
    if (self.downLoader.loadedSize == 0) {//没有正在下载
        //开始现在数据（根据请求的信息，url，requestOffset,requestLength）
        [self.downLoader downLoaderWith:httpURL offset:requestOffset];
        return YES;
    }
    //3.当前有下载， ->判断，是否需要重新下载，如果是（之前的请求不在新个请求内），直接重新下载， return
    //3.1当请求的资源，开始点 < 开始的下载点
    //3.2当请求的资源，开始点 > 开始的下载点+ 下载点长度 + 666（自定义的）
    if (requestOffset < self.downLoader.offset  || requestOffset > self.downLoader.offset +self.downLoader.loadedSize + 666) {//有正在下载，需要重新下载
        //开始现在数据（根据请求的信息，url，requestOffset,requestLength）
        NSLog(@"重新x下载%ld",requestOffset);
         [self.downLoader downLoaderWith:httpURL offset:requestOffset];
        return YES;
    }
    //开始处理请求（在下载过程当中，要不断的b判断）
    [self handleAllLoadingRequest];
    //下载的资源，和请求的资源，区间可以匹配
    //直接把本地缓存数据返回给外界
    //在不断的下载过程当中，返回数据给外界
    //4.处理所有请求，并且，在下载的过程中，不断的处理请求
    
    // NSLog(@"%@",loadingRequest);
    return YES;
}
//取消请求
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    // NSLog(@"取消请求");
    [self.loadingRequests removeObject:loadingRequest];
}
- (void)downLoading
{
    [self handleAllLoadingRequest];
}
- (void)handleAllLoadingRequest
{
    // NSLog(@"在这里处理不通的请求");
    
    NSMutableArray * deleteRequests = [NSMutableArray new];
    for (AVAssetResourceLoadingRequest * loadingRequest in self.loadingRequests) {
        //1.填充内容信息头
        long long totalSize = self.downLoader.totalSize;
        NSString * contentType =self.downLoader.mimeType;

        //内容大小
        loadingRequest.contentInformationRequest.contentLength = totalSize;
        loadingRequest.contentInformationRequest.contentType = contentType;
        //    //支持字节范围下载
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;

        //2.填充内容
        NSData * data = [NSData dataWithContentsOfFile:[WQRemoteAudioFile tmpFilePath:loadingRequest.request.URL] options:NSDataReadingMappedIfSafe error:nil];
        if (!data) {
            data = [NSData dataWithContentsOfFile:[WQRemoteAudioFile cacheFilePath:loadingRequest.request.URL] options:NSDataReadingMappedIfSafe error:nil];
        }
        long long requestOffset = loadingRequest.dataRequest.requestedOffset;
        long long currentOffset = loadingRequest.dataRequest.currentOffset;
        if (currentOffset !=requestOffset) {
            requestOffset = currentOffset;
        }
        NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
        
        long long resposeOffset = requestOffset - self.downLoader.offset;
        long long resposeLength = MIN(data.length - resposeOffset, MIN(self.downLoader.offset + self.downLoader.loadedSize - requestOffset,requestLength))  ;

        NSData * subData = [data subdataWithRange:NSMakeRange(resposeOffset, resposeLength)];
        [loadingRequest.dataRequest respondWithData:subData];
        //3.完成请求(必须把f所有的g关于这个请求的区间数据，都返回之后，才能完成这个请求)
        if (requestLength == resposeLength) {
            [loadingRequest finishLoading];
            [deleteRequests addObject:loadingRequest];
        }
        
    }
    [self.loadingRequests removeObjectsInArray:deleteRequests];
  
    
}
#pragma mark -  私有方法
//处理本地已经下载好的资源文件
-(void)handleLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    //根据请求信息，抛数据给外界
    //1。填充相应 的信息头信息
    //计算总大小
    //1.获取文件dk路径
    //1.1计算文件w路径对应的文件大小
    NSURL * url = loadingRequest.request.URL;
    long long totalSize = [WQRemoteAudioFile cacheFileSize:url];
    
    NSString * contentType = [WQRemoteAudioFile contentType:url];
    
    //内容大小
    loadingRequest.contentInformationRequest.contentLength = totalSize;
    loadingRequest.contentInformationRequest.contentType = contentType;
    //    //支持字节范围下载
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;

    //2.相应数据给外界
    //NSDataReadingMappedIfSafe地址映射，没有加载到内存
    NSData * data = [NSData dataWithContentsOfFile:[WQRemoteAudioFile cacheFilePath:url] options:(NSDataReadingMappedIfSafe) error:nil];
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    NSInteger requsetLength = loadingRequest.dataRequest.requestedLength;
    NSData * subData = [data subdataWithRange:NSMakeRange(requestOffset, requsetLength)];
    
    [loadingRequest.dataRequest respondWithData:subData];
    [loadingRequest finishLoading];
}
@end
