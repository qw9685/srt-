//
//  ccAssetReaderManager.h
//  视频流
//
//  Created by cc on 2019/12/25.
//  Copyright © 2019 cc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ccAssetReaderManager : NSObject

+ (instancetype)initReader:(NSString*)videoPath;

- (CMSampleBufferRef)nextVideoSample;
- (CMSampleBufferRef)nextAudioSample;

- (void)cancel;//停止

@end

NS_ASSUME_NONNULL_END
