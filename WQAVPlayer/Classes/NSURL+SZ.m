//
//  NSURL+SZ.m
//  WQDownLoader
//
//  Created by wuqiong on 2020/4/22.
//  Copyright © 2020 woshisha. All rights reserved.
//

#import "NSURL+SZ.h"
@implementation NSURL (SZ)

- (NSURL *)steamingURL{
    NSURLComponents * components = [NSURLComponents componentsWithString:self.absoluteString];
    components.scheme = @"streaming";
    return components.URL;
}
- (NSURL *)httpURL{
    NSURLComponents * components = [NSURLComponents componentsWithString:self.absoluteString];
    components.scheme = @"http";
    return components.URL;
}

@end
