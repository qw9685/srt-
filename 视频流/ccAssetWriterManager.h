//
//  ccAssetWriterManager.h
//  视频流
//
//  Created by cc on 2019/12/25.
//  Copyright © 2019 cc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ccAssetWriterManager : NSObject

+ (instancetype)initWriter:(NSString *)outPutPath inputPath:(NSString*)inputPath;

// 开始写入
- (void)pushAudioBuffer:(CMSampleBufferRef(^)(void))getBufferBlock;

- (void)pushVideoBuff:(CVPixelBufferRef(^)(void))getBufferBlock getBufferTimeBlock:(CMTime(^)(void))getBufferTimeBlock;

- (void)finishHandle:(void(^)(bool))handle;

//停止
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
