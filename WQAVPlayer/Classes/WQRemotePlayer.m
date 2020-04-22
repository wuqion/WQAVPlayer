//
//  WQRemotePlayer.m
//  WQDownLoader
//
//  Created by wuqiong on 2020/4/22.
//  Copyright © 2020 woshisha. All rights reserved.
//

#import "WQRemotePlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "WQRemoteResourceLoaderDelegate.h"
#import "NSURL+SZ.h"

@interface WQRemotePlayer ()
{
    BOOL isUserPause;
}

@property(nonatomic, strong)AVPlayer * player;
@property(nonatomic, strong)WQRemoteResourceLoaderDelegate * resourceLoaderDelegate;

@end

@implementation WQRemotePlayer

+ (instancetype)shareInstance
{
    static WQRemotePlayer * _RemotePlayer;
    if (!_RemotePlayer) {
        _RemotePlayer = [WQRemotePlayer new];
    }
    return _RemotePlayer;
}


-(void)playWithURL:(NSURL *)url isCache:(BOOL)isCache
{
    NSURL * currentURL = [(AVURLAsset *)self.player.currentItem.asset URL];
    if ([_url isEqual:currentURL]) {
        NSLog(@"当前播放任务已存在");
        [self resume];
        return;
    }
    _url = url;
    if (isCache) {
        //重点，必须改协议（给数据流切段），不然不走WQRemoteResourceLoaderDelegate代理
           _url = [_url steamingURL];
    }
   
    //资源的请求
    AVURLAsset * asset = [AVURLAsset assetWithURL:_url];
    //关于音频的网络请求，是c通过这个对象s，调用代理的相关方法，进行加载的
//    asset.resourceLoader
   //上面url没有改的时候这个，没有意义，
  {
    self.resourceLoaderDelegate = [WQRemoteResourceLoaderDelegate new];
    [asset.resourceLoader setDelegate:self.resourceLoaderDelegate queue:dispatch_get_main_queue()
     ];
  }
    if (self.player.currentItem) {//防止重复播放崩溃
          [self removeObserver];
      }
    //资源的组织
    AVPlayerItem * item = [AVPlayerItem playerItemWithAsset:asset];
    //坚挺状态
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监听当前的资源是否已经准备足够加载了（播放了）
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    //播放完成的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
     //播放中断的监听（如来电）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playInterruption) name:AVPlayerItemPlaybackStalledNotification object:nil];
    //播放
    self.player = [AVPlayer playerWithPlayerItem:item];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerStatusReadyToPlay) {
            [self resume];
        }else{
            NSLog(@"未知状态");
            self.state = WQRemotePlayerStateFailed;
        }
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        BOOL status = [change[NSKeyValueChangeNewKey] boolValue];
        if (status ) {
            //在这里调用播放有问题。暂停的时候有可能触发播放
            if (isUserPause) {
                [self resume];
            }
            NSLog(@"当前的资源，准备的已经足够加载了");
        }else{
            NSLog(@"当前的资源，正在加载中。。");
            self.state = WQRemotePlayerStateLoading;
        }
    }
}
//播放完成
- (void)playEnd
{
    NSLog(@"播放完成");
    self.state = WQRemotePlayerStateStoped;
}
//播放被打断
//1。来电话
//2。资源不够
- (void)playInterruption
{
    NSLog(@"播放被打断");
    self.state = WQRemotePlayerStatePause;
}
-(void)removeObserver{
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

//暂停
-(void)pause
{
    [self.player pause];
    isUserPause = YES;
    if (self.player) {
       self.state = WQRemotePlayerStatePause;
    }
}
-(void)resume
{
    [self.player play];
    isUserPause = NO;
    //代表当前播放器x存在，数据组织者的数据准备，已经足够播放了
    if (self.player && self.player.currentItem.playbackLikelyToKeepUp) {
        self.state = WQRemotePlayerStatePlaying;
    }
    
}
-(void)stop
{
    [self.player pause];
    self.player = nil;
    if (self.player) {
       self.state = WQRemotePlayerStateStoped;
    }
}

-(void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer
{
  
    
    //总时长
    CMTime totalTime = self.player.currentItem.duration;
    NSTimeInterval totalTimeSec = CMTimeGetSeconds(totalTime);

    //当前音频，以播放的时间
    CMTime playTime = self.player.currentItem.currentTime;
    NSTimeInterval playTimeSec = CMTimeGetSeconds(playTime);
    
    playTimeSec +=timeDiffer;
    
    [self seekWithTimePress:playTimeSec/totalTimeSec];
    
}
-(void)seekWithTimePress:(float)pregress{
    //可以指定时间节点f播放
    //时间：CMTime :影片时间
    //影片时间 ->秒
    //秒 ->影片时间
    if (pregress>1 ||pregress<0) {
        return;
    }
    //总时长
    CMTime totalTime = self.player.currentItem.duration;
    //当前音频，以播放的时间
    //self.player.currentItem.currentTime
    NSTimeInterval totalSec = CMTimeGetSeconds(totalTime);
    NSTimeInterval playTimeSec = totalSec * pregress;
    CMTime currentTime = CMTimeMake(playTimeSec, 1);
    
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"确定加载这个时间点点音频");
        }else{
            NSLog(@"去取消加载这个时间点点音频");
        }
    }];
}
-(void)setRate:(float)rate
{
    [self.player setRate:rate];
}
- (float)rate
{
    return self.player.rate;
}
-(void)setMuted:(BOOL)muted
{
    self.player.muted = muted;
}
- (BOOL)muted
{
    return self.player.muted;
}
-(void)setState:(WQRemotePlayerState)state
{
    _state = state;
}
-(void)setVolume:(float)volume
{
    if (volume>1 ||volume<0) {
       return;
    }
    if (volume >0) {
        [self setMuted:NO];
    }
    self.player.volume = volume;
}
- (float)volume
{
    return   self.player.volume;
}
- (NSTimeInterval)totalTime
{
    CMTime totalTime = self.player.currentItem.duration;
    NSTimeInterval totalTimeSec = CMTimeGetSeconds(totalTime);
    if (isnan(totalTimeSec)) {
        return 0;
    }
    return totalTimeSec;
}
- (NSTimeInterval)cunrrenTime{
      CMTime playTime = self.player.currentItem.currentTime;
      NSTimeInterval playTimeSec = CMTimeGetSeconds(playTime);
    if (isnan(playTimeSec)) {
        return 0;
    }
    return playTimeSec;
}
- (float)progress
{
    return self.cunrrenTime/self.totalTime;
}
- (float)loadDataProgress
{
    CMTimeRange timeRange = [self.player.currentItem.loadedTimeRanges.lastObject CMTimeRangeValue];
    CMTime loadTime = CMTimeAdd(timeRange.start, timeRange.duration);
    NSTimeInterval loadTimeSec = CMTimeGetSeconds(loadTime);
    if (isnan(loadTimeSec)) {
        return 0;
    }
//    NSLog(@"%f",loadTimeSec);
    return loadTimeSec / self.totalTime;
    
}
-(NSString *)cunrrenTimeFormat
{
    return  [NSString stringWithFormat:@"%02zd:%02zd",(long)self.cunrrenTime/60,(long)self.cunrrenTime%60];
}
-(NSString *)totalTimeFormat
{
    return  [NSString stringWithFormat:@"%02zd:%02zd",(long)self.totalTime/60,(long)self.totalTime%60];
}
@end
