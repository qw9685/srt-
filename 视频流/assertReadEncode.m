//
//  assertReadEncode.m
//  视频流
//
//  Created by mac on 2019/12/22.
//  Copyright © 2019 cc. All rights reserved.
//

#import "assertReadEncode.h"
#import "ccAssetWriterManager.h"
#import "ccAssetReaderManager.h"
#import <UIKit/UIKit.h>

@interface assertReadEncode ()

@property (nonatomic, strong) AVAssetReader *reader;//媒体读取对象

@end

@implementation assertReadEncode

- (void)initReader:(NSString*)inputPath subtitles:(NSArray*)subtitles outputPath:(NSString*)outputPath handle:(void(^)(bool))handle{
    
    //初始化
    ccAssetReaderManager* manager_reader = [ccAssetReaderManager initReader:inputPath];
    ccAssetWriterManager* manager_writer = [ccAssetWriterManager initWriter:outputPath inputPath:inputPath];

    //读取buffer 写入文件
    __block CMTime pts;
    [manager_writer pushVideoBuff:^CVPixelBufferRef _Nonnull{
        
        CMSampleBufferRef buffer = [manager_reader nextVideoSample];
        __block CVImageBufferRef CVPixelBuffer = CMSampleBufferGetImageBuffer(buffer);

        //时间点
        pts = CMSampleBufferGetPresentationTimeStamp(buffer);
        CGFloat time = CMTimeGetSeconds(pts);

        [subtitles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            float begin = [obj[@"begin"] floatValue];
            float end = [obj[@"end"] floatValue];
            NSString* subtitle = obj[@"subtitle"];

            if (time>=begin && time<=end) {
                UIImage* image = [self imageWithSampleBuffer:buffer];
                UIImage* image_text = [self addText:subtitle addToView:image];
                UIImage* image_transfrom = [self transfromImage:image_text];
                CVPixelBuffer = [self pixelBufferFromCGImage:image_transfrom.CGImage];
            }
        }];
                
        return CVPixelBuffer;
        
    } getBufferTimeBlock:^CMTime{
        return pts;
    }];
    [manager_writer pushAudioBuffer:^CMSampleBufferRef _Nonnull{
        return [manager_reader nextAudioSample];
    }];
    [manager_writer finishHandle:^(bool success) {
        if (success) {
            [manager_reader cancel];
            [manager_writer cancel];
        }
        handle(success);
    }];
}

//转CMSampleBufferRef-->UIImage 并且旋转
- (UIImage*)imageWithSampleBuffer:(CMSampleBufferRef)buffer {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(buffer);
    CIImage *ciimage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
   // 旋转的方法
    CIImage *image = [ciimage imageByApplyingCGOrientation:kCGImagePropertyOrientationRight];
    return [UIImage imageWithCIImage:image];
}
//转UIImage-->UIImage 并且旋转回去
- (UIImage*)transfromImage:(UIImage*)image {
    // 旋转的方法
    CIImage* ciimage = [CIImage imageWithCGImage:image.CGImage];
    ciimage = [ciimage imageByApplyingCGOrientation:kCGImagePropertyOrientationLeft];
//    CIImage *ciimage = [image.CIImage imageByApplyingCGOrientation:kCGImagePropertyOrientationLeft];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef myImage = [context createCGImage:ciimage fromRect:CGRectMake(0, 0, image.size.height, image.size.width)];
    return [UIImage imageWithCGImage:myImage];
}

//CGImageRef --> CVPixelBufferRef
- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height,  kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    // kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst 需要转换成需要的32BGRA空间
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
                                                 frameSize.height, 8, 4*frameSize.width, rgbColorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

// 添加文字水印
- (UIImage*)addText:(NSString*)text addToView:(UIImage*)image{
    
    int w = image.size.width;
    int h = image.size.height;
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, w, h)];
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;//水平居中
    UIFont* font = [UIFont systemFontOfSize:40];
    
    NSDictionary *attr = @{NSFontAttributeName: font, NSForegroundColorAttributeName : [UIColor whiteColor], NSParagraphStyleAttributeName:textStyle,NSKernAttributeName:@(2),NSBackgroundColorAttributeName:[UIColor blackColor]};
        
    [text drawInRect:CGRectMake(0, h - 60, w, 60) withAttributes:attr];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end
