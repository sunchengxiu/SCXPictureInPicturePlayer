//
//  ViewController.m
//  AVPlayer视频播放库
//
//  Created by 孙承秀 on 2017/2/28.
//  Copyright © 2017年 孙承秀. All rights reserved.
//

#import "ViewController.h"
#import "SCXPlayer.h"
#import <Masonry.h>
#import "SCXPlayViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface ViewController (){

    SCXPlayViewController *_playController;
    AVPictureInPictureController *_pipViewController;
  

}

/*************  AVPlayerViewController ***************/
@property ( nonatomic , strong )AVPlayerViewController *playerController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
//    // 添加蒙版效果
//    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:effect];
//    effectView.frame = self.view.frame;
//    effectView.alpha = 0.9;
//    [self.view insertSubview:effectView aboveSubview:self.view];
    [self SCX_presentPlayerController];

}



- (void)SCX_presentPlayerController{
    
    SCXPlayViewController *playController = [[SCXPlayViewController alloc]init];
    _playController = playController;
    playController.nav = self.navigationController;
    SCXPlayer *player = [[SCXPlayer alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 0.75)];
   
    NSURL *path = [[NSBundle mainBundle] URLForResource:@"Swift3.0QQ音乐" withExtension:@"mov"];
    //player.urlString = [NSURL URLWithString:@"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
    player.urlString = path;
    //player.delegate = self;
    [player.titleNameLabel setText:@"视频播放"];
    player.closeBtn.hidden = NO;
    player.isAllowVideoPlayBackground = YES;
    playController.player = player;
    [self.navigationController presentViewController:playController animated:YES completion:^{
        
    }];

}
@end
