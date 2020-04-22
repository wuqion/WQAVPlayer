//
//  ViewController.m
//  WQDownLoader
//
//  Created by wuqiong on 2020/4/22.
//  Copyright © 2020 woshisha. All rights reserved.
//

#import "WQViewController.h"
#import "WQRemotePlayer.h"

@interface WQViewController ()
//时间
@property (strong, nonatomic) UISlider *timeSlider;
//声音
@property (strong, nonatomic) UISlider *volumeSlider;
@property(nonatomic, strong)NSTimer * timer;
//当前播放时间
@property (strong, nonatomic) UILabel *playTime;
//加载进度
@property (strong, nonatomic) UILabel *loadProsess;

@end

@implementation WQViewController
- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}
- (void)update{
    NSString * cunrrenTime =[WQRemotePlayer shareInstance].cunrrenTimeFormat;
    self.playTime.text = cunrrenTime;
    self.timeSlider.value = [WQRemotePlayer shareInstance].progress;
    [[WQRemotePlayer shareInstance] loadDataProgress];
    
    CGRect frame =  _loadProsess.frame;
    frame.size.width = (self.view.frame.size.width - 60) *[WQRemotePlayer shareInstance].loadDataProgress;
    _loadProsess.frame =frame;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //时间进度
    _timeSlider = [[UISlider alloc]initWithFrame:CGRectMake(30, 100, self.view.bounds.size.width - 60, 50)];
    [_timeSlider addTarget:self action:@selector(timeChangeSlider:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_timeSlider];
    //声音
    _volumeSlider = [[UISlider alloc]initWithFrame:CGRectMake(30, 180, self.view.bounds.size.width - 60, 50)];
    [_volumeSlider addTarget:self action:@selector(volumeChangeSlider:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_volumeSlider];
    
    //播放时间
    _playTime = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 110, 79, 80, 40)];
    [self.view addSubview:_playTime];
    
    //播放按钮
    UIButton * playBtn = [[UIButton alloc]initWithFrame:CGRectMake(30, 240, 80, 44)];
    [playBtn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:playBtn];
     //暂停按钮
    UIButton * pauseBtn = [[UIButton alloc]initWithFrame:CGRectMake(150, 240, 80, 44)];
    [pauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
    [pauseBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];

    [pauseBtn addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pauseBtn];
    
    _loadProsess = [[UILabel alloc]initWithFrame:CGRectMake(30, 230, 0, 4)];
    _loadProsess.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_loadProsess];
    
    [self timer];
}
- (void)play {
    NSURL * url = [NSURL URLWithString:@"http://96.ierge.cn/14/222/445723.mp3?v=0524"];
    [[WQRemotePlayer shareInstance] playWithURL:url];
    
}
- (void)volumeChangeSlider:(UISlider *)sender {
    [[WQRemotePlayer shareInstance] setVolume:sender.value];
}
- (void)timeChangeSlider:(UISlider *)sender {
    [[WQRemotePlayer shareInstance] seekWithTimePress:sender.value];
}
- (void)pause {
    [[WQRemotePlayer shareInstance] pause];
}



@end
