//
//  SCXPlayViewController.h
//  AVPlayer视频播放库
//
//  Created by 孙承秀 on 2017/3/15.
//  Copyright © 2017年 孙承秀. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCXPlayer.h"
#import <AVKit/AVKit.h>
@protocol SCXPlayerControllerDelegate;
@interface SCXPlayViewController : UIViewController<AVPictureInPictureControllerDelegate>

/*************  SCXPlayer ***************/
@property ( nonatomic , strong )SCXPlayer *player;


/*************  nav ***************/
@property ( nonatomic , strong )UINavigationController *nav;

@end

