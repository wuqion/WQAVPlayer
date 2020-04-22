//
//  WQAudioDownLoader.h
//  WQDownLoader
//
//  Created by wuqiong on 2020/4/22.
//  Copyright © 2020 woshisha. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WQAudioDownLoaderDelegate <NSObject>

- (void)downLoading;

@end

//下载某个区间的数据
@interface WQAudioDownLoader : NSObject
@property (nonatomic,weak) id<WQAudioDownLoaderDelegate> delegate;

//当前下载片段的总长
@property(nonatomic, assign)long long totalSize;
@property(nonatomic, assign)long long loadedSize;//已经下载的长度
@property(nonatomic, assign)long long offset;//
@property(nonatomic, strong)NSString * mimeType;

- (void)downLoaderWith:(NSURL *)url offset:(long long)offset;

@end

NS_ASSUME_NONNULL_END
