//
//  SCXPlayer.h
//  AVPlayer视频播放库
//
//  Created by 孙承秀 on 2017/2/28.
//  Copyright © 2017年 孙承秀. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

/**************** 判断当前播放状态 ****************/
typedef NS_ENUM(NSInteger , SCXPlayerState) {

    
    SCXPlayerStateReadyToPlay , // 准备播放
    SCXPlayerStatePlaying , // 正在播放
    SCXPlayerStateStoped , // 停止播放
    SCXPlayerStateFinished , // 播放完成
    SCXPlayerStateFailed , // 播放失败
    SCXPlayerStateBuffering  // 正在缓冲

};

/**************** 判断当前关闭按钮图片 ****************/
typedef NS_ENUM(NSInteger , SCXPlayerCloseBtnType) {

    SCXPlayerCloseBtnTypePop , // 返回按钮的样式
    SCXPlayerCloseBtnTypeClose // 关闭按钮的样式

};
@protocol SCXPlayerDelegete;
@interface SCXPlayer : UIView

/*************  视频跳到指定的某个时间播放 ***************/
@property ( nonatomic , assign )double seekTime;

/*************  菊花loading状态 ***************/
@property ( nonatomic , strong )UIActivityIndicatorView *loadingActivityIndicatorView;

/*************  顶部toolBar ***************/
@property ( nonatomic , strong )UIView *topToolBar;

/*************  底部toolBar ***************/
@property ( nonatomic , strong )UIView *bottomToolBar;

/*************  开始暂停按钮 ***************/
@property ( nonatomic , strong )UIButton *playOrPauseBtn;

/*************  亮度进度条 ***************/
@property ( nonatomic , strong )UISlider *lightSlider;

/*************  进度进度条 ***************/
@property ( nonatomic , strong )UISlider *progresseSlider;

/*************  声音进度条 ***************/
@property ( nonatomic , strong )UISlider *volumeSlider;

/*************  系统声音slider ***************/
@property ( nonatomic , strong )UISlider *systemSlider;

/*************  进度条单击手势 ***************/
@property ( nonatomic , strong )UITapGestureRecognizer *pregressTap;

/*************  载入的数据进度条（UIprogressView 非UISlider） ***************/
@property ( nonatomic , strong )UIProgressView *loadingProgressView;

/*************  全屏按钮 ***************/
@property ( nonatomic , strong )UIButton *fullScreenButton;

/*************  左边显示已经观看的时间label ***************/
@property ( nonatomic , strong )UILabel *leftTimeLabel;

/*************  右边显示剩余时间label ***************/
@property ( nonatomic , strong )UILabel *rightTimeLabel;

/*************  关闭按钮 ***************/
@property ( nonatomic , strong )UIButton *closeBtn;

/*************  视频标题label ***************/
@property ( nonatomic , strong )UILabel *titleNameLabel;

/*************  当点击整个视频的view的时候的单击手势 ***************/
@property ( nonatomic , strong )UITapGestureRecognizer *viewTap;

/*************  当点击整个视频的view的时候的双击手势 ***************/
@property ( nonatomic , strong )UITapGestureRecognizer *viewDoubleTap;

/*************  加载失败label ***************/
@property ( nonatomic , strong )UILabel *loadFailedLabel;

/*************  当前播放的item ***************/
@property ( nonatomic , strong )AVPlayerItem *currentItem;

/*************  视频的URL,可以使网络url也可以是本地URL ***************/
@property ( nonatomic , strong )NSURL *urlString;

/*************  当前播放状态 ***************/
@property ( nonatomic , assign )SCXPlayerState playingState;

/*************  关闭按钮的图片种类 ***************/
@property ( nonatomic , assign )SCXPlayerCloseBtnType closeBtnType;

/*************  播放器Player ***************/
@property ( nonatomic , strong )AVPlayer *player;

/*************  player展示层playerLayer,用来把player展示出来 ***************/
@property ( nonatomic , strong )AVPlayerLayer *playerLayer;

/*************  5秒后自动关闭功能菜单时间器 ***************/
@property ( nonatomic , strong )NSTimer *autoDissmissTimer;


/*************  实时监听时间起 ***************/
@property ( nonatomic , strong )id monitorTimer;

/*************  SCXPlayer代理方法 ***************/
@property ( nonatomic , assign )id <SCXPlayerDelegete> delegate;

/*************  是否正在拖拽进度条 ***************/
@property ( nonatomic , assign )BOOL isDragingSlider;

/*************  是否是全屏 ***************/
@property ( nonatomic , assign )BOOL isFullScreen;

/*************  手指当前触摸的点 ***************/
@property ( nonatomic , assign )CGPoint firstPoint;

/*************  手指触摸的原始点 ***************/
@property ( nonatomic , assign )CGPoint originPoint;

/*************  手指触摸的第二个 ***************/
@property ( nonatomic , assign )CGPoint secondPoint;

/*************  是否允许后台播放 ***************/
@property ( nonatomic , assign )BOOL isAllowVideoPlayBackground;




#pragma mark ------------------ 方法 ---------------------
/*************  获取正在播放的时间点 ***************/
- (double)currentTime;


/*************  播放视频 ***************/
- (void)play;

/*************  暂停视频 ***************/
- (void)pause;
@end

@protocol SCXPlayerDelegete <NSObject>

/*************  准备播放 ***************/
- (void)scxplayerReadyToPlay:(SCXPlayer *)player SCXPlayerState:(SCXPlayerState)playState;

/*************  播放失败 ***************/
- (void)scxplayerFailedPlay:(SCXPlayer *)player SCXPlayerState:(SCXPlayerState)playState;

/*************  结束播放 ***************/
- (void)scxplayerFinishPlay:(SCXPlayer *)player SCXPlayerState:(SCXPlayerState)playState;

/*************  点击播放按钮了 ***************/
- (void)scxplayer:(SCXPlayer *)player clickPlayOrPauseBtn:(UIButton *)btn;

/*************  view上面触发单击手势了 ***************/
- (void)scxplayer:(SCXPlayer *)player singleTapGestureAction:(UIGestureRecognizer *)singleTap;

/*************  view上面触发双击手势了 ***************/
- (void)scxplayer:(SCXPlayer *)player doubleTapGestureAction:(UIGestureRecognizer *)doubleTap;

/*************  关闭按钮触发时间 ***************/
- (void)scxplayer:(SCXPlayer *)player closeVideo:(UIButton *)btn;

/*************  全屏事件触发 ***************/
- (void)scxplayer:(SCXPlayer *)player didFullScreen:(UIButton *)btn;

/*************  播放完成监听 ***************/
- (void)scxplayerDidFinishPlayVideo:(SCXPlayer *)player;

-(void)scxplayerBegihPictureInPicture:(SCXPlayer *)player;
@end
