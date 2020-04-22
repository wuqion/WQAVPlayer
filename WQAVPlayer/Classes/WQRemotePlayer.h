//
//  WQRemotePlayer.h
//  WQDownLoader
//
//  Created by wuqiong on 2020/4/22.
//  Copyright © 2020 woshisha. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger ,WQRemotePlayerState){
    WQRemotePlayerStateUnknown =0,//未知（如m播放器没有播放）
    WQRemotePlayerStateLoading =1,//正在加载
    WQRemotePlayerStatePlaying =2,//正在播放
    WQRemotePlayerStateStoped =3,//停止
    WQRemotePlayerStatePause =4,//暂停
    WQRemotePlayerStateFailed =5//失败（比如没有网络。地址找不到）
};

NS_ASSUME_NONNULL_BEGIN

@interface WQRemotePlayer : NSObject

#pragma mark - 提供数据
@property(nonatomic, assign, readonly)NSTimeInterval totalTime;
@property(nonatomic, assign, readonly)NSTimeInterval cunrrenTime;
@property(nonatomic, assign, readonly)NSString * cunrrenTimeFormat;
@property(nonatomic, assign, readonly)NSString * totalTimeFormat;

@property(nonatomic, assign, readonly)float progress;
@property(nonatomic, strong, readonly)NSURL * url;
@property(nonatomic, assign, readonly)float loadDataProgress;
@property(nonatomic, assign)BOOL muted;
@property(nonatomic, assign)float volume;
@property(nonatomic, assign)float rate;
@property(nonatomic, assign,readonly)WQRemotePlayerState state;




+ (instancetype)shareInstance;

-(void)playWithURL:(NSURL *)url isCache:(BOOL)isCache;

-(void)pause;
-(void)resume;
-(void)stop;

-(void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer;
-(void)seekWithTimePress:(float)pregress;
//-(void)setRate:(float)rate;
//-(void)setMuted:(BOOL)muted;
//-(void)setVolume:(float)volume;



@end

NS_ASSUME_NONNULL_END
