//
//  WQRemotePlayer.h
//  WQDownLoader
//
//  Created by wuqiong on 2020/4/22.
//  Copyright © 2020 woshisha. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger ,WQRemotePlayerState){
    WQRemotePlayerStateUnknown =0,
    WQRemotePlayerStateLoading =1,
    WQRemotePlayerStatePlaying =2,
    WQRemotePlayerStateStoped =3,
    WQRemotePlayerStatePause =4,
    WQRemotePlayerStateFailed =5
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

-(void)playWithURL:(NSURL *)url;

//暂停
-(void)pause;
//重新播放
-(void)resume;
//停止
-(void)stop;
//快进timeDiffer秒
-(void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer;
//快进到pregress位置
-(void)seekWithTimePress:(float)pregress;

@end

NS_ASSUME_NONNULL_END
