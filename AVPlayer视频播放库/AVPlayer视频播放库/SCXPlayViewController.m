//
//  SCXPlayViewController.m
//  AVPlayer视频播放库
//
//  Created by 孙承秀 on 2017/3/15.
//  Copyright © 2017年 孙承秀. All rights reserved.
//

#import "SCXPlayViewController.h"
#import <AVFoundation/AVFoundation.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kCellID @"cellID"
@interface SCXPlayViewController ()<SCXPlayerDelegete>{

    SCXPlayer *scxPlayer;
    CGRect     playerFrame;
    AVPictureInPictureController *_pipViewController;

}

/*************  AVPlayerViewController ***************/
@property ( nonatomic , strong )AVPlayerViewController *playerController;

@end

@implementation SCXPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    scxPlayer = self.player;
    playerFrame = _player.frame;
    self.player.delegate = self;
    [self.player play];
    [self.view.layer addSublayer:self.player.layer];
    [self.view addSubview:self.player];
    [self initPictureInPictureVC];
}
- (void)initPictureInPictureVC{

    // 创建画中画播放器
    if([AVPictureInPictureController isPictureInPictureSupported]){
        _pipViewController =  [[AVPictureInPictureController alloc] initWithPlayerLayer:self.player.playerLayer];
        _pipViewController.delegate = self;
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [_pipViewController startPictureInPicture];
    
    
    

}
-(void)scxplayer:(SCXPlayer *)player didFullScreen:(UIButton *)btn{
    
    if (btn.isSelected) {//全屏显示
        scxPlayer.isFullScreen = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    }else{
        [self toNormal];
    }
}
- (void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [scxPlayer removeFromSuperview];
    scxPlayer.transform = CGAffineTransformIdentity;
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
        scxPlayer.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }else if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
        scxPlayer.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    scxPlayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    scxPlayer.playerLayer.frame =  CGRectMake(0,0, kScreenHeight,kScreenWidth);
    [scxPlayer.bottomToolBar
     mas_remakeConstraints:^(MASConstraintMaker *make) {
         make.height.mas_equalTo(40);
         make.top.mas_equalTo(kScreenWidth-40);
         make.width.mas_equalTo(kScreenHeight);
     }];
    [scxPlayer.topToolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.left.equalTo(scxPlayer).with.offset(0);
        make.width.mas_equalTo(kScreenHeight);
    }];
    [scxPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(scxPlayer.topToolBar).with.offset(5);
        make.height.mas_equalTo(30);
        make.top.equalTo(scxPlayer.topToolBar).with.offset(5);
        make.width.mas_equalTo(30);
    }];
    [scxPlayer.titleNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scxPlayer.topToolBar).with.offset(45);
        make.right.equalTo(scxPlayer.topToolBar).with.offset(-45);
        make.center.equalTo(scxPlayer.topToolBar);
        make.top.equalTo(scxPlayer.topToolBar).with.offset(0);
        
    }];
    [scxPlayer.loadFailedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenHeight);
        make.center.mas_equalTo(CGPointMake(kScreenWidth/2-36, -(kScreenWidth/2)+36));
        make.height.equalTo(@30);
    }];
    [scxPlayer.loadingActivityIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(CGPointMake(kScreenWidth/2-37, -(kScreenWidth/2-37)));
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:scxPlayer];
    scxPlayer.fullScreenButton.selected = YES;
    
    [scxPlayer bringSubviewToFront:scxPlayer.topToolBar];
    [scxPlayer bringSubviewToFront:scxPlayer.bottomToolBar
     ];
    
}
-(void)toNormal{
    [scxPlayer removeFromSuperview];
    [UIView animateWithDuration:0.5f animations:^{
        scxPlayer.transform = CGAffineTransformIdentity;
        scxPlayer.frame =CGRectMake(playerFrame.origin.x, playerFrame.origin.y, playerFrame.size.width, playerFrame.size.height);
        scxPlayer.playerLayer.frame =  scxPlayer.bounds;
        [self.view addSubview:scxPlayer];
        [scxPlayer.bottomToolBar
         mas_remakeConstraints:^(MASConstraintMaker *make) {
             make.left.equalTo(scxPlayer).with.offset(0);
             make.right.equalTo(scxPlayer).with.offset(0);
             make.height.mas_equalTo(40);
             make.bottom.equalTo(scxPlayer).with.offset(0);
         }];
        
        
        [scxPlayer.topToolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(scxPlayer).with.offset(0);
            make.right.equalTo(scxPlayer).with.offset(0);
            make.height.mas_equalTo(40);
            make.top.equalTo(scxPlayer).with.offset(0);
        }];
        
        
        [scxPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(scxPlayer.topToolBar).with.offset(5);
            make.height.mas_equalTo(30);
            make.top.equalTo(scxPlayer.topToolBar).with.offset(5);
            make.width.mas_equalTo(30);
        }];
        
        
        [scxPlayer.titleNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(scxPlayer.topToolBar).with.offset(45);
            make.right.equalTo(scxPlayer.topToolBar).with.offset(-45);
            make.center.equalTo(scxPlayer.topToolBar);
            make.top.equalTo(scxPlayer.topToolBar).with.offset(0);
        }];
        
        [scxPlayer.loadFailedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(scxPlayer);
            make.width.equalTo(scxPlayer);
            make.height.equalTo(@30);
        }];
        
    }completion:^(BOOL finished) {
        scxPlayer.isFullScreen = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        scxPlayer.fullScreenButton.selected = NO;
        
    }];
}

/**
 点击返回按钮

 */
- (void)scxplayer:(SCXPlayer *)player closeVideo:(UIButton *)btn{
  [_pipViewController startPictureInPicture];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/**
 推出后台，是否进行画中画

 */
-(void)scxplayerBegihPictureInPicture:(SCXPlayer *)player{


}


/**
 开始画中画

 */
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    NSLog(@"开始");
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];

}

/**
 画中画还原

 */
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler
{
    
    [self.nav presentViewController:self animated:YES completion:nil];
    completionHandler(YES);
}

@end
