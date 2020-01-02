//
//  ViewController.m
//  视频流
//
//  Created by mac on 2019/12/22.
//  Copyright © 2019 cc. All rights reserved.
//

#import "ViewController.h"
#import "assertReadEncode.h"
#import <AVKit/AVKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString* path = [[NSBundle mainBundle]pathForResource:@"0.mp4" ofType:nil];
    
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [docPath objectAtIndex:0];
    NSString* outPath = [NSString stringWithFormat:@"%@/1.mp4",documentsPath];

    [[NSFileManager defaultManager] removeItemAtPath:outPath error:nil];

    NSArray* array_subtitles = [self getVideoSubtitles:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"srt"]];

    assertReadEncode* reader = [[assertReadEncode alloc] init];
    [reader initReader:path subtitles:array_subtitles outputPath:outPath handle:^(bool success) {

        if (success) {
            NSString* outPath = [NSString stringWithFormat:@"%@/1.mp4",documentsPath];
            NSURL *url = [NSURL fileURLWithPath:outPath];
            AVPlayerViewController *playerVc = [[AVPlayerViewController alloc]init];
            playerVc.player = [[AVPlayer alloc]initWithURL:url];
            [playerVc.player play];
            [self presentViewController:playerVc animated:YES completion:nil];
        }else{
            NSLog(@"失败了!!!!");
        }

    }];
}
//解析srt字幕
-(NSArray*)getVideoSubtitles:(NSString*)srtPath{
    
    NSString *content = [[NSString alloc] initWithContentsOfFile:srtPath encoding:NSUTF8StringEncoding error:nil];
    return [self setSrt:content];
    
}
// 设置字幕字符串
- (NSArray*)setSrt:(NSString *)srt {
    // 去除\t\r
    NSString *lyric = [NSString stringWithString:srt];
    lyric = [lyric stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    lyric = [lyric stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    NSArray *arr = [lyric componentsSeparatedByString:@"\n"];
    
    NSMutableArray *tempArr = [NSMutableArray new]; // 存放Item的数组
    NSMutableDictionary *itemDic = [NSMutableDictionary dictionary]; // 存放歌词信息的Item
    
    __block NSInteger i = 0; // 标记， 0：序号  1: 时间   2:英文    3:中文
    for (NSString *str in arr) {
        @autoreleasepool {
            NSString *tempStr = [NSString stringWithString:str];
            tempStr = [tempStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (tempStr.length > 0) {
                switch (i) {
                    case 0:
                        [itemDic setObject:tempStr forKey:@"index"];
                        break;
                    case 1:{
                        //时间
                        NSRange range2 = [tempStr rangeOfString:@"-->"];
                        if (range2.location != NSNotFound) {
                            NSString *beginstr = [tempStr substringToIndex:range2.location];
                            beginstr = [beginstr stringByReplacingOccurrencesOfString:@" " withString:@""];
                            NSArray * arr = [beginstr componentsSeparatedByString:@":"];
                            if (arr.count == 3) {
                                NSArray * arr1 = [arr[2] componentsSeparatedByString:@","];
                                if (arr1.count == 2) {
                                    //将开始时间数组中的时间换化成秒为单位的
                                    CGFloat start = [arr[0] floatValue] * 60*60 + [arr[1] floatValue]*60 + [arr1[0] floatValue] + [arr1[1] floatValue]/1000;
                                    [itemDic setObject:@(start) forKey:@"begin"];
                                    
                                    NSString *endstr = [tempStr substringFromIndex:range2.location+range2.length];
                                    endstr = [endstr stringByReplacingOccurrencesOfString:@" " withString:@""];
                                    NSArray * array = [endstr componentsSeparatedByString:@":"];
                                    if (array.count == 3) {
                                        NSArray * arr2 = [array[2] componentsSeparatedByString:@","];
                                        if (arr2.count == 2) {
                                            //将结束时间数组中的时间换化成秒为单位的
                                            CGFloat end = [array[0] floatValue] * 60*60 + [array[1] floatValue]*60 + [arr2[0] floatValue] + [arr2[1] floatValue]/1000;
                                            [itemDic setObject:@(end) forKey:@"end"];
                                        }
                                    }
                                }
                            }
                        }
                        break;
                    }
                    case 2:
                        [itemDic setObject:tempStr forKey:@"subtitle"];
                        break;
                        //                    case 3: {
                        //                        [itemDic setObject:tempStr forKey:@"en"];
                        //                        break;
                        //                    }
                    default:
                        break;
                }
                i ++;
            }else {
                // 遇到空行，就添加到数组
                i = 0;
                NSDictionary *dic = [NSDictionary dictionaryWithDictionary:itemDic];
                [tempArr addObject:dic];
                [itemDic removeAllObjects];
            }
        }
    }
    return tempArr;
}


@end
