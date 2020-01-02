//
//  ccAssetReaderManager.m
//  视频流
//
//  Created by cc on 2019/12/25.
//  Copyright © 2019 cc. All rights reserved.
//

#import "ccAssetReaderManager.h"

@interface ccAssetReaderManager ()

@property (nonatomic,strong) AVAsset *videoAsset;
//媒体读取对象
@property (nonatomic,strong) AVAssetReader *reader;
//加载轨道及配置
@property (nonatomic,strong) AVAssetReaderTrackOutput *readerTrackOutput_video;
@property (nonatomic,strong) AVAssetReaderTrackOutput *readerTrackOutput_audio;
//资源配置
@property (nonatomic,strong) NSDictionary *videoSetting;
@property (nonatomic,strong) NSDictionary *audioSetting;

@end

@implementation ccAssetReaderManager

+ (instancetype)initReader:(NSString *)videoPath{
    
    ccAssetReaderManager* manager = [[ccAssetReaderManager alloc] init];
    manager.videoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    
    if ([manager.reader canAddOutput:manager.readerTrackOutput_video]) {
        [manager.reader addOutput:manager.readerTrackOutput_video];
    }
    if ([manager.reader canAddOutput:manager.readerTrackOutput_audio]) {
        [manager.reader addOutput:manager.readerTrackOutput_audio];
    }
    [manager.reader startReading];
    return manager;
}

- (CMSampleBufferRef)nextVideoSample{
    if (!_readerTrackOutput_video) {
        return nil;
    }
    return [_readerTrackOutput_video copyNextSampleBuffer];
}
- (CMSampleBufferRef)nextAudioSample{
    if (!_readerTrackOutput_audio) {
        return nil;
    }
    return [_readerTrackOutput_audio copyNextSampleBuffer];
}

- (void)cancel{
    [self.reader cancelReading];
}

-(AVAssetReader *)reader{
    if (!_reader) {
        _reader = [[AVAssetReader alloc] initWithAsset:self.videoAsset error:nil];
    }
    return _reader;
}
-(AVAssetReaderTrackOutput *)readerTrackOutput_video{
    if (!_readerTrackOutput_video) {
        AVAssetTrack *videoTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        _readerTrackOutput_video = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:self.videoSetting];
        _readerTrackOutput_video.alwaysCopiesSampleData = NO;
    }
    return _readerTrackOutput_video;
}
-(AVAssetReaderTrackOutput *)readerTrackOutput_audio{
    if (!_readerTrackOutput_audio) {
        AVAssetTrack *audioTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        _readerTrackOutput_audio = [[AVAssetReaderTrackOutput alloc] initWithTrack:audioTrack outputSettings:self.audioSetting];
        _readerTrackOutput_audio.alwaysCopiesSampleData = NO;
    }
    return _readerTrackOutput_audio;
}
-(NSDictionary *)videoSetting{
    if (!_videoSetting) {
        _videoSetting = @{
            (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
        };
    }
    return _videoSetting;
}
-(NSDictionary *)audioSetting{
    if (!_audioSetting) {
        _audioSetting = @{
            AVFormatIDKey : [NSNumber numberWithUnsignedInt:kAudioFormatLinearPCM]
        };
    }
    return _audioSetting;
}

@end
