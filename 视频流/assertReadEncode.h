//
//  assertReadEncode.h
//  视频流
//
//  Created by mac on 2019/12/22.
//  Copyright © 2019 cc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface assertReadEncode : NSObject

- (void)initReader:(NSString*)inputPath subtitles:(NSArray*)subtitles outputPath:(NSString*)outputPath handle:(void(^)(bool))handle;

@end

NS_ASSUME_NONNULL_END
