#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSURL+SZ.h"
#import "WQAudioDownLoader.h"
#import "WQRemoteAudioFile.h"
#import "WQRemotePlayer.h"
#import "WQRemoteResourceLoaderDelegate.h"

FOUNDATION_EXPORT double WQAVPlayerVersionNumber;
FOUNDATION_EXPORT const unsigned char WQAVPlayerVersionString[];

