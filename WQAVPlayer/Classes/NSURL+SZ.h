//
//  NSURL+SZ.h
//  WQDownLoader
//
//  Created by wuqiong on 2020/4/22.
//  Copyright © 2020 woshisha. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (SZ)
- (NSURL *)steamingURL;
- (NSURL *)httpURL;
@end

NS_ASSUME_NONNULL_END
